#!/bin/bash

if [ "$(id -u)" != "0" ]; then
	echo "This script must be ran as root."
	exit 1
fi