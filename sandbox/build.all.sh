#!/bin/bash
for file in $(ls *.c);do gcc $file -o "${file%.*}.bin";done
