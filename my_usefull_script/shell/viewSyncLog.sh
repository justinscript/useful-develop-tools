#!/usr/bin/env bash
if [ -z "$1" ]
then
    echo "required to operate the file is empty"
    exit 2   
fi
 
if [ ! -e "$1" ]||[ -d "$1" ]
then 
    echo "need to manipulate the file does not exist"
    exit 2
fi

file=$1
currentPath=`pwd`
if [ ! -e "$currentPath/$1" ]||[ -d "$currentPath/$1" ]
then
    echo "Need to deal with the files in the current directory does not exist"
    echo "start looking for this file:$1"
    file=`find . -name "$1" 2>/dev/null|sed -n '1p'`
    if [ -z "$file" ]
    then
       file=`find ~ -name "$1" 2>/dev/null|sed -n '1p'`
    fi
fi

if [ ! -e "$file" ]||[ -d "$file" ]
then
    echo "need to manipulate the file does not exist"
    exit 2
fi

if [ -n "$2" ]&&([ $2 -lt 0 ]||[ $2 -gt 23 ])
then
    echo "find the time can not be less than 0, greater than 23"
    exit 2
fi

function wcLog()
 {
   start=0$2:00:00
   end=0$2:59:59
   if [ $2 -ge 10 ]
   then
     {
       start=$2:00:00
       end=$2:59:59
     }
   fi
   echo $start-$end: "service.ItemDataService - ItemDataService selectModified";
   grep "service.ItemDataService - ItemDataService selectModified:" $1|awk -F '[ ,]' '{if($2>="'$start'" && $2<="'$end'") m++} END{print m}'
 }

if [ -n "$2" ]
then
    wcLog $file $2;
    exit 0
fi

for time in $(seq 0 23)
 do
   wcLog $file $time;
 done
