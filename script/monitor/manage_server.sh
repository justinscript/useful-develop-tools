SCRIPT_NAME="manage_server.py"
EXIT_FILE_NAME=".exit_hifile"
LOG_NAME="../temp/log"
DIR="$( cd "$( dirname "$0" )" && pwd )"

SCRIPT_PATH=`printf "%s/%s" $DIR $SCRIPT_NAME`
EXIT_FILE_PATH=`printf "%s/%s" $DIR $EXIT_FILE_NAME`
LOG_NAME_PATH=`printf "%s/%s" $DIR $LOG_NAME`

function start {
    pyps=`ps axu | grep '/msun/deploy/bin/manage_server.py' | grep -v grep`
    if [ -z "$pyps" ]; then
        /usr/bin/nohup /usr/bin/python $SCRIPT_PATH 1>$LOG_NAME_PATH 2>&1 &
    fi
}
function stop {
    pyps=`ps axu | grep '/msun/deploy/bin/manage_server.py' | grep -v grep`
    if [ ! -z "$pyps" ]; then
        echo $EXIT_FILE_PATH
        touch $EXIT_FILE_PATH
        while [ -f $EXIT_FILE_PATH ]
        do
            echo 'wait... for exit file remove'
            sleep 1
        done
    fi
}

COMMAND="$1"
case $COMMAND in
start)
    start
;;
stop)
    stop
;;
restart)
    stop
    start
;;
*)
    echo 'usage: start|stop|restart'
;;
esac
