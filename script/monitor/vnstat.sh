vnstat -tr 5 | egrep 'rx|tx' | awk '{print "vns: "$0}'
