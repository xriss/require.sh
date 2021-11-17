
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
