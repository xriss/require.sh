cd `dirname $0`

csplit readme.md '/^HELP$/'

cp xx00 readme.md
echo "HELP" >>readme.md
echo "====" >>readme.md
./require.sh --help >>readme.md
rm xx*

