//  GameManager.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/18/12.
//  Copyright Aether Theory, LLC 2012. All rights reserved.
//

#import "cocos2d.h"
#import "chipmunk.h"
#import "GameManager.h"
#import "MainMenuScene.h"
#import "IntroLayer.h"
#import "GameScene.h"
#import "GCHelper.h"
#import "CDXPropertyModifierAction.h"


static NSString *kSoundEffectsOnKey	= @"isSoundEffectsOn";
static NSString *kMusicOnKey		= @"isMusicOn";
static NSString *kHighScoreKey      = @"highScores";

@implementation GameManager

@synthesize curLevel;
@synthesize hasPlayerDied;
@synthesize lastLevel;

static GameManager* _sharedGameManager = nil;
+(GameManager*)sharedGameManager {
    @synchronized([GameManager class])
    {
        if(!_sharedGameManager)
            [[self alloc] init];
        return _sharedGameManager;
    }
    return nil; 
}

+(id)alloc 
{
    @synchronized ([GameManager class])
    {
        NSAssert(_sharedGameManager == nil,
                 @"Attempted to allocated a second instance of the Game Manager singleton");
        _sharedGameManager = [super alloc];
        return _sharedGameManager;
    }
    return nil;  
}

-(id)init { 
    self = [super init];
    if (self != nil) {
        // Game Manager initialized
        CCLOG(@"Game Manager Singleton, init");
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (nil == [defaults objectForKey:kMusicOnKey]) {
            isMusicON = YES;
        } else {
            isMusicON = [defaults boolForKey:kMusicOnKey];
        }
        
        if (nil == [defaults objectForKey:kSoundEffectsOnKey]) {
            isSoundEffectsON = YES;
        } else {
            isSoundEffectsON = [defaults boolForKey:kSoundEffectsOnKey];
        }
        hasPlayerDied = NO;
        currentScene = kNoSceneUninitialized;
        hasAudioBeenInitialized = NO;
        soundEngine = nil;
        managerSoundState = kAudioManagerUninitialized;
        
        self.bgmSources = [NSMutableDictionary dictionaryWithCapacity:10];
        
        // Load sprite sheets.
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"scene1Atlas.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"titleAtlas.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"iconAtlas.plist"];
    }
    return self;
}

-(void)openSiteWithLinkType:(LinkTypes)linkTypeToOpen {
    NSURL *urlToOpen = nil;
    if (linkTypeToOpen == kLinkTypeMainSite) {
        CCLOG(@"Opening Book Site");
        urlToOpen = 
        [NSURL URLWithString:
         @"http://www.aethertheory.com"];
    } else if (linkTypeToOpen == kLinkTypeSupportSite) {
        CCLOG(@"Opening Developer Site for Rod");
        urlToOpen = [NSURL URLWithString:@"http://www.aethertheory.com/support"];
    } else if (linkTypeToOpen == kLinkTypeFacebook) {
        CCLOG(@"Opening Facebook Page");
        urlToOpen = 
        [NSURL URLWithString:@"http://www.facebook.com/AetherTheoryLLC"];
    } else {
        CCLOG(@"Unknown link type!");
        return;
    }
    
    if (![[UIApplication sharedApplication] openURL:urlToOpen]) {
        CCLOG(@"%@%@",@"Failed to open url:",[urlToOpen description]);
        [self runSceneWithID:kMainMenuScene];
    }    
}

#pragma mark - Scene Management


-(CGSize)getDimensionsOfCurrentScene {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    CGSize levelSize;
    switch (currentScene) {
        case kMainMenuScene: 
        case kIntroScene:
        case kGameSceneSurvival:
        case kGameSceneTimeAttack:
        case kGameSceneMomMode:
            levelSize = screenSize;
            break;
        default:
            CCLOG(@"Unknown Scene ID, returning default size");
            levelSize = screenSize;
            break;
    }
    return levelSize;
}

