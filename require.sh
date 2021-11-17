#!/bin/bash


# map special command names to package, otherwise we assume they are the same
declare -A pmap

pmap["test"]="special special2 special3"



declare -A argf
# configure these to not expect values so will not steal the next token
#argf[booleanflag]="1"

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

for key in "${!flags[@]}" ; do
	val=${flags[$key]}

	echo flag $key $val

	case $key in

		"pac")
			export REQUIRE_PAC="$val"
		;;

	esac

done




# the first package manager we find is the one we use or force one with
# env REQUIRE_PAC="apk" or --pac="apk" option

declare -x REQUIRE_PAC

ispac() {
declare -a 'a=('"$1"')'
name=${a[0]}

if [[ -n "$REQUIRE_PAC" ]] ; then
	if [[ "$REQUIRE_PAC" == "$name" ]] ; then return 0 ; fi
	return 1
else
	if [[ -x "$(command -v $name)" ]] ; then return 0 ; fi
	return 1
fi

}

INSTALL="echo require.sh supported package manager not found"
if   ispac apt-get  ; then INSTALL="apt-get install -y"
elif ispac pacman   ; then INSTALL="pacman --sync --noconfirm"
elif ispac apt-cyg  ; then INSTALL="apt-cyg install -y"
elif ispac homebrew ; then INSTALL="echo require.sh homebrew unsuported"
elif ispac macports ; then INSTALL="echo require.sh macports unsuported"
elif ispac yum      ; then INSTALL="echo require.sh yum unsuported"
elif ispac rpm      ; then INSTALL="echo require.sh rpm unsuported"
elif ispac portage  ; then INSTALL="echo require.sh portage unsuported"
elif ispac zypper   ; then INSTALL="echo require.sh zypper unsuported"
elif ispac pkgng    ; then INSTALL="echo require.sh pkgng unsuported"
elif ispac cave     ; then INSTALL="echo require.sh cave unsuported"
elif ispac pkg      ; then INSTALL="echo require.sh pkg unsuported"
elif ispac sun      ; then INSTALL="echo require.sh sun unsuported"
elif ispac apk      ; then INSTALL="echo require.sh apk unsuported"
elif ispac opkg     ; then INSTALL="echo require.sh opkg unsuported"
elif ispac tazpkg   ; then INSTALL="echo require.sh tazpkg unsuported"
elif ispac swupd    ; then INSTALL="echo require.sh swupd unsuported"
elif ispac tlmgr    ; then INSTALL="echo require.sh tlmgr unsuported"
elif ispac conda    ; then INSTALL="echo require.sh conda unsuported"
elif ispac snap     ; then INSTALL="snap install"
fi


# lookup pac names

getpac() {
name="$1"

	if [[ ${pmap[$name]} ]] ; then
		echo ${pmap[$name]}
	else
		echo $name
	fi
}

# install a package if the command does not exist

installpac() {
name="$1"

# do nothing if command exists
if [[ -x "$(command -v $name)" ]] ; then return 0 ; fi

# might need to try multiple names so loop over them
pnames=($(getpac $name))
for pname in "${pnames[@]}" ; do

	# say what we are going to do
	echo sudo $INSTALL $pname
	# try and do it
#	sudo $INSTALL $pname

	# exit if command now exists
	if [[ -x "$(command -v $name)" ]] ; then return 0 ; fi

done

}



# process args

for arg in "${args[@]}" ; do

	installpac $arg

done
