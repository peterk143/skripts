#! /bin/bash

## takes a list of files from the localhost,
## tars them into a tmp dir, rsyncs them
## to various machines, untars the archive on
## the remote, places the files in their correct
## location, cleans up the mess, and outputs
## the elapsed time in MM:SS

## MUST be ran from a machine with routes to all hosts

MACHINES="dmzshell001"
# dmzshell002
# dmzshell003
# dmzshell004
# dmzlegacyshell001
# dmzlegacyshell002
# nagios001
# nagios002
# tnode001
# fileserver001
# fileserver002
# fileserver003
# fileserver004
# fileserver005
# fileserver006
# imageserver001
# imageserver002"

FILES=".ssh/authorized_keys
.ssh/config
.bashrc
.bash_aliases
.emacs
.emacs.d/"

TMP=`mktemp -d`
ZIP=/tmp/asdf.tar.gz
RSYNC_OPTS="rsync -az"
CLEAN="rm -rf ${TMP} ${ZIP}"
UNTAR="tar -xzPf ${ZIP} && \
mkdir -p /home/pkirkpat/.ssh"
MOVE="mv ${TMP}/.bashrc /home/pkirkpat/ && \
mv ${TMP}/config /home/pkirkpat/.ssh/ && \
mv ${TMP}/.bash_aliases /home/pkirkpat/ && \
mv ${TMP}/authorized_keys /home/pkirkpat/.ssh/
mv ${TMP}/.emacs /home/pkirkpat/ && \
rsync -a ${TMP}/.emacs.d /home/pkirkpat/"
START="$(date +%s)"

## ssh key check
CHECK=`ssh-add -l`
if [ $? -eq 0 ]
then
    ## dotfile check
    if [ -d /cloudhome/pkirkpat/dotfiles ]
    then
	DOTS="/cloudhome/pkirkpat/dotfiles"
    else
	echo "you need the dotfile dir, br0"
	exit 0
    fi

    ## file prep
    mkdir -p ${TMP}
    for file in ${FILES}
    do
	cp -R ${DOTS}/${file} ${TMP}
    done

    ## compression
    tar -czPf ${ZIP} ${TMP}
    #tar -cPf - ${TMP} |pv -N tar\'n -s $(du -sb ${TMP} |awk '{print $1}') |gzip > ${ZIP}

    ## remote magic
    SSHELL="ssh -p 20110"
    for host in ${MACHINES}
    do
    	case "$host" in
    	    dmzshell*) ${RSYNC_OPTS} -e "${SSHELL}" ${ZIP} ${host}.lcsee.wvu.edu:/tmp 
    		${SSHELL} ${host}.lcsee.wvu.edu "${UNTAR} && ${MOVE} && ${CLEAN}"
    		;;
    	    *) ${RSYNC_OPTS} ${ZIP} ${host}.lcsee.wvu.edu:/tmp 
    		${host}.lcsee.wvu.edu "${UNTAR} && ${MOVE} && ${CLEAN}"
    		;;
    	esac
    done

    `${CLEAN}`
    
    ## elapsed time
    FIN="$(date +%s)"
    TIME="$(expr ${FIN} - ${START})"
    echo `date -u -d @${TIME} +"%M:%S"`" elapsed"

    echo "allGood!"
else
    echo "do you even keys, br0?"
    exit 1
fi
