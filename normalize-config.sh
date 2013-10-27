#!/bin/bash

usage()
{
  cat << EOF
usage: $CALL_SIGNATURE <options>

This tool normalizes the namespace declarations in the MOBBL config XML, strips
unprintable characters from the files (except spaces, tabs and newlines), and
formats the XML.

OPTIONS:
  [-h]
      this message

  [-s <file path>]
      source file. Defaults to stdin

  [-d <file path>]
      destination file. Defaults to stdout
  
  [-i <file path>]
      edit file in place. Overrides -s and -d

  [-n]
      add MOBBL namespace
EOF
}

INPUT=/dev/stdin
OUTPUT=/dev/stdout
ADD_MOBBL_NS=
while getopts "hs:d:i:n" OPTION
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
    n)
      ADD_MOBBL_NS=1
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
  # in place editing! woohoo!

  if [ ! -f "$IN_PLACE" ]
  then
    echo "Error: $IN_PLACE does not exist or is not a regular file"
  fi

  # set input to file given through -i option
  INPUT="$IN_PLACE"

  # set output to temporary file
  OUTPUT="$TMPDIR/normalize-tmp-file"
fi


# finally! normalize namespaces! and other stuff!

# here are some variables that are going to come in handy later
NS_URL="http://itude.com/schemas/MB/2.0"
ADD_NS="s;<Configuration>;<Configuration xmlns=\"$NS_URL\">;"
STRIP_NS='s/ xmlns="[^"]*"//'


# Here are some variables that define the actions taken in different cases

# applies the following filters:
# - strip the input of unprintable characters, except tabs, spaces and
# newlines
# - strip empty namespace declarations
read -r -d '' COMMAND_HEAD << EOF
tr -dc '[:graph:]\t\n ' < "$INPUT" \
  | sed '$STRIP_NS'
EOF

# adds MOBBL namespace declaration
read -r -d '' COMMAND_ADD_NS << EOF
sed '$ADD_NS'
EOF

# format the XML and outputs to OUTPUT
read -r -d '' COMMAND_FOOT << EOF
xmllint --format /dev/stdin > "$OUTPUT"
EOF

# Apply appropriate filters, using eval (in order to evaluate the pipes and
# IO-redirections).
if [ -n "$ADD_MOBBL_NS" ]
then
  eval "$COMMAND_HEAD | $COMMAND_ADD_NS | $COMMAND_FOOT"
else
  eval "$COMMAND_HEAD | $COMMAND_FOOT"
fi


if [ -n "$IN_PLACE" ]
then
  # overwrite input file with output file
  mv "$OUTPUT" "$INPUT"
fi
