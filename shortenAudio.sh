#!/usr/bin/env bash

# For noisier environments, increase the percentage.
# If its too high, start/end of quiet words are cut.
# Good range for most audio books, 0.5% 2.5%
# Try the first chapter of each book to get the right value.
# The higher value, without noticable word cuts, the more scilence is stripped.
sensitivity=1%

# After cutting out the pauses, how much faster should the recording be?
# Reasonable range: 1.0 1.5
speedup=1.3

### end of config area ##

. $(dirname $(readlink -f $0))/helper.sh

checkexists ffmpeg
checkexists mp3info
checkexists sox
checkexists calc

outdir=.

if [ -n "$1" ] && [ "$1" == "--outdir" ] && [ -n "$2" ]; then
    outdir="$2"
    shift; shift;
    mkdir -p "$outdir"
fi

# Process the files given on the commandline.
while [ -n "$1" ]; do
    file="$1"
    tmp1=$(mktemp -u /tmp/in-XXXXX.wav)
    tmp2=$(mktemp -u /tmp/out-XXXXX.wav)
    echo "processing $file"
    lb=$(mp3info -p '%S' "$file")
    ffmpeg -loglevel quiet -i $file $tmp1
    sox $tmp1 $tmp2 norm -0.1
    sox -q --norm $tmp2 $tmp1 silence 1 0.01 $sensitivity -1 0.1 $sensitivity \
        tempo -s $speedup
    ffmpeg -loglevel quiet -i $tmp1 -y "${outdir}/trimmed.$file"
    la=$(mp3info -p '%S' "${outdir}/trimmed.$file")
    p=$(calc "round( ($la / $lb) * 100,2)")
    echo "trimmed version is ${p}% of original."
    rm $tmp1 $tmp2
    shift
done

