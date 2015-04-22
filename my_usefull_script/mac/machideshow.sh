#! /bin/bash
# by zxc
# mac系统显示隐藏文件切换脚本

if [ $# -lt 1 ];then
    echo "usage hideshow.sh hide|show"
    exit
fi
case $1 in
show)
    if [ `defaults read com.apple.finder AppleShowAllFiles` = "1" ];then
        echo "Hide files already been shown, did nothing!"
        exit
    else
        defaults write com.apple.finder AppleShowAllFiles -bool true
        killall Finder
        exit
    fi
    ;;
hide)
    if [ `defaults read com.apple.finder AppleShowAllFiles` = "0" ];then
        echo "Dot Files already been hided, did nothing!"
        exit
    else
        defaults write com.apple.finder AppleShowAllFiles -bool false
        killall Finder
        exit
    fi
    ;;
*)
    echo "usage hideshow.sh hide|show"
    ;;
esac