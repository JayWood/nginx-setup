#!/bin/bash

# Get the main directory of the script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "$DIR/config.sh"

echo "Define Username"
read username

sh "$DIR/add-user.sh" -u "$username"