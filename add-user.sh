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

showHelp