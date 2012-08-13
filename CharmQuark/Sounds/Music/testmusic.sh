#!/bin/bash

RANGE=8
LAST_INTENSITY=0
INTENSITY=0
LIO=0
IO=0
VOLUME=1

#afplay -v $VOLUME Intro.m4a &
#sleep 8

while true 
do

LAST_INTENSITY=$INTENSITY
let "LIO = $INTENSITY % 2"
INTENSITY=$RANDOM
let "INTENSITY %= $RANGE"
let "INTENSITY += 1"
let "IO = $INTENSITY % 2"

if [ "$IO" -eq "$LIO" ]
then
if [ "$IO" -eq "1" ] 
then
let "INTENSITY++";
else
let "INTENSITY--";
fi
fi

FILENAME=Intensity${INTENSITY}.m4a
#echo $FILENAME
echo -n "$INTENSITY "
afplay -v $VOLUME $FILENAME &
sleep 8

done

echo
