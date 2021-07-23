#!/bin/bash
if [ $# -eq 0 ] || [ $# -ne 3 ];
then
	echo 'Usage: ./diff.sh <dictionary file> <input file> <reference file>'
	echo 'This script will run a diff between your given input and output with a given dictionary.'
	echo 'It expects 3 arguments (separated by spaces):'
	echo '1. your dictionary file (the one given to you is replace.txt)'
	echo '2. your input file (the one given to you is test.txt)'
	echo '3. your reference file which your input file should match (the one given to you is reference.txt)'
	echo 'To run everything with the defaults, just use make test.'
	echo 'Use this script if you have other dictionaries, inputs, and references you want to test things on.'
	echo 'Note, this script will only work on the Hive or on most Mac/Linux machines.'
	exit
fi;

make
echo "Starting $0..."
diff <(./philphix $1 < $2 2> /dev/null) <(cat $3)
echo "End of $0"
echo 'If you saw nothing between the start and end of the diff, that means your reference file matches your philphix output'
