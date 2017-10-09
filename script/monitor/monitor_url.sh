#!/bin/bash
total_request=0
failed_request=0
total_request_time=0
failed_divi_total_request=0
avg_request_time=0
timeout=2000000000
#url="http://msun.com/coordinations.htm"
#url="http://220.181.111.85/index.html"
#url="http://122.193.22.121/home.htm"
#url="http://122.193.22.121/home.htm"
url="http://img.msunimg.com/33/04/3304.jpg"
#url="http://122.193.22.122/img/site/rhine/logo.png"
echo "monitor ${url}"
for i in {1..100000}
do
    time_start=`date +"%s%N"`
    curl -sO ${url}
    time_end=`date +"%s%N"`
    let time_co=${time_end}-${time_start}
    if [ ${time_co} -gt ${timeout} ]; then
        let failed_request=${failed_request}+1
    fi
    total_request_time=`echo ${total_request_time}+${time_co}|bc`
    total_request=`echo ${total_request}+1|bc`
    failed_percentage=`echo "scale=2; (${failed_request}*100)/${total_request}"|bc`
    avg_request_time=`echo "scale=2; ${total_request_time}/(${total_request}*1000000)"|bc`
    echo -ne "  total_request: ${total_request} failed_request: ${failed_request} failed_percentage: ${failed_percentage}% avg_request_time: ${avg_request_time}ms\r"
    sleep 1
done

