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

PORT="-P 20110"
IDENT="/home/pkirkpat/.ssh/identity.bbs"

for host in ${MACHINES}
do
    echo ${host}
    for each in ${FILES}
    do
	case "$host" in
	    dmzshell*) COMMAND="scp ${PORT} ${IDENT} ${each} ${host}.lcsee.wvu.edu:~/" ;;
	    *) COMMAND="scp ${IDENT} ${each} ${host}.lcsee.wvu.edu:~/" ;;
	esac

	eval `${COMMAND}`
    done
done

echo "allGood!"