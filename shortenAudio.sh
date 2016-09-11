#!/usr/bin/env bash

# For noisier environments, increase the percentage.
# If its too high, start/end of quiet words are cut.
# Good range for most audio books, 0.5% 2.5%
# Try the first chapter of each book to get the right value.
# The higher value, without noticable word cuts, the more scilence is stripped.
sensitivity=1.0%

# After cutting out the pauses, how much faster should the recording be?
# Reasonable range: 1.0 1.5
speedup=1.3

### end of config area ##

. helper.sh

checkexists lame
checkexists mp3info
checkexists sox
checkexists calc

in=/tmp/in.wav
out=/tmp/out.wav

outdir=./

if [ -n "$1" ] && [ "$1" == "--outdir" ] && [ -n "$2" ]; then
    outdir="$2"
    shift; shift;
    mkdir -p "$outdir"
fi

# Process the files given on the commandline.
while [ -n "$1" ]; do
    file="$1"
    echo "processing $file"
    lb=$(mp3info -p '%S' "$file")
    lame --silent --decode $file $in
    sox -q --norm $in $out silence 1 0.01 $sensitivity -1 0.1 $sensitivity \
        tempo -s $speedup
    lame --silent -B 32 $out "${outdir}/trimmed.$file"
    la=$(mp3info -p '%S' "${outdir}/trimmed.$file")
    p=$(calc "round( ($la / $lb) * 100,2)")
    echo "trimmed version is ${p}% of original."
    shift
done

if [ -e "$in" ]; then
    rm $in
fi
if [ -e "$out" ]; then
    rm $out
fi
