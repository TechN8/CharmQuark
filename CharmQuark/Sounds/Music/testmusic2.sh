#!/bin/bash

RANGE=8
LAST_INTENSITY=0
INTENSITY=0
LIO=0
IO=0
VOLUME=1

#afplay -v $VOLUME Intro.m4a &
#sleep 8

for i in $@;
do
FILENAME="Intensity${i}.m4a"
echo $FILENAME
afplay -v $VOLUME $FILENAME &
sleep 8
done
