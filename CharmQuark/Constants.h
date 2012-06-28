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

#define kParticleMass       5.0f
#define kParticleFriction   0.0f
#define kParticleElasticity 0.2f
#define kVelocityLimit      1500.0f
#define kParticleDamping    0.1f

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

#define PLAYSOUNDEFFECT(...) \
[[GameManager sharedGameManager] playSoundEffect:@#__VA_ARGS__]

#define STOPSOUNDEFFECT(...) \
[[GameManager sharedGameManager] stopSoundEffect:__VA_ARGS__]

// Links to websites
typedef enum {
    kLinkTypeMainSite,
    kLinkTypeSupportSite,
    kLinkTypeFacebook
} LinkTypes;

#endif
