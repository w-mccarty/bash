#! /bin/bash -
#
#Syncs remote directory to local directory and logs files to EXCLUDE future resync of the same files.  Useful if moving/editing files in local dir after syncing.
#
#custom vars
localfiledir='/local/fileDirectory'
locallogdir='/local/logDirectory'
remotedir='/remote/fileDirectory'
remoteuser='username'
remoteIP='192.168.0.1'
#
#vars
sedfiledir=$(echo "${localfiledir////$'\/'}")
date=$(date +%Y-%m-%d_%H:%M:%S)
#
#first-run logging of existing files in localfiledir
if [[ ! -e ${locallogdir}/nosyncfinal.txt ]]; then
	touch ${locallogdir}/nosyncfinal.txt
	find ${localfiledir}/ -maxdepth 1 -type f > ${locallogdir}/files.txt #list files
	sed -i "s/$sedfiledir\///g" ${locallogdir}/files.txt #filename only
	sed -i '/^$/d' ${locallogdir}/files.txt #remove whitespace
	find ${localfiledir}/ -maxdepth 1 -type d > ${locallogdir}/dirs.txt #list directories
	sed -i "s/$sedfiledir\///g" ${locallogdir}/dirs.txt #dirname only
	sed -i '/^$/d' ${locallogdir}/dirs.txt #remove whitespace
	cat ${locallogdir}/files.txt ${locallogdir}/dirs.txt > ${locallogdir}/nosync.txt #combine
	awk '!seen[$0]++' ${locallogdir}/nosync.txt > ${locallogdir}/nosyncfinal.txt #remove duplicates
	cp ${locallogdir}/nosyncfinal.txt ${locallogdir}/initsync_${date}.txt #initial log
	rm -rf ${locallogdir}/nosync.txt ${locallogdir}/files.txt ${locallogdir}/dirs.txt #cleanup
fi
#
#rsync
rsync -a --progress --exclude-from "${locallogdir}/nosyncfinal.txt" ${remoteuser}@${remoteIP}:${remotedir}/ ${localfiledir}
#
#post-sync logging of files in localfiledir to prevent future re-sync
find ${localfiledir}/ -maxdepth 1 -type f > ${locallogdir}/files.txt #list files
sed -i "s/$sedfiledir\///g" ${locallogdir}/files.txt #filename only
sed -i '/^$/d' ${locallogdir}/files.txt #remove whitespace
find ${localfiledir}/ -maxdepth 1 -type d > ${locallogdir}/dirs.txt #list directories
sed -i "s/$sedfiledir\///g" ${locallogdir}/dirs.txt #dirname only
sed -i '/^$/d' ${locallogdir}/dirs.txt #remove whitespace
cat ${locallogdir}/files.txt ${locallogdir}/dirs.txt ${locallogdir}/nosyncfinal.txt > ${locallogdir}/nosync.txt #combine
awk '!seen[$0]++' ${locallogdir}/nosync.txt > ${locallogdir}/nosyncfinal.txt #remove duplicates
cp ${locallogdir}/nosyncfinal.txt ${locallogdir}/nosync_${date}.txt #log
rm -rf ${locallogdir}/nosync.txt ${locallogdir}/files.txt ${locallogdir}/dirs.txt #cleanup
