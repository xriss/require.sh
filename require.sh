#!/bin/bash

#force a package manager
#export REQUIRE_PAC="apk"



#simeple OS sniff, the first package manager we find is the one to use, if you have multiple package managers then...

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



echo sudo $INSTALL $*






