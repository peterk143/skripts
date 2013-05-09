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

SSH="-e \"ssh -p 20110\""
OPTS="-avz --progress"

CHECK=`ssh-add -l`

if [ $? -eq 0 ]
then
    for host in ${MACHINES}
    do
	echo ${host}
	for each in ${FILES}
	do
	    case "$host" in
		dmzshell*) COMMAND="${SSH} ${each} ${host}.lcsee.wvu.edu:~/" ;;
		*) COMMAND="${each} ${host}.lcsee.wvu.edu:~/" ;;
	    esac

	    rsync ${OPTS} ${COMMAND}
	done
    done

    echo "allGood!"
else
    echo "do you even keys br0?"
fi
