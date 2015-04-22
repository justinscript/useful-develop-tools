while read file_path;
do
    if [ -f $file_path ]; then
        file_type=`file $file_path | awk '{print $2}'`
        if [ $file_type == 'JPEG' ]; then
            quality=`identify -verbose $file_path |grep Quality|awk '{print $2}'`
            from_size=`du -sh $file_path | awk '{print $1}'`
            if [ ! -z "$quality" ] && [ $quality -gt 80 ]; then
                convert  -quality 80 $file_path "${file_path}.n"
                mv "${file_path}.n" $file_path
                to_size=`du -sh $file_path | awk '{print $1}'`
                echo "$file_path from $quality to 80, size $from_size to $to_size" >> log
            fi
        fi
    fi
done < allfile
