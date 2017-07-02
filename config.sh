#!/bin/bash

# Setup some config vars
poolDir="/etc/php5/fpm/pool.d"
vHostDir="/etc/nginx/sites-available"
vHostLinks="/etc/nginx/sites-enabled"

# A few colors for important stuff
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

#
#
#
#
#
# STOP EDITING
#
#
#
#
#

# Get the main directory of the script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Some globals for later
username=""
domain=""
htPass=""

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