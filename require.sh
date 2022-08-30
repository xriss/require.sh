
if [[ "${BASH_VERSINFO:-0}" -lt 4 ]]; then
  echo "This script requires bash >= 4"
  exit 1
fi

trap ' trap - INT ;  kill -s INT "$$" ' INT

REQUIRE_VERSION_NUMBER="0.121"

# map special command names to package, otherwise we assume they are the same
declare -A pmap

# and I guess we should generate this from a better database?

pmap["build-essential"]="build-essential base-devel"

# commandline and env inputs
arg_flags=("version help dry quiet force reinstall-this-script pac=")

arg_get() {
key="$1"
	envkey=${key//-/_}
	if printenv REQUIRE_${envkey^^} ; then
		return 0
	fi
	return 20
}

arg_set() {
key="$1"
val="$2"
	envkey=${key//-/_}
	export REQUIRE_${envkey^^}="$val"
}

#parse arg_flags
declare -A all_flaga
declare -A value_flaga
declare -A boolean_flaga
for flag in $arg_flags ; do
	if [[ "${flag}" == *"="* ]]; then
		fs=(${flag//=/ })
		value_flaga[${fs[0]}]="1"
		all_flaga[${fs[0]}]="1"
		if arg_get ${fs[0]} >/dev/null ; then
			:
		else
			arg_set "${fs[0]}" "${fs[1]}"
		fi
	else
		fs=(${flag//:/ })
		boolean_flaga[${fs[0]}]="1"
		all_flaga[${fs[0]}]="1"
		if arg_get ${fs[0]} >/dev/null ; then
			:
		else
			arg_set "${fs[0]}" "${fs[1]}"
		fi
	fi
done

# fill in these arrays as output
declare -A args
declare -A flags
mode="names"
for arg in "$@" ; do

	case $mode in

		"set")
			val="$arg"
			flags["$set"]="$val"
			mode="names"
		;;

		"done")
			args[${#args[@]}]="$arg"
		;;

		*)
			if [[ "$arg" = "--" ]] ; then # just a -- so stop parsing
				mode="done"
			elif [[ "${arg:0:5}" = "--no-" ]] ; then # unset a flag
				set="${arg:5}"
				flags["$set"]=""
			elif [[ "${arg:0:2}" = "--" ]] ; then # begins with --
			
				set="${arg:2}"
				if [[ "$set" == *"="* ]] ; then # --var=val
					a=(${set//=/ })
					set="${a[0]}"
					val="${a[1]}"
					flags["$set"]="$val"
				else # --var val
					if [[ ${boolean_flaga[$set]} ]] ; then # no val expected
						flags["$set"]="1"
					else
						flags["$set"]="1" # temporary value
						mode="set"
					fi
				fi
			else
				args[${#args[@]}]="$arg"
			fi
		;;

	esac

done





# process flags we found here and probably overwrite env vars

if [[ -z "${args[0]}"  ]] ; then # print help if no names
	REQUIRE_HELP=1
fi
for key in "${!flags[@]}" ; do
	val=${flags[$key]}

	if [[ ${all_flaga[$key]} ]] ; then
		arg_set "${key}" "$val"
	else
		echo "unknown flag $key=$val"
		exit 20
	fi

done




# the first package manager we find is the one we use or force one with
# env REQUIRE_PAC="apk" or --pac="apk" option

ispac() {
name="$1"

	if [[ -n "$REQUIRE_PAC" ]] ; then
		if [[ "$REQUIRE_PAC" == "$name" ]] ; then return 0 ; fi
		return 1
	else
		if [[ -x "$(command -v $name)" ]] ; then return 0 ; fi
		return 1
	fi

}

# pick the pac style we will be using
PAC=""
if   ispac apt     ; then PAC="apt"
elif ispac pacman  ; then PAC="pacman"
elif ispac dnf     ; then PAC="dnf"
elif ispac pkg     ; then PAC="pkg"
elif ispac yum     ; then PAC="yum"
elif ispac brew    ; then PAC="brew"
fi

# install dependencies for this script to use this package manager
case $PAC in

	"apt")
		if ! [[ -x "$(command -v apt-file)" ]] ; then
			echo " require.sh is trying to sudo install apt-file so we can search for packages "
			sudo apt install -y apt-file
			sudo apt-file update
		fi
	;;

esac



# search for package that contains this file or dir
searchpac() {
name="$1"

	case $PAC in

		"apt")
			line=$( apt-file search $name 2>/dev/null | tail --lines=1 )
			a=(${line//:/ })
			pname="${a[0]}"
			if [[ -n "$pname" ]] ; then
				echo "$pname"
			else
				echo "$name"
			fi
		;;

		"pacman")
			line=$( pacman -F --quiet $name 2>/dev/null | tail --lines=1 )
			pname="$line"
			if [[ -n "$pname" ]] ; then
				echo "$pname"
			else
				echo "$name"
			fi
		;;

		*)
			echo "$name"
		;;

	esac
}

# install package by name
installpac() {
name="$1"

	case $PAC in

		"apt")
			INSTALL="sudo apt install -y $name"
		;;

		"pacman")
			INSTALL="sudo pacman --sync --noconfirm $name"
		;;

		"yum")
			INSTALL="sudo yum install -y $name"
		;;

		"dnf")
			INSTALL="sudo dnf install -y $name"
		;;

		"pkg")
			INSTALL="sudo pkg install $name"
		;;

		"brew")
			INSTALL="sudo brew install $name"
		;;

		*)
			INSTALL="echo require.sh supported package manager not found"
		;;

	esac

	# say what we are going to do
	if ! [[ -n "$REQUIRE_QUIET" ]] ; then
		echo "require.sh is trying to $INSTALL"
	fi
	# try and do it
	if ! [[ -n "$REQUIRE_DRY" ]] ; then
		if [[ -n "$REQUIRE_QUIET" ]] ; then
			$INSTALL >/dev/null 2>&1
		else
			$INSTALL
		fi
	fi


}

