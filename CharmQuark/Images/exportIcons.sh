#!/bin/bash -x

INPUT_FILE=../Artwork/Icons.svg

INKSCAPE=/Applications/Inkscape.app/Contents/Resources/bin/inkscape

EXPORT_DIR=Icons
IPAD_DIR=$EXPORT_DIR/iPad
IPAD_DPI=90
IPAD_FONT_HEIGHT=42
IPADHD_DIR=$EXPORT_DIR/iPad-hd
IPADHD_DPI=180
IPADHD_FONT_HEIGHT=75
IPHONE_DIR=$EXPORT_DIR/iPhone
IPHONE_DPI=60
IPHONE_FONT_HEIGHT=26
IPHONEHD_DIR=$EXPORT_DIR/iPhone-hd
IPHONEHD_DPI=120
IPHONEHD_FONT_HEIGHT=51

ICONS='leaderboard achievements'
SMALL_ICONS='facebook-icon twitter-icon twitter-bird at-logo at-icon'

mkdir -p $IPAD_DIR $IPADHD_DIR $IPHONE_DIR $IPHONEHD_DIR

export LANG=C

for ICON in $ICONS; do
$INKSCAPE --export-png=$IPAD_DIR/$ICON.png --export-background-opacity=0 --export-dpi=$IPAD_DPI --export-id=$ICON --export-id-only $INPUT_FILE
$INKSCAPE --export-png=$IPADHD_DIR/$ICON.png --export-background-opacity=0 --export-dpi=$IPADHD_DPI --export-id=$ICON --export-id-only $INPUT_FILE
$INKSCAPE --export-png=$IPHONE_DIR/$ICON.png --export-background-opacity=0 --export-dpi=$IPHONE_DPI --export-id=$ICON --export-id-only $INPUT_FILE
$INKSCAPE --export-png=$IPHONEHD_DIR/$ICON.png --export-background-opacity=0 --export-dpi=$IPHONEHD_DPI --export-id=$ICON --export-id-only $INPUT_FILE
done;

for ICON in $SMALL_ICONS; do
$INKSCAPE --export-png=$IPAD_DIR/$ICON.png --export-background-opacity=0 --export-height=$IPAD_FONT_HEIGHT --export-id=$ICON --export-id-only $INPUT_FILE
$INKSCAPE --export-png=$IPADHD_DIR/$ICON.png --export-background-opacity=0 --export-height=$IPADHD_FONT_HEIGHT --export-id=$ICON --export-id-only $INPUT_FILE
$INKSCAPE --export-png=$IPHONE_DIR/$ICON.png --export-background-opacity=0 --export-height=$IPHONE_FONT_HEIGHT --export-id=$ICON --export-id-only $INPUT_FILE
$INKSCAPE --export-png=$IPHONEHD_DIR/$ICON.png --export-background-opacity=0 --export-height=$IPHONEHD_FONT_HEIGHT --export-id=$ICON --export-id-only $INPUT_FILE
done;
