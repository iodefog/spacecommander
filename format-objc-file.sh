#!/usr/bin/env bash
# format-objc-file.sh
# Formats an Objective-C file, replacing it without a backup.
# Copyright 2015 Square, Inc

export CDPATH=""
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [ ! -e ".clang-format" ]; then
	echo "Couldn't find .clang-format file, unable to format files. Please setup this repo by running the setup-repo.sh script from your repo's top level."
	echo "Also, formatting scripts should be run from the repo's top level dir."
	exit 1
fi

# "#pragma Formatter Exempt" means don't format this file
line="$(head -1 "$1" | xargs)" # (read the first line and trim it)
[ "$line" == "#pragma Formatter Exempt" ] && exit 0

# Fix an edge case with array / dictionary literals that confuses clang-format
python "$DIR"/custom/LiteralSymbolSpacer.py "$1"
# The formatter gets confused by C++ inline constructors that are broken onto multiple lines
python "$DIR"/custom/InlineConstructorOnSingleLine.py "$1"
# Add a semicolon at the end of simple macros
python "$DIR"/custom/MacroSemicolonAppender.py "$1"
# Add an extra newline before @implementation and @interface
python "$DIR"/custom/DoubleNewlineInserter.py "$1"

# Run clang-format
"$DIR"/bin/clang-format-3.7 -i -style=file "$1" ;

# Add a newline at the end of the file
python "$DIR"/custom/NewLineAtEndOfFileInserter.py "$1"
