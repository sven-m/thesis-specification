#!/bin/bash

usage()
{
  cat << EOF
usage: $CALL_SIGNATURE <options>

Infer schema from XML documents using Trang

OPTIONS:
  [-h]
      this message

  -i <directory>
      specify source directory containing the XML files to derive a schema from

  -o <schema filename>
      define the filename for the generated schema file

  -m <mode string>
      Define inference mode:
      -m disable-abstract-elements
        Disables the use of abstract elements and subsitution groups in the
        generated XML Schema. This can also be controlled using an annotation
        attribute.
      -m any-process-contents=strict|lax|skip
        Specifies the value for the processContents attribute of any elements.
        The default is skip (corresponding to RELAX NG semantics) unless the
        input format is dtd, in which case the default is strict (corresponding
        to DTD semantics).
      -m any-attribute-process-contents=strict|lax|skip
        Specifies the value for the processContents attribute of anyAttribute
        elements. The default is skip (corresponding to RELAX NG semantics).

EOF
}

INPUT_DIR=
OUTPUT_DIR=
MODE=
while getopts "hi:o:m:" OPTION
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
      OUTPUT_FILE="`realpath "${OPTARG%.xsd}"`"
      ;;
    m)
      MODE="-o $OPTARG"
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

# perform schema inference

if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_FILE" ]
then
  usage
  exit
fi

SCHEMA_FILE="$OUTPUT_FILE.xsd"
echo "Processing files for $SCHEMA_FILE"

for xmlFile in "$INPUT_DIR"/*.xml
do
  echo "  $xmlFile"
done

echo $TOOLS_DIR
java -jar "$TOOLS_DIR"/../engines/trang-20081028/trang.jar $MODE "$INPUT_DIR"/*.xml "$SCHEMA_FILE"


