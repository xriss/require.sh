
It makes sense to clean this up and split it off into it's own repo as I keep 
having to do it.

This is intended to be developed by watching it break and then fixing it.

Which means if it breaks for you then you get to fix it.

Probably that just means changing the dictionaries at the top of the require.sh 
script to map to the correct package name for your OS.

By default we just assume that the package name is the same as the command eg:

	require git

Will check if the git command exists and if not will install the git package 
using whatever package manager we can find.


Install by just copying the bash script to /usr/local/bin/require with +x

	sudo wget -O /usr/local/bin/require https://raw.githubusercontent.com/xriss/require.sh/main/require.sh
	sudo chmod +x /usr/local/bin/require

The above will work if you have wget available and then

	require --help
	
Will give you more information about how to use it.

HELP

./require.sh [--flags] name [name...]

	VERSION 0.11

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
	REQUIRE_ and capitalize flagn ame eg :
		export REQUIRE_DRY=1
	Would enable the --dry flag but still allow it to be unset with --no-dry

