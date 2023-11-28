#!/bin/bash

EXTENSION=$1
UNTRACKED_FILES=$(git ls-files --others --exclude-standard | grep $EXTENSION)
MODIFIED_FILES=$(git ls-files -m | grep $EXTENSION)

UNTRACKED_FILES_ERROR_MSG="Untracked files with extension $EXTENSION don't exist"
MODIFIED_FILES_ERROR_MSG="Modified files with extension $EXTENSION don't exist"

WARNING_UNTRACKED_MSG=
WARNING_MODIFIED_MSG=

if [[ $UNTRACKED_FILES ]]; then
    let COUNTER=0
    LINE=$(git ls-files --others --exclude-standard | grep $EXTENSION | 
           while read UNTRACKED_FILE
           do 
               let "COUNTER+=1"
               echo "\"$UNTRACKED_FILE\" \"$COUNTER\" off"
           done)
    echo $LINE;
    SELECTED_UNTRACKED_FILES=$(echo $LINE | xargs dialog --stdout --checklist "untracked files to add with extension ($EXTENSION) :" 0 0 0)
    [ ! -z "$SELECTED_UNTRACKED_FILES" ] && echo $SELECTED_UNTRACKED_FILES | xargs git add || WARNING_UNTRACKED_MSG="🟡 You did not select any untracked file"
else
    echo $UNTRACKED_FILES_ERROR_MSG
fi

if [[ $MODIFIED_FILES ]]; then
    let COUNTER=0
    LINE=$(git ls-files -m | grep $EXTENSION | 
           while read MODIFIED_FILE
           do 
               let "COUNTER+=1"
               echo "\"$MODIFIED_FILE\" \"$COUNTER\" off"
           done)
    echo $LINE
    SELECTED_MODIFIED_FILES=$(echo $LINE | xargs dialog --stdout --checklist "modified files to add with extension ($EXTENSION):" 0 0 0)
    [ ! -z "$SELECTED_MODIFIED_FILES" ] && echo $SELECTED_MODIFIED_FILES | xargs git add || WARNING_MODIFIED_MSG="🟡 You did not select any modified file"
else
    echo $MODIFIED_FILES_ERROR_MSG
fi

[ ! -z "$WARNING_UNTRACKED_MSG" ] && echo $WARNING_UNTRACKED_MSG
[ ! -z "$WARNING_MODIFIED_MSG" ] && echo $WARNING_MODIFIED_MSG
