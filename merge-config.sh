#!/bin/bash

usage()
{
  cat << EOF
usage: $CALL_SIGNATURE <options>

This script merges a config XML with its child configs.

OPTIONS:
  [-h]
      this message

  [-d <directory>]
      specify base dir for file paths in <include .../> elements, defaults to
      current working directory

  [-t <filename>]
      file containing a custom XSLT transformation

  -r <filename>
      root file of config

  [-o <filename>]
      output destination, defaults to stdout

  [-i]
      show includes in result

  [-c]
      show comments denoting include start and end

EOF
}

BASE_DIR="`realpath .`"
TRANSFORM="$RESOURCES_DIR/merge-config.xslt"
ROOT_FILE=
OUTPUT_FILE=/dev/stdout
INCLUDES_ARGS=
COMMENTS_ARGS=
while getopts "hd:t:r:o:ns:ic" OPTION
do
  case "$OPTION" in
    h)
      usage
      exit 1
      ;;
    d)
      BASE_DIR="`realpath "$OPTARG"`"
      ;;
    t)
      TRANSFORM="$OPTARG"
      ;;
    r)
      ROOT_FILE="$OPTARG"
      ;;
    o)
      OUTPUT_FILE="$OPTARG"
      ;;
    i)
      INCLUDES_ARGS="--stringparam includes yes"
      ;;
    c)
      COMMENTS_ARGS="--stringparam comments yes"
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

if [ -z "$ROOT_FILE" ]
then
  usage
  exit
fi

PATH_ARGS="--stringparam path $BASE_DIR"

# merge the files
xsltproc $PATH_ARGS $INCLUDES_ARGS $COMMENTS_ARGS \
  "$TRANSFORM" "$ROOT_FILE" > "$OUTPUT_FILE"
