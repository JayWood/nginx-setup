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
echo ${DIR}

# Some globals for later
username=""
sshPass=""
htPass=""

# A few colors for important stuff
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Validates the username against some regex.
isValidUsername() {
	local re='^[[:lower:]_][[:lower:][:digit:]_-]{2,15}$'
 	(( ${#1} > 16 )) && return 1
 	[[ $1 =~ $re ]] # return value of this comparison is used for the function
}

# Creates a random password using the built-in urandom
randomPW(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;}

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

# Creates all user directories.
setupUser() {
	success "Creating directories for ${username}"
	useradd -m "${username}"
	base="/home/${username}"
	sshPass=randomPW

	# Set the users password.
	echo -e "${sshPass}\n${sshPass}" | passwd "${username}"

	# The main dirs
	mkdir "${base}/log"
	mkdir "${base}/html"
	mkdir "${base}/tmp"
	mkdir "${base}/run"
}

getUser () {
	# Sets up the user from the start.
	echo "Please enter the username desired."
	read username

	if isValidUsername "$username"; then
		if [ -d "/home/$username" ]; then
			error "The user $username already exists, please choose another."
			getUser
		else
			setupUser
		fi
	else
		error "$username is not a valid username"
		getUser
	fi
}


getUser