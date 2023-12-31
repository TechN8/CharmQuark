#!/bin/bash

# This script will built texture atlasses for each device resolution.

# Game Sprites

/usr/local/bin/TexturePacker --no-trim --algorithm MaxRects --maxrects-heuristics best --format cocos2d \
	--data scene1Atlas.plist --sheet scene1Atlas.png Sprites/iPhone/*.png

/usr/local/bin/TexturePacker --no-trim --algorithm MaxRects --maxrects-heuristics best --format cocos2d \
	--data scene1Atlas-hd.plist --sheet scene1Atlas-hd.png Sprites/iPhone-hd/*.png

/usr/local/bin/TexturePacker --no-trim --algorithm MaxRects --maxrects-heuristics best --format cocos2d \
	--data scene1Atlas-ipad.plist --sheet scene1Atlas-ipad.png Sprites/iPad/*.png

/usr/local/bin/TexturePacker --no-trim --algorithm MaxRects --maxrects-heuristics best --format cocos2d \
	--data scene1Atlas-ipadhd.plist --sheet scene1Atlas-ipadhd.png Sprites/iPad-hd/*.png

# Titles

/usr/local/bin/TexturePacker --no-trim --algorithm MaxRects --maxrects-heuristics best --format cocos2d \
	--data titleAtlas.plist --sheet titleAtlas.png Titles/iPhone/*.png

/usr/local/bin/TexturePacker --no-trim --algorithm MaxRects --maxrects-heuristics best --format cocos2d \
	--data titleAtlas-hd.plist --sheet titleAtlas-hd.png Titles/iPhone-hd/*.png

/usr/local/bin/TexturePacker --no-trim --algorithm MaxRects --maxrects-heuristics best --format cocos2d \
	--data titleAtlas-ipad.plist --sheet titleAtlas-ipad.png Titles/iPad/*.png

/usr/local/bin/TexturePacker --no-trim --algorithm MaxRects --maxrects-heuristics best --format cocos2d \
	--data titleAtlas-ipadhd.plist --sheet titleAtlas-ipadhd.png Titles/iPad-hd/*.png

# Icons

/usr/local/bin/TexturePacker --no-trim --algorithm MaxRects --maxrects-heuristics best --format cocos2d \
	--data iconAtlas.plist --sheet iconAtlas.png Icons/iPhone/*.png

/usr/local/bin/TexturePacker --no-trim --algorithm MaxRects --maxrects-heuristics best --format cocos2d \
	--data iconAtlas-hd.plist --sheet iconAtlas-hd.png Icons/iPhone-hd/*.png

/usr/local/bin/TexturePacker --no-trim --algorithm MaxRects --maxrects-heuristics best --format cocos2d \
	--data iconAtlas-ipad.plist --sheet iconAtlas-ipad.png Icons/iPad/*.png

/usr/local/bin/TexturePacker --no-trim --algorithm MaxRects --maxrects-heuristics best --format cocos2d \
	--data iconAtlas-ipadhd.plist --sheet iconAtlas-ipadhd.png Icons/iPad-hd/*.png
