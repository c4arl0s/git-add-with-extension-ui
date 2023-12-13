#!/bin/bash
#
# git-add-with-extension-ui script uses an user interface to add files with an
# extension to the stage area.

extension=${1:?“🔴 Error: You must supply an Extention as first parameter.“}

readonly UNTRACKED_FILES_ERROR_MSG='Untracked files with extension $extension dont exist'
readonly MODIFIED_FILES_ERROR_MSG='Modified files with extension $extension dont exist'
readonly ERROR_REPO='Current directory is not a git repository'

warning_untracked_msg=
warning_modified_msg=

#######################################
# A function to print out error messages 
# Globals:
#   
# Arguments:
#   None
#######################################
error() {
  echo "[🔴 $(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

#######################################
# A function to print out warning messages 
# Globals:
#   
# Arguments:
#   None
#######################################
warning() {
  echo "[🟡 $(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { error ${ERROR_REPO}; return 1; }

untracked_files=$(git ls-files --others --exclude-standard | grep ".*.${extension}$")
modified_files=$(git ls-files -m | grep ".*.${extension}$")

if [[ -n ${untracked_files} ]]; then
  let counter=0
  line=$(git ls-files --others --exclude-standard \
    | grep ".*.${extension}$" \
    | while read untracked_file; do 
        let "counter+=1"
        echo "\"${untracked_file}\" \"${counter}\" off"
      done)
  selected_untracked_files=$(echo ${line} | xargs dialog --stdout --checklist "untracked files to add with extension (${extension}) :" 0 0 0)
  [ -n "${selected_untracked_files}" ] \
    && echo ${selected_untracked_files} | xargs git add \
    && echo "🟢 Selected files with extension ${extension} were added to stage area" \
    || warning_untracked_msg="You did not select any untracked file"
else
  error ${UNTRACKED_FILES_ERROR_MSG}
fi

if [[ -n ${modified_files} ]]; then
  let counter=0
  line=$(git ls-files -m | grep ".*.${extension}$" \
    | while read modified_file; do 
        let "counter+=1"
        echo "\"${modified_file}\" \"${counter}\" off"
      done)
  selected_modified_files=$(echo ${line} | xargs dialog --stdout --checklist "modified files to add with extension (${extension}):" 0 0 0)
  [ -n "${selected_modified_files}" ] \
    && echo ${selected_modified_files} | xargs git add \
    && echo "🟢 Selected files with extension ${extension} were added to stage area" \
    || warning_modified_msg="You did not select any modified file"
else
  error ${MODIFIED_FILES_ERROR_MSG}
fi

[ -n "${warning_untracked_msg}" ] && warning ${warning_untracked_msg}
[ -n "${warning_modified_msg}" ] && warning ${warning_modified_msg}
