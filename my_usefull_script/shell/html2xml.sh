#!/bin/bash
# by zxc
# 将html处理成xml的shell

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

#Begin
cd /xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
wget --output-document=hist.tmp -q http://xxxxxxxxxxxxxxxxxxxxxxxxxx > /dev/null
echo -e "\n<android>" > hist.xml
fgrep "hh14" hist.tmp | sed 's/.*a href=\"\.\([^"]*\).*\(2011.*0\).*/<item><url>http:\/\/xxxxxxxxxxxxxxxxx\1<\/url>\n<time>\2<\/time><\/item>/' | awk 'NR%3==1' | sed 's/></>\n</' >> hist.xml
echo "</android>" >> hist.xml
rm -f hist.tmp

HISTORYS=`grep "url" hist.xml | sed 's/<[^<>]*>//g'`
i=0
for hist in $HISTORYS
do
    wget --output-document=$i.tmp -q $hist >/dev/null
    echo -e "

\n<android>" > $i.xml
    egrep "<[^/>]*>([^<]*)</[FS]" $i.tmp | sed '1,6d' > $i.tmp.tmp
    linenu=0
    while read line
    do
        mod=$(($linenu%5))
        case $mod in
        0)
            echo $line | sed 's/.*<[^\/>]*>\([^<]*\)<\/[FS].*/<item>\n<city>\1<\/city>/' >> $i.xml
            ;;
        1)
            echo $line | sed 's/.*<[^\/>]*>\([^<]*\)<\/[FS].*/<range>\1<\/range>/' >> $i.xml
            ;;
        2)
            echo $line | sed 's/.*<[^\/>]*>\([^<]*\)<\/[FS].*/<average>\1<\/average>/' >> $i.xml
            ;;
        3)
            echo $line | sed 's/.*<[^\/>]*>\([^<]*\)<\/[FS].*/<standard>\1<\/standard>/' >> $i.xml
            ;;
        4)
            echo $line | sed 's/.*<[^\/>]*>\([^<]*\)<\/[FS].*/<result>\1<\/result>\n<\/item>/' >> $i.xml
            ;;
        esac
        linenu=$(($linenu+1))
    done < $i.tmp.tmp
    echo "</android>" >> $i.xml
    rm -f $i.tmp.tmp $i.tmp
    i=$(($i+1))
done
#End