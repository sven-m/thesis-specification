#!/bin/bash

usage()
{
  cat << EOF
usage: $CALL_SIGNATURE <options>

Visualize XML schema in a element diagram

OPTIONS:
  [-h]
      this message

  -s <schema file>
      The XML schema file to visualize

  [-d <dot file>]
      If provided, the generated dot definition for the graph is store in the specified file
    
  -o <output file>
      Specifies the file to output to

  -t 
EOF
}

BASEDIR=.
TRANSFORM="$RESOURCES_DIR/graph.xslt"
SCHEMA_FILE=
while getopts "hs:d:" OPTION
do
  case "$OPTION" in
    h)
      usage
      exit 1
      ;;
    s)
      SCHEMA_FILE="`realpath "$OPTARG"`"
      ;;
    d)
      DOT_FILE="`realpath "$OPTARG"`"
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

xsltproc "$TRANSFORM" "$ROOT_FILE" > "$OUTPUT_FILE"

