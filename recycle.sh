#!/bin/bash

# create $HOME/recyclebin if not exist
if [ ! -d "$HOME/recyclebin" ]
then
    mkdir "$HOME/recyclebin"
fi

# separate options and filenames
options=()
filenames=()
directories=()
for input in "$@"
do
    if [ "${input:0:1}" == "-" ]
    then
        # is options
        # separate combined options, e.g. -iv
        for (( i=1; i<${#input}; i++ ))
        do
            options+=("-${input:$i:1}")
        done
    else
        # is files
        if [[ " ${options[*]} " =~ "-r" ]]
        then
            # check input is file or directory
            if [ -d "$input" ]
            then
                directories+=("$input")
                # add all files in directory to array
                allFiles="$(find "$input" -type f)"
                if [ ! -z "$allFiles" ]
                then
                    for i in "${allFiles[@]}"
                    do
                        filenames+=("$i")
                    done
                fi
            else
                filenames+=("$input")
            fi
        else
            # do not care if files or directories
            filenames+=("$input")
        fi
    fi
done

# check incorrect options
if [ ! -z "$options" ]
then
    for option in "${options[@]}"
    do
        if [ "$option" != "-r" ] && [ "$option" != "-v" ] && [ "$option" != "-i" ]
        then
            echo "recycle: invalid option -- '${option:1:1}'"
            exit 1  # stop the execution
        fi
    done
fi

# check No filename provided
if [ -z "$filenames" ] && [ -z "$directories" ]
then
    echo "recycle: missing operand"
    exit 1  # stop the execution
fi

exitStatus=0    # if any error, this will be set to 1

if [ ! -z "$filenames" ]
then
    for input in "${filenames[@]}"
    do
        # check input errors
        # When File does not exist, Directory name provided instead of a filename
        # display the error message from "rm" command
        if [ ! -d "$input" ] && [ ! -f "$input" ]
        then
            echo "recycle: cannot remove '$input': No such file or directory"
            exitStatus=1
            continue  # stop the execution for current input
        fi
        if [ -d "$input" ]
        then
            echo "recycle: cannot remove '$input': Is a directory"
            exitStatus=1
            continue  # stop the execution for current input
        fi

        # check if Filename provided is recycle
        inputRealPath="$(realpath "$input")"
        inputBaseName="$(basename -- "$inputRealPath")"
        if [ "$inputBaseName" == "recycle" ]
        then
            echo "Attempt to delete recycle - operation aborted"
            exitStatus=1
            continue  # stop the execution for current input
        fi

        # move the file to recyclebin and rename with the format fileName_inode
        inodeNo="$(stat -c %i "$input")"
        targetPath="$HOME/recyclebin/""$inputBaseName"_"$inodeNo"

        # -i flag: prompt before action
        if [[ " ${options[*]} " =~ "-i" ]];
        then
            echo -n "recycle: remove regular file '$input'? "
            read choice
            if [ "${choice:0:1}" != "y" ] && [ "${choice:0:1}" != "Y" ]
            then
                continue
            fi
        fi

        # move the file
        mv "$input" "$targetPath"

        # write into .restore.info
        # if not exist then create
        touch "$HOME/.restore.info"
        targetPathBaseName="$(basename -- "$targetPath")"
        echo "$targetPathBaseName":"$inputRealPath" >> "$HOME/.restore.info"

        # -v flag: print deleted
        if [[ " ${options[*]} " =~ "-v" ]];
        then
            echo "removed '$input'"
        fi
    done
fi

# delete directories
if [[ " ${options[*]} " =~ "-r" ]] && [ ! -z "$directories" ]
then
    for input in "${directories[@]}"
    do
        # -i flag: prompt before action
        if [[ " ${options[*]} " =~ "-i" ]];
        then
            echo -n "recycle: remove directory '$input'? "
            read choice
            if [ "${choice:0:1}" != "y" ] && [ "${choice:0:1}" != "Y" ]
            then
                continue
            fi
        fi

        rm -r "$input"

        # -v flag: print deleted
        if [[ " ${options[*]} " =~ "-v" ]];
        then
            echo "removed directory '$input'"
        fi
    done
fi

# exit status
if [ $exitStatus != 0 ]
then
    exit $exitStatus
fi
