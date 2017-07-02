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
domain=""
htPass=""

# A few colors for important stuff
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Creates a random password using the built-in urandom
randomPW(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;}

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
fi

while [[ $# -gt 1 ]]
do
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

echo "${username} and ${domain}"

