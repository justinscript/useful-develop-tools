#!/bin/bash
#
# @desc: es分页导出json文件
# @author: zxc

page_size=1000
pageno=0
echo "---------------------curl es data start------------------------"
for temp in {1..30478};
do
   from=`expr $pageno \* $page_size`
   echo "size=$page_size,pageno=$pageno"
   echo "http://192.168.1.21:9200/my_index/_search?size=${page_size}&from=${from}"
   curl "http://192.168.1.21:9200/my_index/_search?size=${page_size}&from=${from}" >> /data/zxc/my_index_backup/backup.json
   echo -e >> /data/zxc/my_index_backup/backup.json
   pageno=`expr $pageno + 1`
done
echo "---------------------curl es data done------------------------"

#nohup bash curl_es.sh > /data/zxc/my_index_backup/es_bash.log 2>&1 &