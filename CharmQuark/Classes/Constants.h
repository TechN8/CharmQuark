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

typedef enum {
    kNoSceneUninitialized=0,
    kMainMenuScene=1,
    kOptionsScene=2,
    kCreditsScene=3,
    kGameOverScene=4,
    kIntroScene=100,
    kGameScene=101
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
    kLinkTypeSupportSite,
    kLinkTypeFacebook
} LinkTypes;

#endif
