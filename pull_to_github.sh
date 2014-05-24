#!/bin/sh

Usage()
{
	echo "Usage: $0 'commit content'"
}

if [ $# != 1 ]; then
	Usage
	exit 1
else
	git add .
	git commit -m "$1"
	git push -f origin master
fi
