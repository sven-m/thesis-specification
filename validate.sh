#!/bin/bash

usage()
{
  cat << EOF
usage: $CALL_SIGNATURE <options>

Validate one or a set of XML files

OPTIONS:
  [-h]
      this message

  -i <directory>
      specify input directory containing the XML files to derive a schema from

  -s <schema file>
      specify the schema to validate against

EOF
}

INPUT_DIR=
SCHEMA_FILE=
while getopts "hi:s:" OPTION
do
  case "$OPTION" in
    h)
      usage
      exit 1
      ;;
    i)
      INPUT_DIR="`realpath "$OPTARG"`"
      ;;
    s)
      SCHEMA_FILE="`realpath "$OPTARG"`"
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

# perform schema inference

if [ -z "$INPUT_DIR" ] || [ -z "$SCHEMA_FILE" ]
then
  usage
  exit
fi


VALIDATED=()
ERRORS=()

ALL_ERROR_OUTPUT="$TMPDIR"/mcutils-all-errors
TMP_ERROR_OUTPUT="$TMPDIR"/mcutils-tmp-error

rm -rf "$ALL_ERROR_OUTPUT" "$TMP_ERROR_OUTPUT"

#output both to stdout and logfile (header, in case errors coming)
echo "Validating with schema: $SCHEMA_FILE" | tee "$ALL_ERROR_OUTPUT"

for xmlFile in "$INPUT_DIR"/*.xml
do

  xmllint --noout --schema "$SCHEMA_FILE" "$xmlFile" 2> "$TMP_ERROR_OUTPUT"
  RC=$?
  if [ "$RC" = 0 ]
  then
    # success
    VALIDATED=("${VALIDATED[@]}" "$xmlFile")
  else
    # something else
    ERRORS=("${ERRORS[@]}" "$xmlFile")

    # an error has occurred, so append the contents of TMP_ERROR_OUTPUT
    sed 's/^/  /' "$TMP_ERROR_OUTPUT" >> "$ALL_ERROR_OUTPUT"
    echo >> "$ALL_ERROR_OUTPUT"
  fi
done

if [ ${#ERRORS[@]} = 0 ]
then
  echo "  All files validate"
else
  # print filenames that couldn't be validated
  for xmlFile in "${ERRORS[@]}";    do echo "  NOT validated: $xmlFile"; done
  echo
  # print filenames of validated files
  for xmlFile in "${VALIDATED[@]}"; do echo "  Validated    : $xmlFile"; done
  # or state that no files validated
  [ "${#VALIDATED[@]}" = 0 ] && echo "  No file is valid according to schema"

  # errors have occurred, so write all error output to stderr
  echo >> "$ALL_ERROR_OUTPUT"
  cat "$ALL_ERROR_OUTPUT" > /dev/stderr
fi

echo

# clean up
rm -rf "$ALL_ERROR_OUTPUT" "$TMP_ERROR_OUTPUT"
