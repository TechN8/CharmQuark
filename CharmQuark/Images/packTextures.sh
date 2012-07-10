#!/bin/bash


/usr/local/bin/TexturePacker --no-trim --algorithm Basic --basic-sort-by name --format cocos2d \
	--data scene1Atlas.plist --sheet scene1Atlas.png \
	Particles/iPhone/*.png UI/iPhone/*.png

/usr/local/bin/TexturePacker --no-trim --algorithm Basic --basic-sort-by name --format cocos2d \
	--data scene1Atlas-hd.plist --sheet scene1Atlas-hd.png \
	Particles/iPhone-hd/*.png UI/iPhone-hd/*.png
