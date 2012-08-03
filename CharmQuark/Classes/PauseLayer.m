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
    CCSequence *seq = [CCSequence actions:[CCMoveTo actionWithDuration:kPopupSpeed position:offScreen], 
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
    CCLabelBMFont *title = [CCLabelBMFont labelWithString:@"Paused" fntFile:@"score.fnt"];
    title.color = ccGREEN;
    title.position = ccp(winSize.width * 0.5, winSize.height * 0.7);
    title.scale = 1.5;
    [self addChild:title z:100];
    
    //Resume
    CCLabelBMFont *resumeLabel = [CCLabelBMFont labelWithString:@"Resume" fntFile:@"score.fnt"];
    CCMenuItemFont *resumeItem = [CCMenuItemFont itemWithLabel:resumeLabel 
                                                        target:self 
                                                      selector:@selector(resumeParent)];
    
    //Quit
    CCLabelBMFont *quitLabel = [CCLabelBMFont labelWithString:@"Quit" fntFile:@"score.fnt"];
    CCMenuItemFont *quitItem = [CCMenuItemFont itemWithLabel:quitLabel
                                                      target:self 
                                                    selector:@selector(quitGame)];

    // Music off
    NSString *musicString = nil;
    if ([[GameManager sharedGameManager] isMusicON]) {
        musicString = @"Turn Music Off";
    } else {
        musicString = @"Turn Music On";
    }
    CCLabelBMFont *musicLabel = [CCLabelBMFont labelWithString:musicString fntFile:@"score.fnt"];
    musicToggle = [CCMenuItemFont itemWithLabel:musicLabel
                                         target:self 
                                       selector:@selector(toggleMusic)];
    
    // Sound off
    NSString *soundString = nil;
    if ([[GameManager sharedGameManager] isSoundEffectsON]) {
        soundString = @"Turn Sound Off";
    } else {
        soundString = @"Turn Sound On";
    }
    CCLabelBMFont *soundLabel = [CCLabelBMFont labelWithString:soundString fntFile:@"score.fnt"];
    soundToggle = [CCMenuItemFont itemWithLabel:soundLabel target:self selector:@selector(toggleSound)];
    
    CCMenu *menu = [CCMenu menuWithItems:resumeItem, musicToggle, soundToggle, quitItem, nil];
    [menu alignItemsVerticallyWithPadding:0.03 * winSize.height];
    menu.position = ccp(winSize.width * 0.5, winSize.height * 0.42f);
    [self addChild:menu z:100];
}

#pragma mark - CCNode

-(void)onEnter {
    [super onEnter];
}

@end

