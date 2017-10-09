BASH=/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"

echo '' ; echo '==================top -b -n 1|head -n 5=================='
top -b -n 1|head -n 5
echo '' ; echo '==================free -m=================='
free -m
echo '' ; echo '==================df -h=================='
df -h
echo '' ; echo '==================iostat=================='
iostat
echo '' ; echo "====netstat -an | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}' | awk '{print $0}'===="
netstat -an | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}' | awk '{print $0}'
echo '' ; echo "==================vnstat -tr 5=================="
vnstat -tr 5
echo '' ; echo '==================ps axu|sort -nr -k 3|head -n 10=================='
ps axu|sort -nr -k 3|head -n 10
echo '' ; echo '==================ps axu|sort -nr -k 4|head -n 10=================='
ps axu|sort -nr -k 4|head -n 10
