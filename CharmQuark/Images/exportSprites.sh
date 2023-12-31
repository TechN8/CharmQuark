#!/bin/bash -x

INPUT_FILE=../Artwork/SpriteWorksheet.svg

INKSCAPE=/Applications/Inkscape.app/Contents/Resources/bin/inkscape

EXPORT_DIR=Sprites
IPAD_DIR=$EXPORT_DIR/iPad
IPAD_DPI=78.75
IPAD_DPI_LO=52.1
IPADHD_DIR=$EXPORT_DIR/iPad-hd
IPADHD_DPI=157.5
IPADHD_DPI_LO=104.2
IPHONE_DIR=$EXPORT_DIR/iPhone
IPHONE_DPI=42.19
IPHONEHD_DIR=$EXPORT_DIR/iPhone-hd
IPHONEHD_DPI=84.38

IPHONE_SPRITES='white white-small lhcmap pause detector thumbguide firebutton blink graph track uparrow'
IPAD_SPRITES='white white-small lhcmap pause detector thumbguide firebutton blink graph track uparrow'
IPAD_SPRITES_LO='thumbguide firebutton'
PNG_IDS='window frame'

mkdir -p $IPAD_DIR $IPADHD_DIR $IPHONE_DIR $IPHONEHD_DIR

export LANG=C

for i in $IPHONE_SPRITES; do
$INKSCAPE --export-png=$IPHONE_DIR/$i.png --export-background-opacity=0 --export-dpi=$IPHONE_DPI --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=$IPHONEHD_DIR/$i.png --export-background-opacity=0 --export-dpi=$IPHONEHD_DPI --export-id=$i --export-id-only $INPUT_FILE
done;

for i in $IPAD_SPRITES; do
i=${i%%-ipad}
$INKSCAPE --export-png=$IPAD_DIR/$i.png --export-background-opacity=0 --export-dpi=$IPAD_DPI --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=$IPADHD_DIR/$i.png --export-background-opacity=0 --export-dpi=$IPADHD_DPI --export-id=$i --export-id-only $INPUT_FILE
done;

for i in $IPAD_SPRITES_LO; do
$INKSCAPE --export-png=$IPAD_DIR/$i.png --export-background-opacity=0 --export-dpi=$IPAD_DPI_LO --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=$IPADHD_DIR/$i.png --export-background-opacity=0 --export-dpi=$IPADHD_DPI_LO --export-id=$i --export-id-only $INPUT_FILE
done;

for i in $PNG_IDS; do
$INKSCAPE --export-png=${i}-ipad.png --export-background-opacity=0 --export-dpi=$IPAD_DPI --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=${i}-ipadhd.png --export-background-opacity=0 --export-dpi=$IPADHD_DPI --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=${i}.png --export-background-opacity=0 --export-dpi=$IPHONE_DPI --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=${i}-hd.png --export-background-opacity=0 --export-dpi=$IPHONEHD_DPI --export-id=$i --export-id-only $INPUT_FILE
done;

# Background
i=background
$INKSCAPE --export-png=${i}.png --export-background-opacity=0 --export-width=32 --export-height=32 --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=${i}-hd.png --export-background-opacity=0 --export-width=64 --export-height=64 --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=${i}-ipad.png --export-background-opacity=0 --export-width=64 --export-height=64 --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=${i}-ipadhd.png --export-background-opacity=0 --export-width=128 --export-height=128 --export-id=$i --export-id-only $INPUT_FILE
i=bg-gradient
$INKSCAPE --export-png=${i}.png --export-background-opacity=0 --export-width=4 --export-height=256 --export-id=$i --export-id-only $INPUT_FILE
