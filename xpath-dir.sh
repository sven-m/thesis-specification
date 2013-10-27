#!/bin/bash

usage()
{
  cat << EOF
usage: $CALL_SIGNATURE <options>

This script searches though XML files using xpath

OPTIONS:
  [-h]
      this message

  -x <expression>
      XPath expression

  [-d <directory>]
      search directory. Defaults to working directory (.)

  [-s]
      silent mode. do not show matched output

  [-f]
      show filenames (only applies if not -s, renders -u inert)

  [-u]
      filter unique values in output, only applies if not -s or -f

EOF
}

XPATH=
ENABLEOUTPUT=1
SEARCHDIR=.
while getopts "hx:d:sfu" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    x)
      # the XPath query
      XPATH=$OPTARG
      ;;
    d)
      # (optional) the search directory
      SEARCHDIR=$OPTARG
      ;;
    s)
      # silent -> do NOT show matched output
      ENABLEOUTPUT=0
      ;;
    f)
      # tag matched output with file names
      SHOWFILE=1
      ;;
    u)
      # sort matched output and filter away duplicates. does not work if -s or
      # -f is supplied
      UNIQUE=1
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

if [ -z "$XPATH" ]
then
  usage
  exit
fi

# keep track of number of hits and misses (files containing matched output or
# not containing matched output)
FOUND=0
ERRORS=0

# keep track of files that yield results and files that don't
FOUNDLIST=
NOTFOUNDLIST=

if [ $ENABLEOUTPUT -eq "1" ]
then
  echo Output
  echo ------
fi

# go through all XML files in the search directory (default is working
# directory)
for file in $(find $SEARCHDIR -type f -name "*.xml")
do
  # use xmllint to query the xml
  RESULT=$(xmllint --xpath "$XPATH" $file 2>&1)
  if [ $? != 0 ]
  then
    # keep track of the number of documents for which the query did not yield
    # any results
    let ERRORS=ERRORS+1
    NOTFOUNDLIST=${NOTFOUNDLIST}'\n'$file
  else
    # keep track of the number of documents for which the query yielded results
    let FOUND=FOUND+1
    FOUNDLIST=${FOUNDLIST}'\n'$file

    # if silent mode do NOT build output in OUTPUT
    if [ $ENABLEOUTPUT -eq "1" ]
    then
      # if file names are requested, add them to the output
      if [ -z $SHOWFILE ]
      then
        # add output to OUTPUT, no file name tag
        OUTPUT="$(echo $OUTPUT $RESULT)"
      else
        # add output to OUTPUT, including file name tag
        OUTPUT="$OUTPUT  $file: $RESULT"
      fi
    fi
  fi
done

# print matched output (OUTPUT may be empty, but printing is done regardless)
if [ -z $SHOWFILE ] && [ "$UNIQUE" = 1 ]
then
  # only sort and unique if filenames are NOT requested
  echo "$OUTPUT" | tr ' ' '\n' | sort -u
else
  # don't sort, show matched output (possibly tagged with filenames)
  echo "$OUTPUT" | tr ' ' '\n'
fi

# compute total number of files
let TOTAL=FOUND+ERRORS


# summarize
echo "Found "$XPATH" in $FOUND/$TOTAL"
echo
echo -e Found:${FOUNDLIST}
echo
echo -e Not Found:${NOTFOUNDLIST}
