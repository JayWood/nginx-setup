#!/bin/bash

if [ "$(id -u)" != "0" ]; then
	echo "This script must be ran as root."
	exit 1
fi

# Setup some config vars
poolDir="/etc/php5/fpm/pool.d"
vHostDir="/etc/nginx/sites-available"
vHostLinks="/etc/nginx/sites-enabled"
username=""

# A few colors for important stuff
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color


isValidUsername() {
	local re='^[[:lower:]_][[:lower:][:digit:]_-]{2,15}$'
 	(( ${#1} > 16 )) && return 1
 	[[ $1 =~ $re ]] # return value of this comparison is used for the function
}

error() {
	echo -e "${RED}ERROR:${NC} $1"
	echo
}

getUser () {
	# Sets up the user from the start.
	echo "Please enter the username desired."
	read username

	if isValidUsername "$username"; then
		if [ -d "/home/$username" ]; then
			error "The user $username already exists, please choose another."
			getUser
		fi
	else
		error "$username is not a valid username"
		getUser
	fi
}


getUser