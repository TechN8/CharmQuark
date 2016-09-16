#!/bin/bash -x

INKSCAPE=/Applications/Inkscape.app/Contents/Resources/bin/inkscape
INPUT=`pwd`/../Artwork/AppIcon.svg
OUTPUT=`pwd`/../Images.xcassets/AppIcon.appiconset

FILENAME=Icon-29.png
SIZE=29
$INKSCAPE --file="$INPUT" --export-png="$OUTPUT/$FILENAME" --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

FILENAME=Icon-29@2x.png
SIZE=58
$INKSCAPE --file="$INPUT" --export-png="$OUTPUT/$FILENAME" --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

FILENAME=Icon-40.png
SIZE=40
$INKSCAPE --file="$INPUT" --export-png="$OUTPUT/$FILENAME" --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

FILENAME=Icon-40@2x.png
SIZE=80
$INKSCAPE --file="$INPUT" --export-png="$OUTPUT/$FILENAME" --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

FILENAME=Icon-57.png
SIZE=57
$INKSCAPE --file="$INPUT" --export-png="$OUTPUT/$FILENAME" --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

FILENAME=Icon-57@2x.png
SIZE=114
$INKSCAPE --file="$INPUT" --export-png="$OUTPUT/$FILENAME" --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

FILENAME=Icon-60@2x.png
SIZE=120
$INKSCAPE --file="$INPUT" --export-png="$OUTPUT/$FILENAME" --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

FILENAME=Icon-50.png
SIZE=50
$INKSCAPE --file="$INPUT" --export-png="$OUTPUT/$FILENAME" --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

FILENAME=Icon-50@2x.png
SIZE=100
$INKSCAPE --file="$INPUT" --export-png="$OUTPUT/$FILENAME" --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

FILENAME=Icon-72.png
SIZE=72
$INKSCAPE --file="$INPUT" --export-png="$OUTPUT/$FILENAME" --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

FILENAME=Icon-72@2x.png
SIZE=144
$INKSCAPE --file="$INPUT" --export-png="$OUTPUT/$FILENAME" --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

FILENAME=Icon-76.png
SIZE=76
$INKSCAPE --file="$INPUT" --export-png="$OUTPUT/$FILENAME" --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

FILENAME=Icon-76@2x.png
SIZE=152
$INKSCAPE --file="$INPUT" --export-png="$OUTPUT/$FILENAME" --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

FILENAME=Icon-83.5@2x.png
SIZE=167
$INKSCAPE --file="$INPUT" --export-png="$OUTPUT/$FILENAME" --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

FILENAME=Icon-1024.png
SIZE=1024
$INKSCAPE --file="$INPUT" --export-png=$FILENAME --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect

#iTunesArtwork
FILENAME=iTunesArtwork
SIZE=512
$INKSCAPE --file="$INPUT" --export-png=$FILENAME --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect
cp $FILENAME Icon-512.png
