REQUIRE.SH
==========

This bash (version 4+) script attempts to install packages, probably 
for a command, in a generic way across multiple package managers.

This is intended to be used as a bit of boiler plate at the top of 
scripts to make sure that the rest of the script will have the required 
tools. So something like this will install require.sh and then install 
ffmpeg, exiftool and uvx. If these tools are already available (IE not 
the first run or user has previously installed them) then the script 
will not do anything and be silent. The rest of the script can then use 
these tools and this should work across multiple distros and package 
managers.

	# first install a require script that should work on multiple flavors of linux
	if ! [[ -x "$(command -v require.sh)" ]] ; then
		echo " we need sudo to install require.sh to /usr/local/bin from https://github.com/xriss/require.sh "
		echo " if this scares you then add a dummy require.sh and provide the dependencies yourself "
		sudo wget -O /usr/local/bin/require.sh https://raw.githubusercontent.com/xriss/require.sh/main/require.sh
		sudo chmod +x /usr/local/bin/require.sh
	fi
	require.sh ffmpeg
	require.sh exiftool
	require.sh uvx
	
If you wish to run a script with this sort boiler plate code but do not 
trust require.sh then you can fake around it like so.

	bash -c 'function require.sh { echo "REQUIRE.SH" "$@"; } ; export -f "require.sh" ; ./nameofscript '

Where ./nameofscript is the script you want to run with require.sh 
disabled and replaced with an echo command. But if you care about that 
sort of thing you should be able to work that out for yourself and of 
course you should provide the dependencies manually.

This is obviously all a little bit dangerous but the alternative is 
broken confusing dependencies for dumb users. Mayhaps something like 
this with a generic interface and a generic name should be a basic part 
of all package managers...

How else are we supposed to enjoy DLL hell?

We are by design. intentionally dumb, so as default we just assume that 
the package name is the same as the command. This is mostly true.

	require.sh git

Will check if the git command exists and if not will install a package named 
git using whatever package manager we can find.

If however you give a fullpath, something beginning with /

	require.sh /usr/include/libudev.h

Then we will check if this file exists and if not attempt to find a package 
that would install that exact file. Include files are a good pick as it 
should install the dev package and the library and they should be a more 
generic path than .so files.

This is actually how some package managers, such as dnf, already work but we need
to do a bit more for apt, pacman etc.


DEVELOPMENT
===========

This is intended to be developed by watching it break and then fixing it. Which 
means if it breaks for you then you get to fix it :)

Probably that just means changing the dictionaries at the top of the require.sh 
script to fix a package name or adjusting package manager parameters.


INSTALL
=======

You can install require.sh by copying the bash script to /usr/local/bin/require 
with +x So this snippet will download the latest version from github.

	sudo curl https://raw.githubusercontent.com/xriss/require.sh/main/require.sh --output /usr/local/bin/require.sh
	sudo chmod +x /usr/local/bin/require.sh

and then

	require.sh --help
	
Will give you more information about how to use it and the output is what you 
will see below.

HELP
====

./require.sh [--flags] name [name...]

	VERSION 0.124

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

