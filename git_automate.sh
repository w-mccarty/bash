#!bin/bash

tNUL='\033[0m'
tRED='\033[0;31m'
tGRN='\033[0;32m'

f_restore() {
  git checkout HEAD $1
  echo -e "$tGRN $1 restored"
  pre_commit
}

f_commit() {
  git commit -m "commited with script"
  git push
  exit 0
}

pre_commit() {
  declare -a arr
  readarray -t arr < <(git status --porcelain 2>/dev/null)
  if [ ${#arr[@]} == 0 ]; then
    echo -e "$tRED NO CHANGES TO COMMIT"
    exit 0
  else
    echo -e "${tNUL}Files to commit and push:"
    declare -a arr2
    for ((i=0; i<${#arr[@]}; i++ )); do
      v1=$i
      v2="${arr[$i]:0:1}"
      case $v2 in
        "D")
          v3=$tRED
          ;;
        "A")
          v3=$tGRN
          ;;
        *)
          v3=$tNUL
          ;;
        esac
      v4=$(echo "${arr[$i]}" | tr -s ' ' | cut -d '/' -f2)
      v5=$(echo "${arr[$i]}" | tr -s ' ' | cut -d ' ' -f2)
      arr2+=("$v2-$v4-$v5")
      echo -e "$v3 $v1 - $v2 - $v4 - $v5 $tNUL"
    done
    read -p "a to add, c to commit, or the item number to restore: " vRestore
    if [ $vRestore == "a" ]; then
      for ((i=0; i<${#arr2[@]}; i++ )); do
        vres=$(echo "${arr2[$i]}" | tr -s ' ' | cut -d '-' -f1)
        vfes=$(echo "${arr2[$i]}" | tr -s ' ' | cut -d '-' -f2)
        if [ $vres == "?" ]; then
          git add $vfes
        fi
      done
      pre_commit
    elif [ $vRestore == "c" ]; then
      f_commit
    else
      if [ ${arr2[$vRestore]} ]; then
        vres=$(echo "${arr2[$vRestore]}" | tr -s ' ' | cut -d '-' -f2)
        f_restore $vres
      else
        echo -e "$tRED $vRestore NOT FOUND"
        pre_commit
      fi
    fi
  fi
}

f_dir_check() { #Check if current dir is git
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "$tRED FOLDER IS NOT GIT REPOSITORY"
    exit 1
  else
    pre_commit
  fi
}

f_dir_check
