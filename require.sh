#!/bin/bash


#simeple OS sniff, the first package manager we find is the one to use, if you have multiple package managers then...

INSTALL="echo require.sh does not know how to install"

#I guess we should try all of these

#	apt-get			on Debian, Ubuntu, etc.
#	pacman			on Arch Linux-based systems, ArchBang, Manjaro, etc.
#	apt-cyg			on Cygwin (via apt-cyg)
#	homebrew		on Mac OS X
#	macports		on Mac OS X
#	yum/rpm			by Redhat, CentOS, Fedora, Oracle Linux, etc.
#	portage			by Gentoo
#	zypper			by OpenSUSE
#	pkgng			by FreeBSD
#	cave			by Exherbo Linux
#	pkg				tools by OpenBSD
#	sun				tools by Solaris(SunOS)
#	apk				by Alpine Linux
#	opkg			by OpenWrt
#	tazpkg			by SliTaz Linux
#	swupd			by Clear Linux
#	tlmgr			by TeX Live
#	conda			by Conda




if   command -v apt-get ; then


INSTALL="sudo apt-get install -y"


elif command -v pacman ; then


INSTALL="sudo pacman --sync --noconfirm"


elif command -v snap ; then


INSTALL="sudo snap install"


fi



echo $INSTALL $*






