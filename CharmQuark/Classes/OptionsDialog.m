//
//  OptionsDialog.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/18/12.
//  Copyright (c) 2012 Aether Theory, LLC. All rights reserved.
//

#import "OptionsDialog.h"
#import "RemoveFromParentAction.h"
#import "GameManager.h"
#import "CQMenuItemFont.h"

@implementation OptionsDialog

- (void) resumeParent {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGPoint offScreen = ccp(0, 2 * winSize.height);
    CCSequence *seq = [CCSequence actions:[CCMoveTo actionWithDuration:kPopupSpeed position:offScreen], 
                       [RemoveFromParentAction action],
                       nil];
    [self runAction:seq];
}

- (void) toggleMusic {
    // TODO: Use CCMenuItemToggle for this?
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
    CCLabelBMFont *title = [CCLabelBMFont labelWithString:@"Options" fntFile:@"score.fnt"];
    title.color = kColorDialogTitle;
    title.position = kDialogTitlePos;
    title.scale = 1.3;
    [self addChild:title z:100];
    
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

//    //Resume
//    CCLabelBMFont *resumeLabel = [CCLabelBMFont labelWithString:@"Done" fntFile:@"score.fnt"];
//    CQMenuItemFont *resumeItem = [CQMenuItemFont itemWithLabel:resumeLabel 
//                                                        target:self 
//                                                      selector:@selector(resumeParent)];
    
    CCMenu *menu = [CCMenu menuWithItems:musicToggle, soundToggle, nil];
    
    [menu alignItemsVerticallyWithPadding:0.03 * winSize.height];
//    [menu alignItemsInColumns:[NSNumber numberWithUnsignedInt:2],
//     [NSNumber numberWithUnsignedInt:2], nil];
    menu.position = ccp(winSize.width * 0.5, winSize.height * 0.42f);
    [self addChild:menu z:100];
}

#pragma mark - CCTargetedTouchDelegate

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self resumeParent];
}

@end
