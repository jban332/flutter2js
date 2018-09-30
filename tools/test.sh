#!/bin/sh
cd `dirname $0`/../

test () {
	echo "Running 'pub run test' in:"
	echo ""
	echo "  $1"
	echo ""
	(cd $1 && pub get --offline --no-precompile && pub run test)
}

# Flutter2js
test packages/flutter2js

# Examples
test examples/hello_world-browser
