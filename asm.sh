#!/bin/bash
export DEFSDIR=./defs
export DEFSDIR2=/Volumes/Projects/OS9/cbos9/defs
export DEFSDIR3=~/Projects/OS9/cbos9/defs
xasm -i=. -i=$DEFSDIR -i=$DEFSDIR2 -i=$DEFSDIR3 -o=modules/$(basename $1) $1
