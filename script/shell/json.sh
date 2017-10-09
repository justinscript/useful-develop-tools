#!/bin/bash
#
# @desc: json格式数据提取,中间多个空格也可以匹配
# @author: zxc

awk 'BEGIN{n=split("model,brand",fields,",")}{ret="";line=$0; for(i=1;i<=n;i++) { FS="\""fields[i]"\" *: *"; $0=line; f=$2; FS=" *, *\"| *}";$0=f;val[i]=$1; };  for(i=1;i<=n;i++) { if ( ret =="" ) ret=val[i]; else ret=ret","val[i];}print ret }'|sed "s/\"//g" 