#!/bin/bash

# Get the main directory of the script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "$DIR/config.sh"

showHelp() {
cat << EOF
Usage: ${0##*/} -u USERNAME
Create a website and resource pool for DOMAIN for USERNAME

	-u USERNAME   Usernames are limited to 0-9A-Za-z_-

EOF
}

# Require options to be setup.
if [[ ! $@ =~ ^\-.+ ]]; then
	error "You must specify the -u parameter."
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
	    *)
	      # Skip this option, nothing special
	    ;;
	esac
	shift # past argument or value
done

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

	success "==========================================================="
	success "Make sure you save the username/password combo below."
	success "==========================================================="
	success "Login: $username"
	success "Password: $sshPass"
}

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