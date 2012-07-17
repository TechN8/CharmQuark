#!/bin/bash


/usr/local/bin/TexturePacker --no-trim --algorithm Basic --basic-sort-by name --format cocos2d \
	--data scene1Atlas.plist --sheet scene1Atlas.png \
	Particles/iPhone/*.png UI/iPhone/*.png Clock/iPhone/*.png

/usr/local/bin/TexturePacker --no-trim --algorithm Basic --basic-sort-by name --format cocos2d \
	--data scene1Atlas-hd.plist --sheet scene1Atlas-hd.png \
	Particles/iPhone-hd/*.png UI/iPhone-hd/*.png Clock/iPhone-hd/*.png

/usr/local/bin/TexturePacker --no-trim --algorithm Basic --basic-sort-by name --format cocos2d \
	--data scene1Atlas-ipad.plist --sheet scene1Atlas-ipad.png \
	Particles/iPad/*.png UI/iPad/*.png Clock/iPad/*.png

/usr/local/bin/TexturePacker --no-trim --algorithm Basic --basic-sort-by name --format cocos2d \
	--data scene1Atlas-ipadhd.plist --sheet scene1Atlas-ipadhd.png \
	Particles/iPad-hd/*.png UI/iPad-hd/*.png Clock/iPad-hd/*.png

