#!/bin/bash

# This script will built texture atlasses for each device resolution.

/usr/local/bin/TexturePacker --no-trim --algorithm MaxRects --maxrects-heuristics best --format cocos2d \
	--data scene1Atlas.plist --sheet scene1Atlas.png Sprites/iPhone/*.png

/usr/local/bin/TexturePacker --no-trim --algorithm MaxRects --maxrects-heuristics best --format cocos2d \
	--data scene1Atlas-hd.plist --sheet scene1Atlas-hd.png Sprites/iPhone-hd/*.png

/usr/local/bin/TexturePacker --no-trim --algorithm MaxRects --maxrects-heuristics best --format cocos2d \
	--data scene1Atlas-ipad.plist --sheet scene1Atlas-ipad.png Sprites/iPad/*.png

/usr/local/bin/TexturePacker --no-trim --algorithm MaxRects --maxrects-heuristics best --format cocos2d \
	--data scene1Atlas-ipadhd.plist --sheet scene1Atlas-ipadhd.png Sprites/iPad-hd/*.png
