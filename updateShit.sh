#! /bin/bash

MACHINES="dmzshell001
dmzshell002
dmzshell003
dmzshell004
dmzlegacyshell001
dmzlegacyshell002
nagios001
nagios002
tnode001"

FILES="/home/pkirkpat/.bashrc
/cloudhome/pkirkpat/.bash_aliases
/home/pkirkpat/.ssh/authorized_keys
/home/pkirkpat/.ssh/config"

RSYNC_OPTS="rsync -avz --progress"
CHECK=`ssh-add -l`

if [ $? -eq 0 ]
then
    for host in ${MACHINES}
    do
	echo ${host}
	for each in ${FILES}
	do
	    case "$host" in
		dmzshell*) ${RSYNC_OPTS} -e "ssh -p 20110" ${each} ${host}.lcsee.wvu.edu:~/ ;;
		*) ${RSYNC_OPTS} ${each} ${host}.lcsee.wvu.edu:~/ ;;
	    esac
	done
    done

    SSH_OPTS="ssh ${h}"
    RMT_CMD="mkdir -p ~/.ssh && mv ~/authorized_keys ~/config ~/.ssh"
    for h in ${MACHINES}
    do
	case "$h" in
	    dmzshell*) ssh -p 20110 ${h} "${RMT_CMD}" ;;
	    *) ssh ${h} ${RMT_CMD} ;;
	esac
    done

    echo "allGood!"
else
    echo "do you even keys br0?"
fi
