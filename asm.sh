#!/bin/bash
export DEFSDIR=./defs
export DEFSDIR2=/Users/cburke/Projects/OS9/cbos9/defs
xasm -i=. -i=$DEFSDIR -i=$DEFSDIR2 $1
