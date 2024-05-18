#!/bin/bash
MIRROR_DIR=/media/mirrors
SNAPDIR=${MIRROR_DIR}-snap
checkrepos(){
    for repo in "${MIRROR_DIR}"/*;do
        systemctl show --no-pager "${repo##*/}"-mirror-sync.service|grep 'ActiveState=active' && echo "Mirror is Syncing!" && exit 1 
    done
}
mirrorsnapshot(){
    for repo in "${MIRROR_DIR}"/*;do
       if [ -d "$SNAPDIR"/"${repo##*/}" ];then
           btrfs subvolume delete "$SNAPDIR"/"${repo##*/}" || eval $(echo "Failed To Delete Subvolume" && exit 1)
       fi
       btrfs subvolume snapshot -r "$repo" "$SNAPDIR"/"${repo##*/}" || eval $(echo "Failed To Create Subvolume!" && exit 1)
   done
}
resumesync(){
    for repo in "${MIRROR_DIR}"/*;do
        systemctl start "${repo##*/}"-mirror-sync.timer
    done
}
checktime(){
    SNAP_TIME=$(stat $SNAPDIR -c%y)
    SNAP_TIMESTAMP=$(stat $SNAPDIR -c%Y)
    TIMEDIFF=`expr $(date +%s) - ${SNAP_TIMESTAMP}`
    printf 'Last repo snap time: %s,\n' "${SNAP_TIME}"
    echo "It has been $(date -ud@$TIMEDIFF +"$(( ${TIMEDIFF}/3600/24 )) days %H hours %M mins since your last update.")"
}
if [ "$1" = "--checktime" ] || [ "$1" = "-c" ];then
    checktime;exit 0
fi
if [ "$(id -u)" -ne 0 ];then
    printf "You must run this as root\n";exit
fi
if [ -z "$1" ];then
    checkrepos
    for repo in "${MIRROR_DIR}"/*;do 
        systemctl stop "${repo##*/}"-mirror-sync.timer || exit 1
    done
    mirrorsnapshot
else
    printf "Unrecognized option: \"%s\"\n" $1
fi
echo 'Running Pacman...'
sleep 1
if ! pacman -Syu ; then
    printf 'ERROR! Pacman Failed!'
else
    resumesync
fi
