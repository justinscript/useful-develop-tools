top -b -n 1|egrep '^top|^Tasks|^Cpu|^Mem|^Swap' | awk '{print "top: "$0}'
