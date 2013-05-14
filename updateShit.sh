#! /bin/bash

MACHINES="dmzshell001"
# dmzshell002
# dmzshell003
# dmzshell004
# dmzlegacyshell001
# dmzlegacyshell002
# nagios001
# nagios002
# tnode001"

# file prep
mkdir -p ~/temp
cp ~/.ssh/{authorized_keys,config} /cloudhome/pkirkpat/.bash_aliases ~/temp
gzip -r ~/temp > temp.gz && rm -rf ~/temp

RSYNC_OPTS="rsync -avz --progress"
TEMP="~/temp.gz"

# ssh key check
CHECK=`ssh-add -l`
if [ $? -eq 0 ]
then
    # file transpo
    for host in ${MACHINES}
    do
	echo ${host}
	case "$host" in
	    dmzshell*) ${RSYNC_OPTS} -e "ssh -p 20110" ${TEMP} ${host}.lcsee.wvu.edu:~/ ;;
	    *) ${RSYNC_OPTS} ${TEMP} ${host}.lcsee.wvu.edu:~/ ;;
	esac
    done

    # put files into place
    RMT_CMD="gunzip ~/temp.gz && mkdir -p ~/.ssh && mv ~/temp/authorized_keys ~/temp/config ~/.ssh"
    for h in ${MACHINES}
    do
	case "$h" in
	    dmzshell*) ssh -p 20110 ${h} "${RMT_CMD}" ;;
	    *) ssh ${h} "${RMT_CMD}" ;;
	esac
    done

    # clean up temps
    CLEAN="rm -rf ~/temp && rm ~/temp.gz"
    for x in ${MACHINES}
    do
	case "$x" in
	    dmzshell*) ssh -p 20110 ${x} "${CLEAN}" ;;
	    *) ssh ${x} "${CLEAN}" ;;
	esac
    done
    eval ${CLEAN}

    echo "allGood!"
else
    echo "do you even keys br0?"
fi
