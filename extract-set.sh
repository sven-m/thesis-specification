#!/bin/bash

usage()
{
  cat << EOF
usage: $CALL_SIGNATURE <options>

This tool extracts all configs in projects under a given directory

OPTIONS:
  [-h]
      this message

  -i <directory>
      input directory

  -o <directory>
      output directory

EOF
}

INPUTDIR=
OUTPUTDIR=
while getopts "hi:o:" OPTION
do
  case "$OPTION" in
    h)
      usage
      exit 1
      ;;
    i)
      INPUTDIR="`realpath "$OPTARG"`"
      ;;
    o)
      OUTPUTDIR="`realpath "$OPTARG"`"
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

if [ -z "$INPUTDIR" ]
then
  usage
  exit
fi

# look for all files in the INPUTDIR with names starting with "config". Every
# single file is a config root
for CONF_PATH in $(find "$INPUTDIR" -name 'config*.xml');
do
  PROJECT_DIR="`dirname \`dirname "$CONF_PATH"\``"
  PROJECT_NAME="`basename "$PROJECT_DIR"`"
  CONF_FILE="`basename "$CONF_PATH"`"
  mcutils extract-config -d "$PROJECT_DIR" -r "$CONF_PATH" \
    -o "${OUTPUTDIR}/${PROJECT_NAME}_${CONF_FILE%.xml}"
done

