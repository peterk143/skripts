#! /bin/bash

## takes a list of files from the localhost,
## tars them into a tmp dir, rsyncs them
## to various machines, untars the archive on
## the remote, places the files in their correct
## location, cleans up the mess, and outputs
## the elapsed time in MM:SS

## MUST be ran from a machine with routes to all hosts

MACHINES="dmzshell001
dmzshell002
dmzshell003
dmzshell004
dmzlegacyshell001
dmzlegacyshell002
nagios001
nagios002
tnode001
fileserver001
fileserver002
fileserver003
fileserver004
fileserver005
fileserver006
imageserver001
imageserver002"

FILES=".ssh/authorized_keys
.ssh/config
.bashrc
.profile
.bash_aliases
.emacs
.emacs.d/"

TMP=`mktemp -d`
ZIP=/tmp/asdf.tar.gz
RSYNC_OPTS="rsync -az"
UNTAR="tar -xzmPf ${ZIP} && \
mkdir -p /home/$USER/.ssh"
CLEAN="rm -rf ${TMP} ${ZIP}"
MOVE="mv ${TMP}/.bashrc /home/$USER/ && \
mv ${TMP}/config /home/$USER/.ssh/ && \
mv ${TMP}/.bash_aliases /home/$USER/ && \
mv ${TMP}/authorized_keys /home/$USER/.ssh/ && \
mv ${TMP}/.emacs /home/$USER/ && \
mv ${TMP}/.profile /home/$USER/ && \
rsync -a ${TMP}/.emacs.d /home/$USER/"
START="$(date +%s)"

## ssh key check
CHECK=`ssh-add -l`
if [ $? -eq 0 ]
then
    ## dotfile check
    if [ -d /cloudhome/$USER/dotfiles ]
    then
	DOTS="/cloudhome/$USER/dotfiles"
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

    ## remote magic
    SSHELL="ssh -o"
    KEYCHECK="StrictHostKeyChecking no"
    for host in ${MACHINES}
    do
    	case "$host" in
    	    dmzshell*) ${RSYNC_OPTS} -e "${SSHELL} \"${KEYCHECK}\" -p 20110" ${ZIP} ${host}.lcsee.wvu.edu:/tmp 
		${SSHELL} "${KEYCHECK}" -p 20110 ${host}.lcsee.wvu.edu "${UNTAR} && ${MOVE} && ${CLEAN}"
		echo ${host}
		;;
    	    *) ${RSYNC_OPTS} ${ZIP} ${host}.lcsee.wvu.edu:/tmp 
    		${SSHELL} "${KEYCHECK}" ${host}.lcsee.wvu.edu "${UNTAR} && ${MOVE} && ${CLEAN}"
		echo ${host}
    		;;
    	esac
    done

    `${CLEAN}`
    
    ## elapsed time
    FIN="$(date +%s)"
    TIME="$(expr ${FIN} - ${START})"
    echo `date -u -d @${TIME} +"%M:%S"`" elapsed"
    echo "crescent fresh!"
else
    echo "do you even keys, br0?"
    exit 1
fi
