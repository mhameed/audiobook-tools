#!/usr/bin/env bash

. helper.sh

checkexists mp3splt

mp3splt  -o @f_@n -a -p off=0 -t 72.00 ${1}
