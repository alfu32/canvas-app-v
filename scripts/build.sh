#!/bin/bash
BUILD_RUNDATE=$(date '+%Y-%m-%d %H:%M:%S')
GIT_COMMIT=$(git rev-parse HEAD)
GIT_BRANCH="$(git branch | egrep "^\* ")"
GIT_TAG=($(git tag --points-at HEAD))

rm -rf bin
mkdir bin

v src/ -o bin/main
v src/ -o bin/main.c
v src/ -o bin/main.js
echo "
release
 BUILD_RUNDATE  : $BUILD_RUNDATE
    GIT_COMMIT  : $GIT_COMMIT
    GIT_BRANCH  : $GIT_BRANCH
       GIT_TAG  : $GIT_TAG
" >> bin/rel.txt