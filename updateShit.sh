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

FILES="/cloudhome/pkirkpat/.ssh/authorized_keys
/cloudhome/pkirkpat/.ssh/config
/cloudhome/pkirkpat/.bashrc
/cloudhome/pkirkpat/.bash_aliases"

TMP=`mktemp -d`
ZIP=/tmp/asdf.tar.gz
RSYNC_OPTS="rsync -az"
CLEAN="rm -rf ${TMP} ${ZIP}"
RMT_CMD="tar -xzPf ${ZIP} && \
mkdir -p /home/pkirkpat/.ssh && \
mv ${TMP}/.bashrc /home/pkirkpat/ && \
mv ${TMP}/config /home/pkirkpat/.ssh/ && \
mv ${TMP}/.bash_aliases /home/pkirkpat/ && \
mv ${TMP}/authorized_keys /home/pkirkpat/.ssh/"
START="$(date +%s)"

# file prep
mkdir -p ${TMP}
for file in ${FILES}
do
    cp ${file} ${TMP}
done

# compression
tar -czPf ${ZIP} ${TMP}

# ssh key check
CHECK=`ssh-add -l`
if [ $? -eq 0 ]
then
    SSHELL="ssh -p 20110"
    # file transpo
    echo "sending files."
    for host in ${MACHINES}
    do
	case "$host" in
	    dmzshell*) ${RSYNC_OPTS} -e "${SSHELL}" ${ZIP} ${host}.lcsee.wvu.edu:/tmp ;;
	    *) ${RSYNC_OPTS} ${ZIP} ${host}.lcsee.wvu.edu:/tmp ;;
	esac
    done

    # put files into place
    echo "puttin' shit away.."
    for h in ${MACHINES}
    do
    	case "$h" in
    	    dmzshell*) ${SSHELL} ${h}.lcsee.wvu.edu "${RMT_CMD}" ;;
    	    *) ssh ${h}.lcsee.wvu.edu "${RMT_CMD}" ;;
    	esac
    done

    # clean up temps
    echo "clean all the things..."
    for x in ${MACHINES}
    do
    	case "$x" in
    	    dmzshell*) ${SSHELL} ${x}.lcsee.wvu.edu "${CLEAN}" ;;
    	    *) ssh ${x}.lcsee.wvu.edu "${CLEAN}" ;;
    	esac
    done

    EXIT_CODE=0
    echo "allGood!"
else
    EXIT_CODE=1
    echo "do you even keys, br0?"
fi

`${CLEAN}`

# elapsed time
FIN="$(date +%s)"
TIME="$(expr ${FIN} - ${START})"
echo `date -u -d @${TIME} +"%M:%S"`" elapsed"

exit ${EXIT_CODE}