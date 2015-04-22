BASH=/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
# multi monitor instance run...
if [ -f $DIR/.lck ]
then
    exit;
fi
touch $DIR/.lck
for i in df.sh iostat.sh netstat.sh top.sh vnstat.sh
do
    $BASH `printf "%s/%s" $DIR $i`
done
rm $DIR/.lck
