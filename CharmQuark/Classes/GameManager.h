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
    
    // Added for audio
    BOOL hasAudioBeenInitialized;
    GameManagerSoundState managerSoundState;
    SimpleAudioEngine *soundEngine;
    NSMutableDictionary *listOfSoundEffectFiles;
    NSMutableDictionary *soundEffectsState;
    
    SceneTypes curLevel;
    SceneTypes lastLevel;
    
}
@property (nonatomic,readwrite) BOOL isMusicON;
@property (nonatomic,readwrite) BOOL isSoundEffectsON;
@property (readwrite) BOOL hasPlayerDied;
@property (readwrite) GameManagerSoundState managerSoundState;
//@property (readonly) SimpleAudioEngine *soundEngine;
@property (nonatomic, retain) NSMutableDictionary *listOfSoundEffectFiles;
@property (nonatomic, retain) NSMutableDictionary *soundEffectsState;
@property (assign) SceneTypes curLevel;
@property (assign) SceneTypes lastLevel;

+(GameManager*)sharedGameManager;                                  // 1
-(void)runSceneWithID:(SceneTypes)sceneID;                         // 2
-(void)openSiteWithLinkType:(LinkTypes)linkTypeToOpen ;            // 3
// Chapter 8
-(void)setupAudioEngine;
-(ALuint)playSoundEffect:(NSString*)soundEffectKey gain:(Float32)gain;
-(void)stopSoundEffect:(ALuint)soundEffectID;
-(void)playBackgroundTrack:(NSString*)trackFileName;
// Chapter 9
-(CGSize)getDimensionsOfCurrentScene;
-(NSInteger)getHighScoreForSceneWithID:(SceneTypes)sceneID;
-(void)setHighScore:(NSInteger)score forSceneWithID:(SceneTypes)sceneID;
@end
