#!/bin/bash

readonly SCRIPTNAME=$(basename $0)

function help {
    cat << EOF
Usage: $SCRIPTNAME -n GROUPNAME (cn:) -g GROUPID (gidnumber:)

List of arguments:
    -n: Name for the group to set "cn: " attribute
    -g: Numeric groupid to set "gidNumber: " attribute
    -h: Show this message "(h)elp"

Import to LDAP Directory with Administrator account:

    ldapadd -x -D "cn=admin,dc=2cfs-w,dc=com" -W -f ./$GROUPNAME.ldif

EOF

    exit 0
}

while getopts n:g:h FLAG
do
    case $FLAG in
        n) GROUPNAME=$OPTARG;;
        g) GROUPID=$OPTARG;;
        h) help;;
    esac
done

# check parameters
[[ -z "$GROUPNAME" ]] && help
[[ -z "$GROUPID" ]] && help

if [[  -f ./"$GROUPNAME".ldif ]]; then
        mv ./"$GROUPNAME".ldif "$GROUPNAME".ldif.`date "+%d-%m-%Y-%H:%M:%S"`
fi
touch ./"$GROUPNAME".ldif

# Print LDIF for user account inside a file
printf 'dn: cn=%s,ou=unidad-w,dc=2cfs-w,dc=com\n' "$GROUPNAME" >> ./"$GROUPNAME".ldif
printf 'objectClass: posixGroup\n' >> ./"$GROUPNAME".ldif
printf 'objectClass: top\n' >> ./"$GROUPNAME".ldif
printf 'cn: %s\n' "$GROUPNAME" >> ./"$GROUPNAME".ldif
printf 'gidNumber: %d\n' "$GROUPID" >> ./"$GROUPNAME".ldif

# ldapsearch -xLLL -b "dc=2cfs-w,dc=com" uid=ajfernandez sn givenName cn --> Example of look up for a objectClass
# it find that "uid=" and for this object print the list of attributes passed: "sn" "givenName" and "cn" e.g
