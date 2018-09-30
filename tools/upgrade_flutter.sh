cd `dirname $0`/../
SRC_FLUTTER=../flutter/packages/flutter
DEST_FLUTTER=packages/flutter

# TODO: A script that copies everything except certain files

echo "Removing old files"
rm packages/flutter/lib/src/physics/*

echo "Copying new files from '../flutter'"
cp $SRC_FLUTTER/lib/physics.dart $DEST_FLUTTER/lib/

cp $SRC_FLUTTER/lib/src/physics/* $DEST_FLUTTER/lib/src/physics/

echo "Replacing occurences of 'dart:ui'"
find ./ -iname "*.dart" -exec sed 's/dart:ui/package:flutter\/ui\.dart/g' {} +


