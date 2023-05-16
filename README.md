# Bash Recycle Bin

Recycle and restore script using bash

# Introduction

UNIX has no recycle bin at the command line. When you remove a file or directory, it is gone and cannot be restored. This project is to write a recycle script and a restore script. This will provide users with a recycle bin which can be used to safely delete and restore files.

# Basic Functionality of Recycle

This script mimics the `rm` command. But instead of deleting the file, this script moves it to a recyclebin directory called recyclebin located in your home directory.

1. The script name is recycle and will be stored in `$HOME/project`.
2. The recycle bin is `$HOME/recyclebin`.
3. Entering `bash recycle fileName` will recycle the file.
4. The test for error conditions mimics the `rm` command, which contains:

   a) No filename provided

   b) File does not exist

   c) Directory name provided instead of a filename

   d) Filename provided is `recycle`. In this case, display the error message:

   `Attempting to delete recycle – operation aborted`

   and terminate the script with a non-zero exit status.

5. The filenames in the recyclebin, will be in the following format:

   ```
   fileName_inode
   ```

   For example, if a file named `f1` with inode `1234` is recycled, the file in the recyclebin will be named `f1_1234`. This gets around the potential problem of deleting two files with the same name. The recyclebin will only contain files, not directories.

6. A `.restore.info` file is created in `$HOME`. Each line of this file contains the name of the file in the recyclebin, followed by a colon, followed by the original absolute path of the file.

   For example, if a file called `f1`, with an inode of `1234` was recycled from the `/home/trainee1` directory, `.restore.info` will contain:

   ```
   f1_1234:/home/trainee1/f1
   ```

   If another file named `f1`, with an inode of `5432`, was recycled from the `/home/trainee1/testing` directory, then `.restore.info` will contain:

   ```
   f1_1234:/home/trainee1/f1
   f1_5432:/home/trainee1/testing/f1
   ```

# Basic Functionality of Restore

This script restores individual files back to their original location.
The user will determine which file is to be restored and use the file name with inode number in order to restore the file. For example: `bash restore f1_1234`

1. Script name is restore and stored in `$HOME/project`
2. The file to be restored is a command line argument and the script is executed as follows:

   ```
   bash restore f1_1234
   ```

   `f1_1234` is the name of the file in `$HOME/recyclebin`.

3. The file is restored to its original location, using the pathname stored in the `.restore.info` file.

4. The script tests for the following error conditions and display similar error messages to the rm command:

   a) No filename provided - Display an error message if no file provided as argument, and set an error exit status.

   b) File does not exist - Display an error message if file supplied does not exist, and terminate the script.

5. The script checks whether the file being restored already exists in the target directory. If it does, the user will be asked

   `Do you want to overwrite? y/n`

   The script restores the file if the user types `y`, `Y`, or any word beginning with y or Y to this prompt, and not restore it if they type anything else.

6. After the file has been successfully restored, the entry in the .restore.info file will be deleted.

# Multiple Files and Option Flags

The recycle script has the following options:

1. `–r`: Recursively remove files in directories.
2. `–i`: Prompt the user, asking for confirmation.
3. `-v`: Display a message showing deleted files.

The restore script has the following options:

1. `–r`: Recursively restore files.
