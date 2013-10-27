#!/bin/bash

usage()
{
  cat << EOF
usage: $CALL_SIGNATURE <options>

The script normalizes all files under a certain directory.

OPTIONS:
  [-h]
      this message

  -t <target directory>
      target directory

  [-n]
      add MOBBL namespace to output

EOF
}

TARGETDIR=
ADD_NS=
while getopts "ht:n" OPTION
do
  case "$OPTION" in
    h)
      usage
      exit 1
      ;;
    n)
      ADD_NS_ARG="-n"
      ;;
    t)
      TARGETDIR="$OPTARG"
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

if [ -z "$TARGETDIR" ]
then
  usage
  exit
fi

# look for all XML files in the TARGETDIR. Strip empty namespace declarations,
# add MOBBL namespace declarations if requested.
for FILE_PATH in `find "$TARGETDIR" -name '*.xml'`
do
  mcutils normalize-config $ADD_NS_ARG -i "$FILE_PATH"
done

