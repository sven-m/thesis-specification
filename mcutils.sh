#!/bin/bash

BASENAME=`basename $0`

usage()
{
  cat << EOF
usage: $BASENAME <options> <command> [<args>]

This is the entry script to use the MOBBL XML tools. The available commands
are:

COMMANDS:
  list-config
  merge-config
  merge-set
  normalize-config
  normalize-dir
  xpath-dir
  extract-config
  extract-set
  validate
  infer-learner
  infer-trang

OPTIONS:
  [-h]
      this message

ARGS:
  The arguments depend on the command. Most commands have help messages
  themselves (command: $BASENAME <command> -h)

EOF
}

error() {
  usage
  exit
}

# convert relative paths into absolute paths
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/$1"
}

export -f realpath

FILEPATH="$0"

while [ -h "$FILEPATH" ]
do
  FILEPATH="`readlink "$FILEPATH"`"
done

export TOOLS_DIR="`dirname "$FILEPATH"`"
export RESOURCES_DIR="$TOOLS_DIR"/resources


while getopts "h" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

# check for enough arguments
if [ "$#" -le 0 ]
then
  error
fi

TOOLNAME=$1

if [[  "$TOOLNAME" != "list-config"     
    && "$TOOLNAME" != "merge-config"       
    && "$TOOLNAME" != "merge-set"
    && "$TOOLNAME" != "normalize-config"
    && "$TOOLNAME" != "normalize-dir"
    && "$TOOLNAME" != "xpath-dir"
    && "$TOOLNAME" != "extract-config"
    && "$TOOLNAME" != "extract-set"
    && "$TOOLNAME" != "validate"
    && "$TOOLNAME" != "infer-learner"
    && "$TOOLNAME" != "infer-trang" ]]
then
  error
fi

# by now, we can be sure a valid tool name has been provided

# pass on call signature, for the usage message
export CALL_SIGNATURE="`basename $0` $TOOLNAME"

# execute tool with arguments, skipping the first two (command and toolname)
$TOOLS_DIR/$TOOLNAME.sh "${@:2}"
