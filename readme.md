
It makes sense to clean this up and split it off into it's own repo as I keep having to do it.

This is intended to be developed by watching it break and then fixing it.

Which means if it breaks for you then you get to fix it.

Probably that just means changing the dictionaries at the top of the require.sh script to map to the correct package name for your OS.

By default we assume that the package name is the same as the command name eg

  require git

Will just install the git package using whatever package manager make sense for this OS.
