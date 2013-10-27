#!/bin/bash

# go through all files in first arg (should be directory)
for file in $(find $1 -name "*.xml")
do
  cp $file ${file}.bak \  # copy file to <orig>.bak
    && xmllint --format ${file}.bak > $file \  # format it, save it to <orig>
    && rm -f ${file}.bak # delete <orig>
done
