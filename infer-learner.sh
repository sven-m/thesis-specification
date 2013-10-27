#!/bin/bash

usage()
{
  cat << EOF
usage: $CALL_SIGNATURE <options>

Infer using XML-schema learner

OPTIONS:
  [-h]
      this message

  -i <directory>
      specify source directory containing the XML files to derive a schema from

  -o <directory name>
      output destination, should exist already

  [-s]
      defines a filename suffix appended to the filename with an underbar (_)
      before the extension.

  [-n]
      indicates that the XML files to be analysed have a MOBBL namespace
      declaration, and the output should have a targetNamespace declaration as
      well.

EOF
}

INPUT_DIR=
OUTPUT_DIR=
SUFFIX=
DEF_TNS="no-ns"
while getopts "hi:o:s:n" OPTION
do
  case "$OPTION" in
    h)
      usage
      exit 1
      ;;
    i)
      INPUT_DIR="`realpath "$OPTARG"`"
      ;;
    o)
      OUTPUT_DIR="`realpath "$OPTARG"`"
      ;;
    s)
      SUFFIX="_$OPTARG"
      ;;
    n)
      DEF_TNS="ns"
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

# perform schema inference

if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_DIR" ]
then
  usage
  exit
fi

for method in exact reduce node-based subsumed node-subsumed
do
  schemaFile="$OUTPUT_DIR/${method}${SUFFIX}.xsd"
  echo "Processing files for $schemaFile:"

  for xmlFile in "$INPUT_DIR"/*.xml
  do
    echo "  $xmlFile"
  done

  learn --type xsd --ptrnComp "${method}" "$INPUT_DIR"/*.xml > "$schemaFile"

  # repair XML-schema-learner output

  # clean up empty xmlns attribute declaration. ugh.
  sed -i '' 's#<attribute name="xmlns" type="string" use="required"/>##g' "$schemaFile"
  sed -i '' 's#<attribute name="xmlns" type="string" use="required"/>##g' "$schemaFile"
  sed -i '' 's#<attribute name="xmlns" type="string" use="required"/>##g' "$schemaFile"

  # clean up xmlns:xsi and xsi:schemaLocation declarations, to prevent them from
  # being denoted by XML schema learner
  sed -i '' 's#<attribute name="xmlns:xsi" type="string" use="required"/>##g' "$schemaFile"
  sed -i '' 's#<attribute name="xsi:schemaLocation" type="string" use="required"/>##g' "$schemaFile"

  # fix XMLSchema namespace declaration
  sed -i '' 's#schema xmlns#schema xmlns:xs#g' "$schemaFile"

  # add xs: namespace prefixes to open and close tags and type attribute values
  sed -i '' 's#<\([^?/]\)#<xs:\1#g' "$schemaFile"
  sed -i '' 's#</#</xs:#g' "$schemaFile"
  sed -i '' 's#type="\([a-z]\)#type="xs:\1#g' "$schemaFile"

  # determine wether targetNamespace should be defined
  if [ "$DEF_TNS" = "ns" ]
  then
    TNS="http://itude.com/schemas/MB/2.0"
    sed -i '' 's#targetNamespace="[^"]*"#targetNamespace="'$TNS'" xmlns="'$TNS'"#g' "$schemaFile"
  elif [ "$DEF_TNS" = "no-ns" ]
  then
    sed -i '' 's#targetNamespace="[^"]*"##g' "$schemaFile"
  fi
done

