#! /bin/bash

## takes a list of files from the localhost,
## tars them into a tmp dir, rsyncs them
## to various machines, untars the archive on
## the remote, places the files in their correct
## location, cleans up the mess, and outputs
## the elapsed time in MM:SS

## MUST be ran from a machine with routes to all hosts

bold() {
    echo -e "\033[1m${1}\033[0m"
}

usage() {
cat <<EOF

  Usage: ${0} [--servers | --desktops] [-l `bold \<hosts\>` | --list `bold \<hosts\>`]

    `bold -l`|`bold --list` hosts          specify which machines to update

    `bold -s`|`bold --servers`             update all servers
    `bold -d`|`bold --desktops`            update all desktops

    `bold --list-servers`           list all available servers
    `bold --list-desktops`          list all available desktops

        `bold Example`:
            ${0} --desktops
EOF
}

if [ $# -eq 0 ]; then
    usage
    exit 0
elif [ "${1}" = "--help" -o "${1}" = "-h" ]; then
    usage
    exit 0
fi

MACHINES="nagios001
nagios002
dmzshell001
dmzshell002
dmzshell003
dmzshell004
imageserver001
imageserver002
dmzlegacyshell001
dmzlegacyshell002
tnode001
fileserver001
fileserver002
fileserver003
fileserver004
fileserver005
fileserver006"

DESKTOPS="cseesystems01
cseesystems03
cseesystems04
cseesystems05
cseesystems07
cseesystems08
cseesystems09"

if [ "${1}" == "--list-servers" ]; then
    for node in ${MACHINES}; do
	echo "   " ${node}
    done
    exit 0
elif [ "${1}" == "--list-desktops" ]; then
    for instance in ${DESKTOPS}; do
	echo "   " ${instance}
    done
    exit 0
fi

FILES=".ssh/authorized_keys
.ssh/config
.bashrc
.profile
.bash_aliases
.emacs
.emacs.d/"

TMP=`mktemp -d`
ZIP="/tmp/asdf.tar.gz"
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
	exit 1
    fi

    ## file prep
    mkdir -p ${TMP}
    for file in ${FILES}
    do
	cp -R ${DOTS}/${file} ${TMP}
    done

    ## compression
    tar -czPf ${ZIP} ${TMP}

    case "$1" in
	-s|--servers) TARGET=${MACHINES} ;;
	-d|--desktops) TARGET=${DESKTOPS} ;;
	-l|--list) TARGET=`echo $@ |cut -d' ' -f2-` ;;
	*) echo "unknown option"
	    exit 1;;
    esac

    ## remote magic
    SSHELL="ssh -x -o"
    KEYCHECK="StrictHostKeyChecking no"
    TARGET=`echo ${TARGET} |tr '[:upper:]' '[:lower:]'`
    for host in ${TARGET}
    do
    	case "$host" in
    	    dmzshell*) ${RSYNC_OPTS} -e "${SSHELL} \"${KEYCHECK}\" -p 20110" ${ZIP} ${host}:/tmp 
		echo -n "."
		${SSHELL} "${KEYCHECK}" -p 20110 ${host} "${UNTAR} && ${MOVE} && ${CLEAN}"
		echo -n "."
		;;
	    cseesystems*) ${RSYNC_OPTS} ${ZIP} ${host}:/tmp
		echo -n "."
		ssh ${host} "${UNTAR} && ${MOVE} && ${CLEAN}"
		echo -n "."
		;;
    	    *) ${RSYNC_OPTS} ${ZIP} ${host}:/tmp 
		echo -n "."
    		${SSHELL} "${KEYCHECK}" ${host} "${UNTAR} && ${MOVE} && ${CLEAN}"
		echo -n "."
    		;;
    	esac
    done

    `${CLEAN}`
    
    ## elapsed time
    FIN="$(date +%s)"
    TIME="$(expr ${FIN} - ${START})"
    echo -e "\n"`date -u -d @${TIME} +"%M:%S"`" elapsed"
    echo "crescent fresh!"
else
    echo "do you even keys, br0?"
    exit 1
fi
