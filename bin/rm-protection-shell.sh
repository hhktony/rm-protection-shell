#!/usr/bin/env bash
#  Filename: rm-protection-shell.sh
#   Created: 2012-11-30 11:52:23
#      Desc: A safe alternative for "rm".
#    Author: xutao(Tony Xu), hhktony@gmail.com
#   Company: myself

TRASH_DIR=${TRASH_DIR:=$HOME/.Trash}
TRASH_LOG=${TRASH_LOG:=$HOME/.Trash.log}

[ ! -d $TRASH_DIR ] && mkdir -p $TRASH_DIR

usage()
{
  cat <<EOF
Usage: rm [file1] [file2] [dir3] [....]
       rm [ -l | -c | -h ]

options:
  -l  show log of the deleted files
  -c  clean the recycle bin
  -h  display this help menu
EOF
}

move()
{
  now=`date +%F_%H:%M:%S`
  file_path=$(realpath "$file")
  base_name=$(basename "$file_path")

  local trash_name="$TRASH_DIR/$base_name"
  [[ -e "$trash_name" ]] && trash_name="$trash_name.$now"

  if [[ "$file_path" == "/" ]]; then
    echo "rm: it is dangerous to operate recursively on ‘/’"
  else
    mv "$file_path" "$trash_name" && \
    echo -e "[$now] [`whoami`] $file_path \t=>\t $trash_name" | tee -a $TRASH_LOG
  fi
}

clean()
{
  echo -en "All backups in trash will be delete, continue or not(y/n): "
  read -n 1 confirm
  echo
  [[ $confirm == y ]] && \rm -vrf ${TRASH_DIR}/* && echo -n >$TRASH_LOG
}

[ $# -eq 0 ] && usage

while getopts licdhfr option
do
  case "$option" in
    l) cat $TRASH_LOG;;
    h) usage;;
    c) clean;;
   \?) usage
       exit 1;;
  esac
done
shift $((OPTIND-1))

while [ $# -ne 0 ]
do
  file=$1
  move
  shift
done
