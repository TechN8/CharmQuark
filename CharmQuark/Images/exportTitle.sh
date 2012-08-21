#!/bin/bash -x

INPUT_FILE=../Artwork/MainTitle.svg

INKSCAPE=/Applications/Inkscape.app/Contents/Resources/bin/inkscape

EXPORT_DIR=Titles
IPAD_DIR=$EXPORT_DIR/iPad
IPAD_DPI=90
IPADHD_DIR=$EXPORT_DIR/iPad-hd
IPADHD_DPI=180
IPHONE_DIR=$EXPORT_DIR/iPhone
IPHONE_DPI=42.19
IPHONEHD_DIR=$EXPORT_DIR/iPhone-hd
IPHONEHD_DPI=84.38

PNG_IDS='title-text title-glow title-flash'

mkdir -p $IPAD_DIR $IPADHD_DIR $IPHONE_DIR $IPHONEHD_DIR

export LANG=C

for i in $PNG_IDS; do
$INKSCAPE --export-png=$IPAD_DIR/$i.png --export-background-opacity=0 --export-dpi=$IPAD_DPI --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=$IPADHD_DIR/$i.png --export-background-opacity=0 --export-dpi=$IPADHD_DPI --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=$IPHONE_DIR/$i.png --export-background-opacity=0 --export-dpi=$IPHONE_DPI --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=$IPHONEHD_DIR/$i.png --export-background-opacity=0 --export-dpi=$IPHONEHD_DPI --export-id=$i --export-id-only $INPUT_FILE
done;

# Export bird
#i=twitter-bird
#
#$INKSCAPE --export-png=$IPAD_DIR/$i.png --export-background-opacity=0 --export-dpi=$IPAD_DPI --export-id=$i --export-id-only $INPUT_FILE
#$INKSCAPE --export-png=$IPADHD_DIR/$i.png --export-background-opacity=0 --export-dpi=$IPADHD_DPI --export-id=$i --export-id-only $INPUT_FILE
#$INKSCAPE --export-png=$IPHONE_DIR/$i.png --export-background-opacity=0 --export-dpi=$IPHONE_DPI --export-id=$i --export-id-only $INPUT_FILE
#$INKSCAPE --export-png=$IPHONEHD_DIR/$i.png --export-background-opacity=0 --export-dpi=$IPHONEHD_DPI --export-id=$i --export-id-only $INPUT_FILE
