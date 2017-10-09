domain="http://pic.yupoo.com/"
domina_len=${#domain}
let domina_len=domina_len+1
while read line
do
    line=`echo -n $line|perl -pe 's/\s+//g'`
    if [ "$line" != "" ]; then
        path=`echo $line|cut -c $domina_len-`
        absdir="/msun/static/nfs/img/"`dirname $path`
        abspath="/msun/static/nfs/img/$path"
        if [ ! -e $absdir ]; then
            mkdir -p $absdir
        fi
        curl $line > $abspath
    fi
done < pic.url
