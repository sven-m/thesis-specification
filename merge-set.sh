#!/bin/bash

usage()
{
  cat << EOF
usage: $CALL_SIGNATURE <options>

The script merges all files under a certain directory

OPTIONS:
  [-h]
      this message

  -s <directory>
      source directory

  -o <directory>
      output directory

  [-i]
      show includes in results

  [-c]
      show comments denoting start and end of includes

EOF
}

SOURCE_DIR=
OUTPUTDIR=
MERGE_CONFIG_ARGS=
while getopts "hs:o:ci" OPTION
do
  case "$OPTION" in
    h)
      usage
      exit 1
      ;;
    s)
      SOURCE_DIR="`realpath "$OPTARG"`"
      ;;
    o)
      OUTPUTDIR="`realpath "$OPTARG"`"
      ;;
    i)
      MERGE_CONFIG_ARGS="$MERGE_CONFIG_ARGS -i"
      ;;
    c)
      MERGE_CONFIG_ARGS="$MERGE_CONFIG_ARGS -c"
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

if [ -z "$SOURCE_DIR" ]
then
  usage
  exit
fi

# look for all files in the SOURCE_DIR with names starting with "config". Every
# single file is a config root
for PROJECT_DIR in $(find "$SOURCE_DIR" -type d -depth 1);
do
  PROJECT_NAME="`basename "$PROJECT_DIR"`"
  for CONF_PATH in $(find "$PROJECT_DIR" -name 'config*.xml');
  do
    CONF_FILE="`basename "$CONF_PATH"`"
    mcutils merge-config $MERGE_CONFIG_ARGS -d "$PROJECT_DIR" -r "$CONF_PATH" \
      > "${OUTPUTDIR}/${PROJECT_NAME}_${CONF_FILE}"
  done
done