# lookup pac names
getpac() {
name="$1"

	if [[ "${name:0:1}" = "/" ]] ; then	# turn a path into a package
		name=$(searchpac $name)
	fi
	
	if [[ ${pmap[$name]} ]] ; then # replace bad package names
		echo ${pmap[$name]}
	else
		echo $name
	fi
}

# install a package if the command does not exist

installcommand() {
name="$1"

	# do nothing if command exists
	if ! [[ -n "$REQUIRE_FORCE" ]] ; then
		if [[ "${name:0:1}" = "/" ]] ; then
			if [[ -e "$name" ]] ; then return 0 ; fi
		else
			if [[ -x "$(command -v $name)" ]] ; then return 0 ; fi
		fi
	fi
	
	# might need to try multiple names so loop over them
	pnames=($(getpac $name))
	for pname in "${pnames[@]}" ; do

		installpac $pname
		
		# exit if command now exists
		if ! [[ -n "$REQUIRE_FORCE" ]] ; then
			if [[ "${name:0:1}" = "/" ]] ; then
				if [[ -e "$name" ]] ; then return 0 ; fi
			else
				if [[ -x "$(command -v $name)" ]] ; then return 0 ; fi
			fi
		fi
	done

}


if [[ -n "$REQUIRE_VERSION" ]] ; then

	cat <<EOF
require.sh VERSION $REQUIRE_VERSION_NUMBER
EOF

elif [[ -n "$REQUIRE_REINSTALL_THIS_SCRIPT" ]] ; then

	sudo cat >/tmp/download-require.sh <<EOF

echo
echo
echo " PLEASE WAIT "
echo
echo
sudo curl https://raw.githubusercontent.com/xriss/require.sh/main/require.sh --output /usr/local/bin/require.sh
sudo chmod +x /usr/local/bin/require.sh
echo
echo
echo " REQUIRE.SH HAS BEEN REINSTALLED WITH LATEST VERSION FROM GITHUB "
echo " PRESS RETURN TO CONTINUE "
echo
echo
/usr/local/bin/require.sh --version
echo
echo

EOF
	sudo chmod +x /tmp/download-require.sh
	/tmp/download-require.sh &
	exit

elif [[ -n "$REQUIRE_HELP" ]] ; then
	cat <<EOF

$0 [--flags] name [name...]

	VERSION $REQUIRE_VERSION_NUMBER

	Attempt to sudo install packages to provide all the given commands using 
	whatever packagemanager we can find. Do nothing if the commands already 
	exist in the path. We assume the package name and command name are the same 
	or will attempt to look up a package if given a full path to a file it 
	would install ( name begins with a / ) possibly we may even have to try a 
	few candidates so just because you see an error from the package manager 
	does not mean that we did not suceed. If all commands/files are available 
	then we will print nothing and do nothing.
	
	Possible --flags are :
	
	--version
		Print version and exit.

	--help
		Print this help text.

	--pac=*
		Force the use of this package manager where * should be one of the 
		following values : apt pacman yum dnf pkg brew

	--dry
		Enable dry run, we will print the commands we want to run but will not 
		run them. NB: We may still try to install dependencies that 
		enable this script to run.

	--quiet
		Do not print the output from the package manager.

	--force
		Do not check if command exists, always try and install each candidate 
		package. Usefull for packages that do not provide a command or file we 
		can easily test for so instead we must require a package name.
		
	--reinstall-this-script
		Reinstall this script from github using curl.

	--no-*
		Disable a previously set flag where * is the flag name. eg --no-dry
		
	These flags can also be set using environment variables prefixed with 
	REQUIRE_ and capitalize flagn name with - replaced with _ eg :
		export REQUIRE_DRY=1
	Would enable the --dry flag but still allow it to be unset with --no-dry

EOF

else

	# process args
	for arg in "${args[@]}" ; do

		installcommand $arg

	done

fi
