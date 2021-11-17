
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