- (NSString*)formatSceneTypeToString:(SceneTypes)sceneID {
    NSString *result = nil;
    switch(sceneID) {
        case kNoSceneUninitialized:
            result = @"kNoSceneUninitialized";
            break;
        case kMainMenuScene:
            result = @"kMainMenuScene";
            break;
        case kIntroScene:
            result = @"kIntroScene";
            break;
        case kGameSceneSurvival:
            result = @"kGameSceneSurvival";
            break;
        case kGameSceneTimeAttack:
            result = @"kGameSceneTimeAttack";
            break;
        case kGameSceneMomMode:
            result = @"kGameSceneMomMode";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected SceneType."];
    }
    return result;
}

-(void)runSceneWithID:(SceneTypes)sceneID {
    
    lastLevel = curLevel;
    curLevel = sceneID;
    
    SceneTypes oldScene = currentScene;
    currentScene = sceneID;
    
    id sceneToRun = nil;
    switch (sceneID) {
        case kMainMenuScene: 
            sceneToRun = [MainMenuScene node];
            break;
        case kIntroScene:
            sceneToRun = [IntroLayer scene];
            break;
        case kGameSceneSurvival: 
        case kGameSceneTimeAttack:
        case kGameSceneMomMode:
            // Same scene used for both modes.
            sceneToRun = [GameScene node];
            break;
        default:
            CCLOG(@"Unknown ID, cannot switch scenes");
            return;
            break;
    }
    
    if (sceneToRun == nil) {
        // Revert back, since no new scene was found
        currentScene = oldScene;
        return;
    }
    
    // Menu Scenes have a value of < 100
    if (sceneID < 100) {
        //        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) { 
        //            CGSize screenSize = [CCDirector sharedDirector].winSizeInPixels; 
        //                [sceneToRun setScaleX:0.46875f];
        //                [sceneToRun setScaleY:0.41666f];
        //                CCLOG(@"GameMgr:Scaling for iPhone");
        //        }
    }
    
//    [self loadBGMListForSceneWithID:sceneID]; // Don't do async.  Need BGM.
    
    if (currentScene != oldScene) {
        [self performSelectorInBackground:@selector(loadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:sceneID]];
    }
    
    if ([[CCDirector sharedDirector] runningScene] == nil) {
        [[CCDirector sharedDirector] runWithScene:sceneToRun];
    } else {
        [[CCDirector sharedDirector] 
         replaceScene:[CCTransitionFade transitionWithDuration:1.0 
                                                         scene:sceneToRun 
                                                     withColor:ccBLACK]];
    }
    
    // Start appropriate music for scene.
    if (isMusicON) {
        [self playBackgroundTrackForCurrentScene];
    }
}

#pragma mark - Game Center / High Scores

-(NSInteger)getHighScoreForSceneWithID:(SceneTypes)sceneID {
    NSInteger highScore = 0;
    NSDictionary *highScoreDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kHighScoreKey];
    if (nil != highScoreDict) {
        NSNumber *scoreNum = [highScoreDict valueForKey:[self formatSceneTypeToString:sceneID]];
        if (nil != scoreNum) {
            highScore = [scoreNum intValue];
        }
    }
    
    // TODO: Get from gamecenter if authenticated.
    
    return highScore;
}

-(void)setHighScore:(NSInteger)score forSceneWithID:(SceneTypes)sceneID {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *newHighScoreDict = [[[NSMutableDictionary alloc] init] autorelease];
    NSDictionary *oldHighScoreDict = [ud dictionaryForKey:kHighScoreKey];
    if (nil != oldHighScoreDict) {
        [newHighScoreDict addEntriesFromDictionary:oldHighScoreDict];
    }
    [newHighScoreDict setValue:[NSNumber numberWithInt:score] 
                        forKey:[self formatSceneTypeToString:sceneID]];
    [ud setValue:newHighScoreDict forKey:kHighScoreKey];
    
    // Send to gamecenter.
    GCHelper *gch = [GCHelper sharedInstance];
    switch (sceneID) {
        case kGameSceneTimeAttack:
            [gch reportScore:kLeaderboardTimeAttack score:score];
            break;
        case kGameSceneSurvival:
            [gch reportScore:kLeaderboardAccelerator score:score];
            break;
        default:
            break;
    }
}

