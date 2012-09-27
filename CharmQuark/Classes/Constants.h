//
//  Constants.h
//  CharmQuark
//
//  Created by Nathan Babb on 6/18/12.
//  Copyright (c) 2012 Aether Theory, LLC. All rights reserved.
//

#ifndef CharmQuark_Constants_h
#define CharmQuark_Constants_h

#define kMainMenuTagValue 10

// Scoring messages
#define kColorScore     ccc3(240, 200, 80)
#define kColorCombo     ccc3(200, 200, 230)
#define kColorBonus     ccc3(200, 200, 230)
#define kColorTimeAdd   ccc3(200, 230, 200)
#define kColorLevelUp   ccc3(230, 200, 200)

// UI Elements
#define kColorBackground        ccc3(0, 40, 60)
#define kColorUI                ccc3(90, 140, 150)
#define kColorButton            ccc3(130, 180, 190)
#define kColorButtonSelected    ccc3(160, 210, 220)
#define kColorDialogTitle       ccc3(90, 140, 150)
#define kColorThumbGuide        ccc3(160, 210, 220)
#define kOpacityThumbGuide      128

// Dialog tuning
#define kPopupSpeed         0.3
#define kDialogTitlePos     ccp(winSize.width * 0.5, winSize.height * 0.72);
#define kDialogTitleScale   1.0

// Device support
#define kSimDimensions  ccp(1024,768)
#define kPuzzleCenter   ccp(720, 384)
#define kLaunchPoint    ccp(-720, 0)
#define kiPhoneScale    0.46875f
#define kiPhoneSkew     ccp(0,-32);
#define kiPadScale      0.875
#define kiPadSkew       ccp(88, 48)
#define kiPhone568Skew  ccp(44,-32);

// Volume
#define kVolumeMenu     0.1
#define kVolumeGame     0.7

typedef enum {
    kNoSceneUninitialized=0,
    kMainMenuScene=1,
    kIntroScene=100,
    kGameSceneSurvival=101,
    kGameSceneTimeAttack=102,
    kGameSceneMomMode=103,
} SceneTypes;

// Audio Items
#define AUDIO_MAX_WAITTIME 150

typedef enum {
    kAudioManagerUninitialized=0,
    kAudioManagerFailed=1,
    kAudioManagerInitializing=2,
    kAudioManagerInitialized=100,
    kAudioManagerLoading=200,
    kAudioManagerReady=300
    
} GameManagerSoundState;

// Audio Constants
#define SFX_NOTLOADED NO
#define SFX_LOADED YES

//#define PLAYSOUNDEFFECT(...) \
//[[GameManager sharedGameManager] playSoundEffect:@#__VA_ARGS__]

#define PLAYSOUNDEFFECT(__id__,__gain__) \
[[GameManager sharedGameManager] playSoundEffect:@#__id__ gain:__gain__]


#define STOPSOUNDEFFECT(...) \
[[GameManager sharedGameManager] stopSoundEffect:__VA_ARGS__]

// Links to websites
typedef enum {
    kLinkTypeMainSite,
    kLinkTypeFacebook,
    kLinkTypeTwitter,
} LinkTypes;

#endif

// Uncomment this for bigger explosions.
#define SCREENSHOTS 1

// Uncomment this for constant rating reminders.
//#define DEBUG_IRATE 1
