#!/bin/bash

# @author: ajfernandez
# @date: 27-10-18
#
# With this script we can create user by user her corresponding *.ldif
# file for add later to our LDAP server.
#
# For an unattended use of this script i decided to use parameters instead
# of "read" method (in whose case we need an human typing) and therefore
# we can integrate this code in a other automatized workflows that we will call "loopUsers".
#
# e.g: ./addUser -f Agustin -l Fernandez -u ajfernandez -g 10000 -p Admin1234 -e a@b.c -a The\ Solar\ System -t 67676767 -d IT

readonly SHELL=/bin/bash

function help { # This function show the usage of the script and which parameters are mandatory
    cat << EOF
Usage:  addUser -f FirstName -l LastName -u username -g groupid -p password -e email -a address -t telephone number -d department

List of arguments:
    -f: FirstName
    -l: Lastname (REQUIRED)
    -a: Address
    -t: telephone number
    -e: user email address
    -g: numeric groupid (REQUIRED)
    -p: password
    -u: username (cn:) (REQUIRED)
    -d: department

Import file to LDAP Directory with Administrator account:

    ldapadd -x -D "cn=admin,dc=2cfs-w,dc=com" -W -f ./$USERNAME.ldif

EOF

    exit 0
}

while getopts a:d:e:f:g:l:p:t:u:h FLAG # getopt (without "s") is newer and powerfull, change this !!!
do
    case $FLAG in		# join each parameter with the argument passed with the command
        a) ADDR=$OPTARG;;
	d) DEPART=$OPTARG;;
        e) EMAIL=$OPTARG;;
        f) FIRSTNAME=$OPTARG;;
        g) GROUPID=$OPTARG;;
        l) LASTNAME=$OPTARG;;
        p) PASSWORD=$OPTARG;;
        t) TPHONE=$OPTARG;;
        u) USERNAME=$OPTARG;;
        h) help;;
    esac
done

# This line search in our LDAP all users values, for later, using pipes to proccess the output among various commands until
# we get the last uidNumber used, by this way, adding +1 we get the uidNumber for the user to add.
LAST_UIDNUMBER=$((`ldapsearch -LLL  -h 192.168.2.200 -p 389 -D "cn=admin,dc=2cfs-w,dc=com" -w  Admin1234 -b "dc=2cfs-w,dc=com"\
 "(&(uidNumber=*)(gidNumber=10000))" | grep uidNumber | sort -k2 | cut -d: -f2 | tail -1` + 1))

[[  -z "$USERNAME" ]] && help # Check mandatory parameters for our object
[[  -z "$GROUPID" ]] && help  # and if someone of this variables are empty: show usage again an exit
[[ -z "$LASTNAME" ]] && help

if [[  -f ./"$USERNAME".ldif ]]; then 	# If exist a file with same name we must rename it
	mv ./"$USERNAME".ldif "$USERNAME".ldif.`date "+%d-%m-%Y-%H:%M:%S"`
fi

touch ./"$USERNAME".ldif # Creation of a file with the name of user to store the data and to add later to LDAP

# Print LDIF for user account inside a file adding line per line
printf 'dn: cn=%s,cn=grupo-w,ou=unidad-w,dc=2cfs-w,dc=com\n' "$USERNAME" >> ./"$USERNAME".ldif
printf 'objectClass: person\n' >> ./"$USERNAME".ldif
printf 'objectClass: inetOrgPerson\n' >> ./"$USERNAME".ldif  # Mandatory to set: UID, HOMEDIR, UIDNUM, GIDNUM and CN.
printf 'objectClass: posixAccount\n' >> ./"$USERNAME".ldif # Integration with /etc/passwd of POSIX systems
printf 'objectClass: shadowAccount\n' >> ./"$USERNAME".ldif  # Integration with /etc/shadow of POSIX systems
printf 'objectClass: top\n' >> ./"$USERNAME".ldif
printf 'cn: %s %s\n' "$USERNAME" >> ./"$USERNAME".ldif
printf 'givenName: %s\n' "$FIRSTNAME" >> ./"$USERNAME".ldif
printf 'sn: %s\n' "$LASTNAME" >> ./"$USERNAME".ldif
printf 'uid: %s\n' "$USERNAME" >> ./"$USERNAME".ldif
printf 'uidNumber: %d\n' "$LAST_UIDNUMBER" >> ./"$USERNAME".ldif
printf 'gidNumber: %d\n' "$GROUPID" >> ./"$USERNAME".ldif
printf 'loginShell: %s\n' "$SHELL" >> ./"$USERNAME".ldif
printf 'gecos: %s %s\n' "$FIRSTNAME" "$LASTNAME" >> ./"$USERNAME".ldif
printf 'userPassword: %s\n' "$PASSWORD" >> ./"$USERNAME".ldif
printf 'homeDirectory: /home/%s\n' "$USERNAME" >> ./"$USERNAME".ldif
printf 'mail: %s\n' "$EMAIL" >> ./"$USERNAME".ldif
printf 'telephoneNumber: %d\n' "$TPHONE" >> ./"$USERNAME".ldif
printf 'postalAddress: %s\n' "$ADDR" >> ./"$USERNAME".ldif
printf 'departmentNumber: %s\n' "$DEPART" >> ./"$USERNAME".ldif # See at rfc 2798 -new attribute types in the inetOrgPerson Objet Class

printf '\nAdding new user "%s" to LDAP owned by AJFernandez, Pablo Alcaide\n' "$USERNAME"
ldapadd -x -h 192.168.2.200 -D "cn=admin,dc=2cfs-w,dc=com" -w Admin1234 -f ./"$USERNAME".ldif # Adding the file to LDAP

# ldapsearch -xLLL -b "dc=2cfs-w,dc=com" uid=ajfernandez sn givenName cn --> Example of look up for a objectClass
# it find that "uid=" and for this object print the list of attributes passed: "sn" "givenName" and "cn" e.g
