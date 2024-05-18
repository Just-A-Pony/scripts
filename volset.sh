#!/bin/bash
if [ -z $1 ];then exit
fi
if [ $1 = 'up' ];then
    if [ -z $2 ];then
    amixer -M set Master 10%+
else
    amixer -M set Master ${2}%+
fi
fi
if [ $1 = 'down' ] ;then
    if [ -z $2 ];then
    amixer -M set Master 10%-
else
    amixer -M set Master ${2}%-
    fi
fi
