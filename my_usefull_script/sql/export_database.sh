#!/bin/bash


database='porsche'

for table in `mysql -h 192.168.1.170 -u dev '-pdev1234' porsche -Bse 'show tables'`
do
    if [ ! "$table" == 's_keyword' ]; then
        continue
    fi
    for i in {0..10000}
    do
        from=`echo "5000*$i"|bc`
        to=`echo "5000*($i+1)"|bc`
        export_file="$database.$table.$from.$to"
        mysqldump -h 192.168.1.170 -u dev '-pdev1234' --databases $database --tables $table --order-by-primary --where="id >= $from and id < $to" > ${export_file}
	count=`grep '^INSERT INTO ' ${export_file} | wc -l` 
        echo $i.$from.$to.${export_file}.$count
        if [ $count -le 0 ]; then
            rm "${export_file}"
            break
        fi
        echo "export to file $export_file"
    done
done

