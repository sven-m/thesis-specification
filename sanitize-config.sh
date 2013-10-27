#!/bin/bash

usage()
{
  cat << EOF
usage:
  $CALL_SIGNATURE [-h]
  $CALL_SIGNATURE -i <file path>
  $CALL_SIGNATURE -s <input file> -d <output file>

This script filters input and strips unwanted characters.

OPTIONS:
  [-h]
      this message

  [-s <file path>]
      source file. Defaults to stdin

  [-d <file path>]
      destination file. Defaults to stdout
  
  [-i <file path>]
      edit file in place. Overrides -s and -d
EOF
}


INPUT=/dev/stdin
OUTPUT=/dev/stdout
IN_PLACE=
COMMAND=
while getopts "hs:d:i:" OPTION
do
  case "$OPTION" in
    h)
      usage
      exit 1
      ;;
    s)
      INPUT="$OPTARG"
      ;;
    d)
      OUTPUT="$OPTARG"
      ;;
    i)
      IN_PLACE="$OPTARG"
      ;;
    c)
      COMMAND=$OPTARG
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

# making sure no faulty user input is given
if [ -z "$IN_PLACE" ] && [ "$INPUT" = "$OUTPUT" ]
then
  echo "Error: if not editing in place, arguments of -s and -d may not be equal"
  echo "Use $CALL_SIGNATURE -h for help"
  exit
fi

if [ -n "$IN_PLACE" ]
then
  # in place editing!

  if [ ! -f "$IN_PLACE" ]
  then
    echo "Error: $IN_PLACE does not exist or is not a regular file"
  fi

  # set input to file given through -i option
  INPUT="$IN_PLACE"

  # set output to temporary file
  OUTPUT="$TMPDIR/normalize-tmp-file"
fi

# filter the input
tr '[:graph:]\t\n ' < "$INPUT" > "$OUTPUT"


if [ -n "$IN_PLACE" ]
then
  # overwrite input file with output file
  mv "$OUTPUT" "$INPUT"
fi


