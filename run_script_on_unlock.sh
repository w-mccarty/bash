########################################### WARNING ###########################################

# IF "~/.profile" IS EDITED INCORRECTLY A LOGIN LOOP OR OTHER SERIOUS ERROR CAN OCCUR
# SCRIPT CREATOR IS NOT RESPONSIBLE FOR ANY DAMAGE CAUSED BY THIS SCRIPT
# TESTED ON UBUNTU 24.04 LTS

############################################ SETUP ############################################

# RENAME SCRIPT TO "unlock.sh"
# MOVE SCRIPT TO ~/ AND CHMOD 554
# REPLACE LINE 22 IN THIS SCRIPT WITH CONTENTS TO EXECUTE ON UNLOCK

# ADD LINE 13-16 TO BOTTOM OF "~/.profile" AND UNCOMMENT SO SCRIPT RUNS ON RESTART/LOGIN
#SPATH="$HOME/unlock.sh"
#if [[ -f "$SPATH" ]] ; then
#        /bin/bash $SPATH &
#fi

########################################### SCRIPT ###########################################

gdbus monitor -y -d org.freedesktop.login1 | grep --line-buffered -o 'Session.Unlock ()' | while read -r; do
	echo "SCRIPT CONTENTS GO HERE"
done
