#!/bin/bash

# Get the main directory of the script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "$DIR/config.sh"

showHelp() {
cat << EOF
Usage: ${0##*/} -u USERNAME -h DOMAIN...
Create a website and resource pool for DOMAIN for USERNAME

	-u USERNAME   Usernames are limited to 0-9A-Za-z_-
	-h DOMAIN     Excluding http:// eg. mysite.com

EOF
}

# Require options to be setup.
if [[ ! $@ =~ ^\-.+ ]]
then
  showHelp
  exit
fi

while [[ $# -gt 1 ]]; do
	key="$1"
	case $key in
	    -u|--username)
	    username="$2"
	    shift # past argument
	    ;;
	    -h|--host)
	    domain="$2"
	    shift # past argument
	    ;;
	    *)
	      # Skip this option, nothing special
	    ;;
	esac
	shift # past argument or value
done

# Chances are if we can't validate the name, then the user doesn't exist.
if [ ! isValidUsername "$username"]; then
	error "$username is not a valid username."
	exit 1
fi

# If the user doesn't have a home directory, there's no need to continue.
if [ ! -d "/home/$username" ]; then
	error "The user $username appears to not be created?"
	exit 1
fi

# We must have the /files directory
if [ ! -d "$DIR/files" ]; then
	error "The required files directory is not at $DIR/files"
	exit 1
fi

# Will resuse this below
hostFile="$vHostDir/$domain"

# Copy the resource TPL file and move it
cp "$DIR/files/vhost.tpl" "$hostFile"

# Replace username with username in the vhost file
replace "%USER%" "$username" -- "$hostFile"

# Replace the domain now.
replace "%DOMAIN%" "$domain" -- "$hostFile"

# Make the website directory now.
mkdir "/home/$username/html/$domain" && chown "$username:$username" "/home/$username/html/$domain";

# Create the .d directory for this domain. Will store subdomains there.
mkdir "$vHostDir/$domain.d"


# TODO Setup htaccess auth properly.
# 
# Ideally it would go like this:
# 
# Do you want to setup htaccess for this install?
# 	IF YES
# 		Check for existing htaccess password
# 			IF EXISTS
# 				Ask if a new user should be made?
# 				IF YES
# 					PROMPT create new user
# 				ENDIF
# 			ELSE
# 				PROMP create new user
# 			ENDIF
# 	ELSE
# 		REPLACE auth_basic in vhost file
# 
# PROMPT create new user
# INPUT username
# 	VALIDATE username
# 	IF FALSE then
# 		INPUT username
# 	ENDIF
# 	
# INPUT password
# 	VALIDATE password
# 	IF FALSE then
# 		INPUT username
# 	ENDIF
# 		
# 		
# success "You're all setup, would you like to password this install, \nenter a password now, or just hit [ENTER] to skip this step."
# read passInstall

# # Trim the result
# passInstall="${passInstall// }"

# if [[ -z $passInstall ]]; then
# 	echo "Disabling basic_auth on host file..."
# 	replace "auth_basic" "#auth_basic" -- "$hostFile"
# else
# 	# Create passwd file
# 	htpasswd -b "/home/$username/.htpasswd" "$username" "$passInstall"

# 	echo "Setting host file for authoriazation..."
# 	replace "#auth_basic" "auth_basic" -- "$hostFile"
# fi

