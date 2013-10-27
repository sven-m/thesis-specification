#!/bin/bash

usage()
{
  cat << EOF
usage: $CALL_SIGNATURE <options>

This tool lists the paths of all the files referenced by a root config file.
The output list includes the root file itself and the paths are relative to the
current working directory.

Run this tool from the main directory of the project in which the config
resides (usually the parent of the 'config' directory).

OPTIONS:
  [-h]
      this message


  [-c <config filepath>]
      the file path of the root config file relative
    
EOF
}


PROJECT_DIR=.
CONFIG_FILE=
TRANSFORM="$RESOURCES_DIR/getrefs.xslt"
while getopts "hc:d:" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    c)
      CONFIG_FILE="`realpath "$OPTARG"`"
      ;;
    d)
      PROJECT_DIR="`realpath "$OPTARG"`"
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

if [ -z "$CONFIG_FILE" ]
then
  usage
  exit
fi

xsltproc --stringparam path "$PROJECT_DIR" "$TRANSFORM" "$CONFIG_FILE"
