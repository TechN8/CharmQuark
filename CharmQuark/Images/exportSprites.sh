#!/bin/bash -x

INPUT_FILE=SpriteWorksheet.svg

#INKSCAPE=/Applications/Inkscape.app/Contents/Resources/script
INKSCAPE=/Applications/Inkscape.app/Contents/Resources/bin/inkscape

EXPORT_DIR=Sprites
IPAD_DIR=$EXPORT_DIR/iPad
IPAD_DPI=90
IPAD_DPI_LO=52.1
IPADHD_DIR=$EXPORT_DIR/iPad-hd
IPADHD_DPI=180
IPADHD_DPI_LO=104.2
IPHONE_DIR=$EXPORT_DIR/iPhone
IPHONE_DPI=42.19
IPHONEHD_DIR=$EXPORT_DIR/iPhone-hd
IPHONEHD_DPI=84.38

IPHONE_SPRITES='white white-small lhcmap pause detector thumbguide firebutton blink graph'
IPAD_SPRITES='white white-small lhcmap pause detector thumbguide firebutton blink graph'
IPAD_SPRITES_LO='thumbguide firebutton'
PNG_IDS='window'

mkdir -p $IPAD_DIR $IPADHD_DIR $IPHONE_DIR $IPHONEHD_DIR

export LANG=C

for i in $IPHONE_SPRITES; do
$INKSCAPE --export-png=$IPHONE_DIR/$i.png --export-dpi=$IPHONE_DPI --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=$IPHONEHD_DIR/$i.png --export-dpi=$IPHONEHD_DPI --export-id=$i --export-id-only $INPUT_FILE
done;

for i in $IPAD_SPRITES; do
i=${i%%-ipad}
$INKSCAPE --export-png=$IPAD_DIR/$i.png --export-dpi=$IPAD_DPI --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=$IPADHD_DIR/$i.png --export-dpi=$IPADHD_DPI --export-id=$i --export-id-only $INPUT_FILE
done;

for i in $IPAD_SPRITES_LO; do
$INKSCAPE --export-png=$IPAD_DIR/$i.png --export-dpi=$IPAD_DPI_LO --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=$IPADHD_DIR/$i.png --export-dpi=$IPADHD_DPI_LO --export-id=$i --export-id-only $INPUT_FILE
done;

for i in $PNG_IDS; do
$INKSCAPE --export-png=${i}-ipad.png --export-dpi=$IPAD_DPI --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=${i}-ipadhd.png --export-dpi=$IPADHD_DPI --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=${i}.png --export-dpi=$IPHONE_DPI --export-id=$i --export-id-only $INPUT_FILE
$INKSCAPE --export-png=${i}-hd.png --export-dpi=$IPHONEHD_DPI --export-id=$i --export-id-only $INPUT_FILE
done;

#cp window-ipad.png window.png
#cp window-ipadhd.png window-hd.png
