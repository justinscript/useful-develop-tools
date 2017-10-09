while read file_path;
do
    new_file_path=`echo $file_path|perl -pe 's/.jpg$/_900.jpg/'`
    if [ -f $file_path ] && [ ! -e $new_file_path ]; then
        file_type=`file $file_path | awk '{print $2}'`
        if [ $file_type == 'JPEG' ]; then
            geometry_x=`identify -verbose $file_path|grep Geometry:|awk '{print $2}'|awk -F x '{print $1}'`
            from_size=`du -s $file_path | awk '{print $1}'`
            if [ ! -z "$geometry_x" ] && [ $geometry_x -gt 900 ]; then
                convert -resize 900 $file_path "${file_path}.n"
                to_size=`du -s ${file_path}.n | awk '{print $1}'`
                if [ $from_size -gt $to_size ]; then
                    mv "${file_path}.n" $new_file_path
                    echo "$file_path from $geometry_x to 900, size $from_size to $to_size" >> log
                fi
                rm -rf "${file_path}.n"
            fi
        fi
        if [ ! -e $new_file_path ]; then
            cp $file_path $new_file_path
        fi
    fi
done < allfile
