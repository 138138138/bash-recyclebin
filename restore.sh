#!/bin/bash

input="$1"

# No filename provided
if [ -z "$input" ]
then
    echo "No filename provided."
    exit 1
fi

# check the file in recyclebin
# find the word "f1_1234:" with colon at the end
inputWColon="$input":
if [ "$(grep "$inputWColon" "$HOME/.restore.info" | wc -l)" != "1" ]
then
    echo "File does not exist."
    exit 1
fi
fileRecord="$(grep "$inputWColon" "$HOME/.restore.info")"

# get original file path
destPath="$(echo "$fileRecord" | sed "s/$inputWColon//")"

# create directory if not exists
if [ ! -d "$(dirname "$destPath")" ]
then
    mkdir "$(dirname "$destPath")"
fi

# check file on restore path exists
if [ -f "$destPath" ]
then
    # check if want to overwrite
    echo -n "Do you want to overwrite? y/n "
    read choice
    if [ "${choice:0:1}" != "y" ] && [ "${choice:0:1}" != "Y" ]
    then
        exit
    fi
fi

# move the file
mv "$HOME/recyclebin/$input" "$destPath"

# delete the record line with filename
sed -i "/$inputWColon/d" "$HOME/.restore.info"
