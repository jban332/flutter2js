#!/bin/sh

build () {
	echo "Running 'pub run webdev build' in:"
	echo ""
	echo "  $1"
	echo ""
	(cd $1 && pub run webdev build)
}

build examples/hello_world-browser
