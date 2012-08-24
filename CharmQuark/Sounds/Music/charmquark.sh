#!/bin/bash

DURATION=38.452245
FILENAME=CharmQuark.m4a
VOLUME=1

while true 
do

afplay -v $VOLUME $FILENAME &
sleep $DURATION

done

echo
