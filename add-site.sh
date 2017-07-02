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

showHelp() {
cat << EOF
${GREEN}Usage: ${0##*/} -u USERNAME -h DOMAIN...${NC}
Create a website and resource pool for DOMAIN for USERNAME

	-u USERNAME   Usernames are limited to 0-9A-Za-z_-
	-h DOMAIN     Excluding http:// eg. mysite.com

EOF
}

# Require options to be setup.
if [[ ! $@ =~ ^\-.+ ]]
then
  showHelp
fi