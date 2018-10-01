#!/bin/sh

cd `dirname $0`/..
ARGS="$@"
SPACE_ARGS=""
if [ -n "$ARGS" ]; then
	SPACE_ARGS=" $ARGS"
fi

get () {
	echo "Running 'pub get$SPACE_ARGS' in:"
	echo ""
	echo "  $1"
	echo ""
	(cd $1 && pub get $ARGS)
}

get packages/flutter2js
get packages/flutter
get packages/flutter_test
get packages/flutter_localizations

# "Hello world"
get examples/hello_world
get examples/hello_world-browser

# "Stocks"
get examples/stocks
get examples/stocks-browser

