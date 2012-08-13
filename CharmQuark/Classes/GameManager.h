//  GameManager.h
//  CharmQuark
//
//  Created by Nathan Babb on 6/18/12.
//  Copyright Aether Theory, LLC 2012. All rights reserved.
//

#import "Constants.h"
#import "SimpleAudioEngine.h"

@interface GameManager : NSObject {
    BOOL isMusicON;
    BOOL isSoundEffectsON;
    BOOL hasPlayerDied;
    SceneTypes currentScene;
    SceneTypes curLevel;
    SceneTypes lastLevel;
    
    // Added for audio
    BOOL hasAudioBeenInitialized;
    GameManagerSoundState managerSoundState;
    SimpleAudioEngine *soundEngine;
    NSMutableDictionary *listOfSoundEffectFiles;
    NSMutableDictionary *soundEffectsState;
    ALuint sfxChannels[30];
    NSInteger sfxNext;
    
    // BGM
    NSMutableDictionary *bgmSources;
    CDSoundSource *lastBGMSource;
    NSInteger bgmIntensity;
    NSInteger bgmIntensityLast;
}

@property (nonatomic,readwrite) BOOL isMusicON;
@property (nonatomic,readwrite) BOOL isSoundEffectsON;
@property (readwrite) BOOL hasPlayerDied;
@property (readwrite) GameManagerSoundState managerSoundState;
@property (readonly) SimpleAudioEngine *soundEngine;
@property (nonatomic, retain) NSMutableDictionary *listOfSoundEffectFiles;
@property (nonatomic, retain) NSMutableDictionary *soundEffectsState;
@property (nonatomic, retain) NSMutableDictionary *bgmSources;
@property (assign) SceneTypes curLevel;
@property (assign) SceneTypes lastLevel;
@property (assign) NSInteger bgmIntensity;

+(GameManager*)sharedGameManager;
-(void)runSceneWithID:(SceneTypes)sceneID;
-(void)openSiteWithLinkType:(LinkTypes)linkTypeToOpen;
-(CGSize)getDimensionsOfCurrentScene;

// Scores
-(NSInteger)getHighScoreForSceneWithID:(SceneTypes)sceneID;
-(void)setHighScore:(NSInteger)score forSceneWithID:(SceneTypes)sceneID;

// Audio
-(void)setupAudioEngine;
-(ALuint)playSoundEffect:(NSString*)soundEffectKey gain:(Float32)gain;
-(void)stopSoundEffect:(ALuint)soundEffectID;
-(void)playBackgroundTrack:(NSString*)trackFileName;
-(void)playBackgroundTrackForCurrentScene;
-(void)stopBackgroundTrack;

// BGM
-(void)startBGM;
-(void)stopBGM;
-(void)restartBGM;

@end
