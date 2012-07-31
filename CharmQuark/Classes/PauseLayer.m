//
//  PauseLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 7/11/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "PauseLayer.h"
#import "GameManager.h"
#import "RemoveFromParentAction.h"

@implementation PauseLayer

- (void) quitGame {
    [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
}

- (void) resumeParent {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGPoint offScreen = ccp(0, 2 * winSize.height);
    CCSequence *seq = [CCSequence actions:[CCMoveTo actionWithDuration:0.5f position:offScreen], 
                       [RemoveFromParentAction action],
                       [CCCallFunc actionWithTarget:self.parent selector:@selector(resumeSchedulerAndActions)], 
                       nil];
    [self runAction:seq];
}

- (void) toggleMusic {
    GameManager *sharedGameManager = [GameManager sharedGameManager];
    [sharedGameManager setIsMusicON:![sharedGameManager isMusicON]];
    if ([[GameManager sharedGameManager] isMusicON]) {
        [musicToggle setString:@"Turn Music Off"];
    } else {
        [musicToggle setString:@"Turn Music On"];
    }
}

- (void) toggleSound {
    GameManager *sharedGameManager = [GameManager sharedGameManager];
    [sharedGameManager setIsSoundEffectsON:![sharedGameManager isSoundEffectsON]];
    if ([[GameManager sharedGameManager] isSoundEffectsON]) {
        [soundToggle setString:@"Turn Sound Off"];
    } else {
        [soundToggle setString:@"Turn Sound On"];
    }
}

#pragma mark - ModalMenuLayer

-(void)initUI {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
//    CCLabelTTF *title = [CCLabelTTF labelWithString:@"Game Paused" fontName:@"American Typewriter" fontSize:30.0f];
//    title.color = ccWHITE;
//    title.position = ccp(winSize.width * 0.5, winSize.height * 0.82);
//    [self addChild:title z:100];
    
    //TODO: Replace with CCMenuItemLabel using CCLabelBMFont

    //Resume
    CCMenuItemFont *resumeItem = [CCMenuItemFont itemWithString:@"Resume" target:self selector:@selector(resumeParent)];
    [resumeItem setFontName:@"American Typewriter"];
    [resumeItem setColor:ccWHITE];

    //Quit
    CCMenuItemFont *quitItem = [CCMenuItemFont itemWithString:@"Quit" target:self selector:@selector(quitGame)];
    [quitItem setFontName:@"American Typewriter"];
    [quitItem setColor:ccWHITE];

    // Music off
    NSString *musicString = nil;
    if ([[GameManager sharedGameManager] isMusicON]) {
        musicString = @"Turn Music Off";
    } else {
        musicString = @"Turn Music On";
    }
    musicToggle = [CCMenuItemFont itemWithString:musicString target:self selector:@selector(toggleMusic)];
    [musicToggle setFontName:@"American Typewriter"];
    [musicToggle setColor:ccWHITE];
    
    // Sound off
    NSString *soundString = nil;
    if ([[GameManager sharedGameManager] isSoundEffectsON]) {
        soundString = @"Turn Sound Off";
    } else {
        soundString = @"Turn Sound On";
    }
    soundToggle = [CCMenuItemFont itemWithString:soundString target:self selector:@selector(toggleSound)];
    [soundToggle setFontName:@"American Typewriter"];
    [soundToggle setColor:ccWHITE];

    
    CCMenu *menu = [CCMenu menuWithItems:resumeItem, quitItem, musicToggle, soundToggle, nil];
    [menu alignItemsVerticallyWithPadding:10];
    menu.position = ccp(winSize.width * 0.5, winSize.height * 0.5f);
    [self addChild:menu z:100];
}

#pragma mark - CCNode

-(void)onEnter {
    [super onEnter];
}

@end

