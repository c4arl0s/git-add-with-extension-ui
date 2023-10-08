#!/bin/bash

PARAMETER=$1
UNTRACKED_FILES=$(git ls-files --others --exclude-standard | grep $PARAMETER)
MODIFIED_FILES=$(git ls-files -m | grep $PARAMETER)

UNTRACKED_FILES_ERROR_MSG="Untracked files with filter: $PARAMETER don't exist"
MODIFIED_FILES_ERROR_MSG="Modified files with filter: $PARAMETER don't exist"

if [[ $UNTRACKED_FILES ]]; then
    let COUNTER=0
    LINE=$(git ls-files --others --exclude-standard | grep $PARAMETER | 
           while read UNTRACKED_FILE
           do 
               let "COUNTER+=1"
               echo "\"$UNTRACKED_FILE\" \"$COUNTER\" off"
           done)
    echo $LINE;
    SELECTED_UNTRACKED_FILES=$(echo $LINE | xargs dialog --stdout --checklist "untracked files to add with filter ($PARAMETER) :" 0 0 0)
    echo $SELECTED_UNTRACKED_FILES | xargs git add
else
    echo -e $UNTRACKED_FILES_ERROR_MSG
fi

if [[ $MODIFIED_FILES ]]; then
    let COUNTER=0
    LINE=$(git ls-files -m | grep $PARAMETER | 
           while read MODIFIED_FILE
           do 
               let "COUNTER+=1"
               echo "\"$MODIFIED_FILE\" \"$COUNTER\" off"
           done)
    echo $LINE
    SELECTED_MODIFIED_FILES=$(echo $LINE | xargs dialog --stdout --checklist "modified files to add with filter ($PARAMETER):" 0 0 0)
    echo $SELECTED_MODIFIED_FILES | xargs git add
else
    echo -e $MODIFIED_FILES_ERROR_MSG
fi
