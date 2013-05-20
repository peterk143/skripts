#! /bin/bash

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

TMP="/home/pkirkpat/asdf"
ZIP="/home/pkirkpat/asdf.temp.tar.gz"
RSYNC_OPTS="rsync -az"
CLEAN="rm -rf /home/pkirkpat/asdf /home/pkirkpat/asdf.temp.tar.gz"
RMT_CMD="tar -xzPf /home/pkirkpat/asdf.temp.tar.gz && \
mkdir -p /home/pkirkpat/.ssh && \
mv /home/pkirkpat/asdf/.bashrc /home/pkirkpat/ && \
mv /home/pkirkpat/asdf/.bash_aliases /home/pkirkpat/ && \
mv /home/pkirkpat/asdf/authorized_keys /home/pkirkpat/asdf/config /home/pkirkpat/.ssh/"

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
	    dmzshell*) ${RSYNC_OPTS} -e "${SSHELL}" ${ZIP} ${host}.lcsee.wvu.edu:~/ ;;
	    *) ${RSYNC_OPTS} ${ZIP} ${host}.lcsee.wvu.edu:~/ ;;
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

    echo "allGood!"
else
    echo "do you even keys, br0?"
fi

`${CLEAN}`
exit 0
