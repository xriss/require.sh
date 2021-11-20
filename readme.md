REQUIRE.SH
==========

This bash script attempts to install packages, probably for a command, in a 
generic way across multiple package managers.

By default we just assume that the package name is the same as the command

	require git

Will check if the git command exists and if not will install a package named 
git using whatever package manager we can find.

If however you give a fullpath, something beginning with /

	require /usr/include/libudev.h

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

	sudo wget -O /usr/local/bin/require https://raw.githubusercontent.com/xriss/require.sh/main/require.sh
	sudo chmod +x /usr/local/bin/require

and then

	require --help
	
Will give you more information about how to use it and the output is what you 
will see below.

HELP
====

./require.sh [--flags] name [name...]

	VERSION 0.112

	Attempt to sudo install packages to provide all the given commands using 
	whatever packagemanager we can find. Do nothing if the commands already 
	exist in the path. We assume the package name and command name are the same 
	but also have a list of exceptions and alternative names we can try. We may 
	need to try a few candidates so just because you see an error does not mean 
	that we did not suceed.
	
	Possible --flags are :
	
	--version
		Print version and exit.

	--help
		Print this help text.

	--pac=*
		Force the use of this package manager where * should be one of the 
		following values : apt pacman yum dnf pkg

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
	REQUIRE_ and capitalize flagn ame eg :
		export REQUIRE_DRY=1
	Would enable the --dry flag but still allow it to be unset with --no-dry