#pragma mark - Sound Effects

@synthesize isSoundEffectsON;

-(void)setIsSoundEffectsON:(BOOL)value {
    isSoundEffectsON = value;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:kSoundEffectsOnKey];
}

-(void)stopSoundEffect:(ALuint)soundEffectID {
    if (managerSoundState == kAudioManagerReady) {
        [soundEngine stopEffect:soundEffectID];
    }
}

-(ALuint)playSoundEffect:(NSString*)soundEffectKey gain:(Float32)gain {
    ALuint soundID = 0;
    if (isSoundEffectsON && managerSoundState == kAudioManagerReady) {
        NSNumber *isSFXLoaded = [soundEffectsState objectForKey:soundEffectKey];
        if ([isSFXLoaded boolValue] == SFX_LOADED) {
            soundID = [soundEngine playEffect:[listOfSoundEffectFiles objectForKey:soundEffectKey] 
                                        pitch:1.0 pan:0.0 gain:gain];
        } else {
            CCLOG(@"GameMgr: SoundEffect %@ is not loaded, cannot play.",soundEffectKey);
        }
    } else {
        CCLOG(@"GameMgr: Sound Manager is not ready or sound disabled, cannot play %@", soundEffectKey);
    }
    return soundID;
}

#pragma mark - Music

@synthesize bgmSources;
@synthesize isMusicON;
@synthesize bgmIntensity;

-(void)setIsMusicON:(BOOL)value {
    isMusicON = value;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:kMusicOnKey];
    if (NO == value) {
        [self stopBackgroundTrack];
//        [self stopBGM];
    } else {
        [self playBackgroundTrackForCurrentScene];
//        [self startBGM];
    }
}

-(void)bgmManager {
    if (bgmIntensity == bgmIntensityLast) {
        bgmIntensity = bgmIntensity % 2 ? bgmIntensity + 1 : bgmIntensity - 1;
    }
    NSString *bgmId = [NSString stringWithFormat:@"BGM_%d", bgmIntensity];
    [self playBGM:bgmId];
    bgmIntensityLast = bgmIntensity;
}

-(void)playBGM:(NSString*)loopKey {
    if (isMusicON && managerSoundState == kAudioManagerReady) {
        CDSoundSource *nextBGM = [bgmSources objectForKey:loopKey];
        if (nil == nextBGM) {
            nextBGM = [soundEngine soundSourceForFile:
                      [listOfSoundEffectFiles objectForKey:loopKey]];
            [bgmSources setObject:nextBGM forKey:loopKey];
            [nextBGM setGain:0.5];
        }
        [nextBGM rewind];
        [nextBGM play];
        lastBGMSource = nextBGM;
    }
}

-(void)startBGM {
    [self scheduleBGM];
    [self bgmManager];
}

-(void)stopBGM {
    [[[CCDirector sharedDirector] scheduler] 
     unscheduleSelector:@selector(bgmManager) forTarget:self];
    [lastBGMSource stop];
}

-(void) restartBGM {
    [self scheduleBGM];
    if (isMusicON && managerSoundState == kAudioManagerReady) {
    [lastBGMSource rewind];
    [lastBGMSource play];
    }
}

-(void)scheduleBGM {
    CCScheduler *scheduler = [[CCDirector sharedDirector] scheduler];
    [scheduler scheduleSelector:@selector(bgmManager) 
                      forTarget:self 
                       interval:8.0
                         paused:NO
                         repeat:kCCRepeatForever
                          delay:8.0];
}

-(void)playBackgroundTrackForCurrentScene {
    switch (currentScene) {
        case kMainMenuScene: 
            [soundEngine setBackgroundMusicVolume:0.2];
            [self playBackgroundTrack:@"SmoothPiano.m4a"];
            break;
        case kGameSceneSurvival:
        case kGameSceneTimeAttack:
        case kGameSceneMomMode:
            // Start the music.
            [soundEngine setBackgroundMusicVolume:0.6];
            [self playBackgroundTrack:@"SmoothPiano.m4a"];
            break;
        case kIntroScene:
            [self stopBackgroundTrack];
            break;            
        default:
            CCLOG(@"Unknown Scene ID, stopping BGM");
            [self stopBackgroundTrack];
            break;
            
    }
}

