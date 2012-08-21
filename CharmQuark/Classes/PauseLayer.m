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
#import "CQMenuItemFont.h"

@implementation PauseLayer

- (void) quitGame {
    [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
}

- (void) resumeParent {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGPoint offScreen = ccp(0, 2 * winSize.height);
    CCSequence *seq = [CCSequence actions:[CCMoveTo actionWithDuration:kPopupSpeed position:offScreen], 
                       [RemoveFromParentAction action],
                       [CCCallFunc actionWithTarget:self.parent selector:@selector(resume)], 
                       nil];
    [self runAction:seq];
}

- (void) toggleMusic {
    GameManager *sharedGameManager = [GameManager sharedGameManager];
    [sharedGameManager setIsMusicON:![sharedGameManager isMusicON]];
    if ([[GameManager sharedGameManager] isMusicON]) {
        [musicToggle setString:@"Music: On"];
    } else {
        [musicToggle setString:@"Music: Off"];
    }
}

- (void) toggleSound {
    GameManager *sharedGameManager = [GameManager sharedGameManager];
    [sharedGameManager setIsSoundEffectsON:![sharedGameManager isSoundEffectsON]];
    if ([[GameManager sharedGameManager] isSoundEffectsON]) {
        [soundToggle setString:@"Sound: On"];
    } else {
        [soundToggle setString:@"Sound: Off"];
    }
}

#pragma mark - ModalMenuLayer

-(void)initUI {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCLabelBMFont *title = [CCLabelBMFont labelWithString:@"Game Paused" fntFile:@"score.fnt"];
    title.color = kColorDialogTitle;
    title.position = kDialogTitlePos;
    title.scale = 1.3;
    [self addChild:title z:100];
    
    //Resume
    CCLabelBMFont *resumeLabel = [CCLabelBMFont labelWithString:@"Resume" fntFile:@"score.fnt"];
    resumeLabel.color = kColorButton;
    CQMenuItemFont *resumeItem = [CQMenuItemFont itemWithLabel:resumeLabel 
                                                        target:self 
                                                      selector:@selector(resumeParent)];
    
    //Quit
    CCLabelBMFont *quitLabel = [CCLabelBMFont labelWithString:@"Quit" fntFile:@"score.fnt"];
    quitLabel.color = kColorButton;
    CQMenuItemFont *quitItem = [CQMenuItemFont itemWithLabel:quitLabel
                                                      target:self 
                                                    selector:@selector(quitGame)];

    // Music off
    NSString *musicString = nil;
    if ([[GameManager sharedGameManager] isMusicON]) {
        musicString = @"Music: On";
    } else {
        musicString = @"Music: Off";
    }
    CCLabelBMFont *musicLabel = [CCLabelBMFont labelWithString:musicString fntFile:@"score.fnt"];
    musicLabel.color = kColorButton;
    musicToggle = [CQMenuItemFont itemWithLabel:musicLabel
                                         target:self 
                                       selector:@selector(toggleMusic)];
    
    // Sound off
    NSString *soundString = nil;
    if ([[GameManager sharedGameManager] isSoundEffectsON]) {
        soundString = @"Sound: On";
    } else {
        soundString = @"Sound: Off";
    }
    CCLabelBMFont *soundLabel = [CCLabelBMFont labelWithString:soundString fntFile:@"score.fnt"];
    soundLabel.color = kColorButton;
    soundToggle = [CQMenuItemFont itemWithLabel:soundLabel target:self selector:@selector(toggleSound)];
    CCMenu *menu1 = [CCMenu menuWithItems:musicToggle, soundToggle, nil];
    [menu1 alignItemsVerticallyWithPadding:0.03 * winSize.height];
    menu1.position = ccp(winSize.width * 0.5, winSize.height * 0.48f);
    [self addChild:menu1 z:100];
    
    CCMenu *menu2 = [CCMenu menuWithItems:resumeItem, quitItem, nil];
    [menu2 alignItemsHorizontallyWithPadding:0.15 * winSize.width];
    menu2.position = ccp(winSize.width * 0.5, winSize.height * 0.25f);
    [self addChild:menu2 z:100];
}

#pragma mark - CCNode

-(void)onEnter {
    [super onEnter];
}

@end

