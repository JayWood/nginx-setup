#!/bin/bash

if [ "$(id -u)" != "0" ]; then
	echo "This script must be ran as root."
	exit 1
fi

# Setup some config vars
poolDir="/etc/php5/fpm/pool.d"
vHostDir="/etc/nginx/sites-available"
vHostLinks="/etc/nginx/sites-enabled"

# Get the main directory of the script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Some globals for later
username=""
domain=""
htPass=""

# A few colors for important stuff
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Creates a random password using the built-in urandom
randomPW(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;}

# Validates the username against some regex.
isValidUsername() {
	local re='^[[:lower:]_][[:lower:][:digit:]_-]{2,15}$'
 	(( ${#1} > 16 )) && return 1
 	[[ $1 =~ $re ]] # return value of this comparison is used for the function
}

# Wrapper for displaying error messages
error() {
	echo -e "${RED}ERROR:${NC} $1"
	echo
}

# Wrapper for displaying success messages
success() {
	echo -e "${GREEN}$1${NC}"
	echo
}

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

#copy the resource TPL file and move it
cp "$DIR/files/vhost.tpl" "$hostFile"

# Replace username with username in the vhost file
replace "%USER%" "$username" -- "$hostFile"

# Replace the domain now.
replace "%DOMAIN%" "$domain" -- "$hostFile"

# Make the website directory now.
mkdir "/home/$username/html/$domain" && chown "$username:$username" "/home/$username/html/$domain";

success "You're all setup, would you like to password this install, \nenter a password now, or just hit [ENTER] to skip this step."
read passInstall

if [[ -z "${passInstall// }" ]]; then
	replace "auth_basic" "#auth_basic" -- "$hostFile"
else
	# Create passwd file
	htpasswd "/home/$username/.htpasswd" "$username" passInstall
fi