-(void)playBackgroundTrack:(NSString*)trackFileName {
    // Wait to make sure soundEngine is initialized
    if ((managerSoundState != kAudioManagerReady) 
        && (managerSoundState != kAudioManagerFailed)) {
        
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME) {
            [NSThread sleepForTimeInterval:0.1f];
            if ((managerSoundState == kAudioManagerReady) || 
                (managerSoundState == kAudioManagerFailed)) {
                break;
            }
            waitCycles = waitCycles + 1;
        }
    }
    
    if (isMusicON && managerSoundState == kAudioManagerReady) {
        if ([soundEngine isBackgroundMusicPlaying]) {
            [soundEngine stopBackgroundMusic];
        }
        [soundEngine preloadBackgroundMusic:trackFileName];
        [soundEngine playBackgroundMusic:trackFileName loop:YES];
        [soundEngine setBackgroundMusicVolume:0.0];
        [CDXPropertyModifierAction fadeBackgroundMusic:1.0f finalVolume:0.5f curveType:kIT_SCurve shouldStop:NO];
    }
}

-(void)stopBackgroundTrack {
    if (managerSoundState == kAudioManagerReady) {
        [soundEngine stopBackgroundMusic];
    }
}

#pragma mark - Audio Manager

@synthesize listOfSoundEffectFiles;
@synthesize managerSoundState;
@synthesize soundEffectsState;
@synthesize soundEngine;

-(NSDictionary *)getSoundEffectsListForSceneWithID:(SceneTypes)sceneID {
    
    // 1: Get the Path to the plist file
    NSString *plistPath = [[NSBundle mainBundle] 
                     pathForResource:@"SoundEffects" ofType:@"plist"];
    
    // 2: Read in the plist file
    NSDictionary *plistDictionary = 
    [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // 3: If the plistDictionary was null, the file was not found.
    if (plistDictionary == nil) {
        CCLOG(@"Error reading SoundEffects.plist");
        return nil; // No Plist Dictionary or file found
    }
    
    // 4. If the list of soundEffectFiles is empty, load it
    if ((listOfSoundEffectFiles == nil) || 
        ([listOfSoundEffectFiles count] < 1)) {
        NSLog(@"Before");
        [self setListOfSoundEffectFiles:
         [[[NSMutableDictionary alloc] init] autorelease]];
        NSLog(@"after");
        for (NSString *sceneSoundDictionary in plistDictionary) {
            [listOfSoundEffectFiles 
             addEntriesFromDictionary:
             [plistDictionary objectForKey:sceneSoundDictionary]];
        }
        CCLOG(@"Number of SFX filenames:%d", 
              [listOfSoundEffectFiles count]);
    }
    
    // 5. Load the list of sound effects state, mark them as unloaded
    if ((soundEffectsState == nil) || 
        ([soundEffectsState count] < 1)) {
        [self setSoundEffectsState:[[[NSMutableDictionary alloc] init] autorelease]];
        for (NSString *SoundEffectKey in listOfSoundEffectFiles) {
            [soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:SoundEffectKey];
        }
    }
    
    // 6. Return just the mini SFX list for this scene
    NSString *sceneIDName = [self formatSceneTypeToString:sceneID];
    NSDictionary *soundEffectsList = 
    [plistDictionary objectForKey:sceneIDName];
    
    return soundEffectsList;
}


-(void)loadAudioForSceneWithID:(NSNumber*)sceneIDNumber {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    SceneTypes sceneID = (SceneTypes) [sceneIDNumber intValue];
    // 1
    if (managerSoundState == kAudioManagerInitializing) {
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME) {
            [NSThread sleepForTimeInterval:0.1f];
            if ((managerSoundState == kAudioManagerReady) || 
                (managerSoundState == kAudioManagerFailed)) {
                break;
            }
            waitCycles = waitCycles + 1;
        }
    }
    
    if (managerSoundState == kAudioManagerFailed || managerSoundState == kAudioManagerUninitialized) {
        return; // Nothing to load, CocosDenshion not ready
    }
    
    NSDictionary *soundEffectsToLoad = 
    [self getSoundEffectsListForSceneWithID:sceneID];
    if (soundEffectsToLoad == nil) { // 2
        CCLOG(@"Error reading SoundEffects.plist");
        return;
    }
    
    // Get all of the entries and PreLoad // 3
    for( NSString *keyString in soundEffectsToLoad )
    {
        CCLOG(@"\nLoading Audio Key:%@ File:%@", 
              keyString,[soundEffectsToLoad objectForKey:keyString]);
        [soundEngine preloadEffect:
         [soundEffectsToLoad objectForKey:keyString]]; // 3
        // 4
        [soundEffectsState setObject:[NSNumber numberWithBool:SFX_LOADED] forKey:keyString];
        
    }
    
    [self unloadAudioForSceneWithID:[NSNumber numberWithInt:lastLevel]];
    [pool release];
}

