#!/bin/bash

trap ' trap - INT ;  kill -s INT "$$" ' INT

REQUIRE_VERSION="0.1"

# map special command names to package, otherwise we assume they are the same
declare -A pmap

# I guess we should generate this from a better database...

pmap["build-essential"]="build-essential base-devel"


declare -A argf
# configure these flags to not expect values so will not steal the next token
argf["help"]="1"
argf["dry"]="1"
argf["quiet"]="1"
argf["force"]="1"
argf["reinstall-this-script"]="1"

# fill in these arrays as output
declare -A args
declare -A flags
mode=names
for arg in "$@" ; do

	case $mode in

		"set")
			val="$arg"
			flags["$set"]="$val"
			mode=names
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
					if [[ ${argf[$set]} ]] ; then # no val expected
						flags["$set"]="1"
					else
						flags["$set"]="1" # temporary value
						mode=set
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

	case $key in

		"pac")
			export REQUIRE_PAC="$val"
		;;

		"dry")
			export REQUIRE_DRY="$val"
		;;

		"quiet")
			export REQUIRE_QUIET="$val"
		;;

		"force")
			export REQUIRE_FORCE="$val"
		;;

		"help")
			export REQUIRE_HELP="$val"
		;;

		"reinstall-this-script")
			export REQUIRE_REINSTALL_THIS_SCRIPT="$val"
		;;


		*)
			echo "unknown flag $key=$val"
		;;

	esac

done




# the first package manager we find is the one we use or force one with
# env REQUIRE_PAC="apk" or --pac="apk" option

declare -x REQUIRE_PAC

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
elif ispac yum     ; then PAC="yum"
fi


#INSTALL="echo require.sh supported package manager not found"
#if   ispac apt-get ; then INSTALL="apt-get install -y"
#elif ispac pacman  ; then INSTALL="pacman --sync --noconfirm"
#elif ispac yum     ; then INSTALL="yum install"
#elif ispac pkg     ; then INSTALL="pkg install"
#elif ispac dnf     ; then INSTALL="dnf install"
#elif ispac emerge  ; then INSTALL="emerge"
#elif ispac zypper  ; then INSTALL="zypper install"
#elif ispac swupd   ; then INSTALL="swupd bundle-add"
#elif ispac opkg    ; then INSTALL="opkg install"
#elif ispac tazpkg  ; then INSTALL="tazpkg get-install"
#elif ispac tlmgr   ; then INSTALL="tlmgr install"
#elif ispac conda   ; then INSTALL="conda install"
#elif ispac apt-cyg ; then INSTALL="apt-cyg install -y"
#elif ispac brew    ; then INSTALL="brew cask install"
#elif ispac port    ; then INSTALL="port install"
#elif ispac snap    ; then INSTALL="snap install"
#fi


# search for package that contains this file or dir
searchpac() {
name="$1"

	case $PAC in

		"apt")
			line=$( dpkg -S $name | tail --lines=1 )
			a=(${line//:/ })
			pname="${a[0]}"
			echo "$pname"
		;;

		"pacman")
			echo "$name"
		;;

		"yum")
			echo "$name"
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
			INSTALL="echo require.sh supported package manager not found"
		;;

		"yum")
			INSTALL="echo require.sh supported package manager not found"
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
			$INSTALL > /dev/null 2>&1
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


if [[ -n "$REQUIRE_REINSTALL_THIS_SCRIPT" ]] ; then

	sudo cat >/tmp/download-require.sh <<EOF

sudo wget -O /usr/local/bin/require https://raw.githubusercontent.com/xriss/require.sh/main/require.sh
sudo chmod +x /usr/local/bin/require

EOF
	sudo chmod +x /tmp/download-require.sh
	/tmp/download-require.sh

elif [[ -n "$REQUIRE_HELP" ]] ; then

	cat <<EOF

require [--flags] name [name...]

	VERSION $REQUIRE_VERSION

	Attempt to sudo install packages to provide all the given commands using 
	whatever packagemanager we can find. Do nothing if the commands already 
	exist in the path. We assume the package name and command name are the same 
	but also have a list of exceptions and alternative names we can try. We may 
	need to try a few candidates so just because you see an error does not mean 
	that we did not suceed.
	
	Possible --flags are :
	
	--help
		Print this help text.

	--pac=*
		Force the use of this package manager where * should be one of the 
		following values : apt pacman yum   

	--dry
		Enable dry run, we will print the commands we want to run but will not 
		run them.

	--quiet
		Do not print the output from the package manager.

	--force
		Do not check if command exists, always try and install each candidate 
		package. Usefull for packages that do not provide a command or file we 
		can easily test for.
		
	--reinstall-this-script
		Reinstall this script from github using wget.

	--no-*
		Disable a previously set flag where * is the flag name. eg --no-dry
		
	These flags can also be set using environment variables prefixed with 
	REQUIRE_ and capitalize eg :
		export REQUIRE_DRY=1
	Would enable the --dry flag but still allow it to be unset with --no-dry

EOF

else

	# process args
	for arg in "${args[@]}" ; do

		installcommand $arg

	done

fi
