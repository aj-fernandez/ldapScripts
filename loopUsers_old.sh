#!/bin/bash

# @author: ajfernandez
# @date: 27-10-18
#
# Using the script for create user by user "addUser" i wrote "loopUsers" for to
# create users in batch, but we must known that "addUser" create one file per
# user, due to this, we have to merge all of this files in one (we doing this
# in for loop with "find" and "cat").
#
# Usage: #> loopUser numberUsers nameUser name-common departmenName-common
#   e.g: #> loopUser 9 usuario-w RRHH Contrataciones
#
#	Result: usuario-w1 to usuario-w9


readonly TARGET_FILE="./loopUsers.ldif" # for easy change of target file

for (( i = 1; i <= $1; i++ )); do
	./addUser \-u $2"$i" \-g 10000  \-l user \-i 200"$i" \-p Admin1234 \-f $3 \-d $4
done

printf "\n%d users created\nMerging all files...\n" "$1"

if [[  -f "$TARGET_FILE" ]]; then 				# If files already exists we have to create backup of these
        mv "$TARGET_FILE" "$TARGET_FILE".`date "+%d-%m-%Y-%H:%M"`
fi

touch "$TARGET_FILE"

for j in `find . -maxdepth 1 -type f -name ""$2"?*.ldif"`; do # I Use ?* because i dont know if will be 1 or 2 digits,
								   # if there are more than 99 users i should change that.
	cat $j >> "$TARGET_FILE" && printf "\n" >> "$TARGET_FILE"    # Here we merge all files in target and put a blank line
						 		     # (there must be a blank line between objects in .ldif files)
done

printf "File \"loopUsers.ldif\" is ready for upload to LDAP\n\n"
