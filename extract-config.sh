#!/bin/bash

usage()
{
  cat << EOF
usage: $CALL_SIGNATURE <options>

This script extracts all the config files of a project to a given location.

OPTIONS:
  [-h]
      this message

  [-d <directory>]
      specify base dir for file paths in <include .../> elements, defaults to
      current working directory

  -r <filename>
      root XML file

  -o <directory name>
      output destination, should not exist already

EOF
}

BASEDIR=.
ROOT_FILE=
OUTPUT_DIR=
while getopts "hd:r:o:" OPTION
do
  case "$OPTION" in
    h)
      usage
      exit 1
      ;;
    d)
      BASEDIR="`realpath "$OPTARG"`"
      ;;
    r)
      ROOT_FILE="`realpath "$OPTARG"`"
      ;;
    o)
      OUTPUT_DIR="`realpath "$OPTARG"`"
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

if [ -z "$ROOT_FILE" ] || [ -z "$OUTPUT_DIR" ]
then
  usage
  exit
fi

# create the output dir, exit if unsuccessful
mkdir "$OUTPUT_DIR" || exit


# extract the files using the following method:
# - first generate and print a file list using 'mcutils list-config'
# - print a line containing the root filename of the config, relative to the
#     basedir
# - multiplex these two streams into one and feed it to rsync, that will copy
#     all the files in the combined list to the specified output dir
cat \
  <( mcutils list-config -d "$BASEDIR" -c "$ROOT_FILE" ) \
  <( echo ${ROOT_FILE#$BASEDIR/} ) \
  | rsync --files-from=/dev/stdin "$BASEDIR" "$OUTPUT_DIR"
