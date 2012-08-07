#!/bin/bash -x

INKSCAPE=/Applications/Inkscape.app/Contents/Resources/bin/inkscape
INPUT=../Artwork/AppIcon.svg

#Icon-72.png:        PNG image data, 72 x 72, 8-bit/color RGBA, non-interlaced
FILENAME=Icon-72.png
SIZE=72
$INKSCAPE --file=$INPUT --export-png=$FILENAME --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

#Icon-Small-100.png: PNG image data, 100 x 100, 8-bit/color RGB, non-interlaced
FILENAME=Icon-Small-100.png
SIZE=100
$INKSCAPE --file=$INPUT --export-png=$FILENAME --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

#Icon-Small-50.png:  PNG image data, 50 x 50, 8-bit/color RGBA, non-interlaced
FILENAME=Icon-Small-50.png
SIZE=50
$INKSCAPE --file=$INPUT --export-png=$FILENAME --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

#Icon-Small.png:     PNG image data, 29 x 29, 8-bit/color RGBA, non-interlaced
FILENAME=Icon-Small.png
SIZE=72
$INKSCAPE --file=$INPUT --export-png=$FILENAME --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

#Icon-Small@2x.png:  PNG image data, 58 x 58, 8-bit/color RGBA, non-interlaced
FILENAME=Icon-Small@2x.png
SIZE=58
$INKSCAPE --file=$INPUT --export-png=$FILENAME --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

#Icon.png:           PNG image data, 57 x 57, 8-bit/color RGBA, non-interlaced
FILENAME=Icon.png
SIZE=57
$INKSCAPE --file=$INPUT --export-png=$FILENAME --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

#Icon@2x.png:        PNG image data, 114 x 114, 8-bit/color RGB, non-interlaced
FILENAME=Icon@2x.png
SIZE=114
$INKSCAPE --file=$INPUT --export-png=$FILENAME --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

#Icon_iPadHD.png:    PNG image data, 144 x 144, 8-bit/color RGB, non-interlaced
FILENAME=Icon_iPadHD.png
SIZE=144
$INKSCAPE --file=$INPUT --export-png=$FILENAME --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

#Icon-1024
FILENAME=Icon-1024.png
SIZE=1024
$INKSCAPE --file=$INPUT --export-png=$FILENAME --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 

#iTunesArtwork
FILENAME=iTunesArtwork
SIZE=512
$INKSCAPE --file=$INPUT --export-png=$FILENAME --export-width=$SIZE --export-height=$SIZE --export-id=icon-rect 