-(void)unloadAudioForSceneWithID:(NSNumber*)sceneIDNumber {
//    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    SceneTypes sceneID = (SceneTypes) [sceneIDNumber intValue];
    if (sceneID == kNoSceneUninitialized) {
        return; // Nothing to unload
    }
    
    
    NSDictionary *soundEffectsToUnload = 
    [self getSoundEffectsListForSceneWithID:sceneID];
    if (soundEffectsToUnload == nil) {
        CCLOG(@"Error reading SoundEffects.plist");
        return;
    }
    if (managerSoundState == kAudioManagerReady) {
        // Get all of the entries and unload
        for( NSString *keyString in soundEffectsToUnload )
        {
            [soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:keyString];
            [bgmSources removeObjectForKey:keyString];
            [soundEngine unloadEffect:keyString];
            CCLOG(@"\nUnloading Audio Key:%@ File:%@", 
                  keyString,[soundEffectsToUnload objectForKey:keyString]);
            
        }
    }
//    [pool release];
}

-(void)initAudioAsync {
    // Initializes the audio engine asynchronously
    managerSoundState = kAudioManagerInitializing; 
    // Indicate that we are trying to start up the Audio Manager
    [CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_MID];
    
    //Init audio manager asynchronously as it can take a few seconds
    //The FXPlusMusicIfNoOtherAudio mode will check if the user is
    // playing music and disable background music playback if 
    // that is the case.
    [CDAudioManager initAsynchronously:kAMM_FxPlusMusicIfNoOtherAudio];
    
    //Wait for the audio manager to initialise
    while ([CDAudioManager sharedManagerState] != kAMStateInitialised) 
    {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    //At this point the CocosDenshion should be initialized
    // Grab the CDAudioManager and check the state
    CDAudioManager *audioManager = [CDAudioManager sharedManager];
    if (audioManager.soundEngine == nil || 
        audioManager.soundEngine.functioning == NO) {
        CCLOG(@"CocosDenshion failed to init, no audio will play.");
        managerSoundState = kAudioManagerFailed; 
    } else {
        [audioManager setResignBehavior:kAMRBStopPlay autoHandle:YES];
        soundEngine = [SimpleAudioEngine sharedEngine];
        managerSoundState = kAudioManagerReady;
        CCLOG(@"CocosDenshion is Ready");
    }
}


-(void)setupAudioEngine {
    if (hasAudioBeenInitialized == YES) {
        return;
    } else {
        hasAudioBeenInitialized = YES; 
        NSOperationQueue *queue = [[NSOperationQueue new] autorelease];
        NSInvocationOperation *asyncSetupOperation = 
        [[NSInvocationOperation alloc] initWithTarget:self 
                                             selector:@selector(initAudioAsync) 
                                               object:nil];
        [queue addOperation:asyncSetupOperation];
        [asyncSetupOperation autorelease];
    }
}

@end
