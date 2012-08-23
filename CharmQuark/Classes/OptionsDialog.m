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
#import "GCHelper.h"

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
    GameManager *sharedGameManager = [GameManager sharedGameManager];
    [sharedGameManager setIsMusicON:![sharedGameManager isMusicON]];
//    if ([[GameManager sharedGameManager] isMusicON]) {
//        [musicToggle setString:@"Music: On"];
//    } else {
//        [musicToggle setString:@"Music: Off"];
//    }
}

- (void) toggleSound {
    GameManager *sharedGameManager = [GameManager sharedGameManager];
    [sharedGameManager setIsSoundEffectsON:![sharedGameManager isSoundEffectsON]];
//    if ([[GameManager sharedGameManager] isSoundEffectsON]) {
//        [soundToggle setString:@"Sound: On"];
//    } else {
//        [soundToggle setString:@"Sound: Off"];
//    }
}

- (void) toggleTutorial {
    GameManager *sharedGameManager = [GameManager sharedGameManager];
    [sharedGameManager setShouldShowTutorial:![sharedGameManager shouldShowTutorial]];
//    if ([[GameManager sharedGameManager] shouldShowTutorial]) {
//        [tutorialToggle setString:@"Tutorial: On"];
//    } else {
//        [tutorialToggle setString:@"Tutorial: Off"];
//    }
}

#pragma mark - ModalMenuLayer

-(void)initUI {
    [super addCloseArrow];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCLabelBMFont *title = [CCLabelBMFont labelWithString:@"Options" fntFile:@"score.fnt"];
    title.color = kColorDialogTitle;
    title.position = kDialogTitlePos;
    title.scale = kDialogTitleScale;
    [self addChild:title z:100];
    
    CCMenu *menu = [CCMenu node];
    menu.anchorPoint = ccp(0,0);
    menu.position = ccp(0,0);
//    menu.contentSize = winSize;
    [self addChild:menu z:100];
    
    CCLabelBMFont *optionLabel, *onLabel, *offLabel;
    CCMenuItemFont *onItem, *offItem;
    
    // Music
    optionLabel = [CCLabelBMFont labelWithString:@"Music:"
                                   fntFile:@"score.fnt"];
    optionLabel.anchorPoint = ccp(1.0, 0.5);
    optionLabel.color = kColorUI;
    optionLabel.position = ccp(winSize.width * 0.45, winSize.height * 0.60);
    [self addChild:optionLabel];
    
    onLabel = [CCLabelBMFont labelWithString:@"On"
                                                    fntFile:@"score.fnt"];
    onItem = [CQMenuItemFont itemWithLabel:onLabel];
    onItem.color = kColorButton;
    offLabel = [CCLabelBMFont labelWithString:@"Off"
                                                    fntFile:@"score.fnt"];
    offItem = [CQMenuItemFont itemWithLabel:offLabel];
    offItem.color = kColorButton;
    musicToggle = [CCMenuItemToggle itemWithTarget:self
                                          selector:@selector(toggleMusic)
                                             items:onItem, offItem, nil];
    musicToggle.anchorPoint = ccp(0.0, 0.5);
    musicToggle.position = ccp(winSize.width * 0.55, winSize.height * 0.60);
    musicToggle.selectedIndex = [[GameManager sharedGameManager] isMusicON] ? 0 : 1;
    [menu addChild:musicToggle];
  
    // Sound
    optionLabel = [CCLabelBMFont labelWithString:@"Sound:"
                                         fntFile:@"score.fnt"];
    optionLabel.anchorPoint = ccp(1.0, 0.5);
    optionLabel.color = kColorUI;
    optionLabel.position = ccp(winSize.width * 0.45, winSize.height * 0.50);
    [self addChild:optionLabel];
    
    onLabel = [CCLabelBMFont labelWithString:@"On"
                                     fntFile:@"score.fnt"];
    onItem = [CQMenuItemFont itemWithLabel:onLabel];
    onItem.color = kColorButton;
    offLabel = [CCLabelBMFont labelWithString:@"Off"
                                      fntFile:@"score.fnt"];
    offItem = [CQMenuItemFont itemWithLabel:offLabel];
    offItem.color = kColorButton;
    soundToggle = [CCMenuItemToggle itemWithTarget:self
                                          selector:@selector(toggleSound)
                                             items:onItem, offItem, nil];
    soundToggle.anchorPoint = ccp(0.0, 0.5);
    soundToggle.position = ccp(winSize.width * 0.55, winSize.height * 0.50);
    soundToggle.selectedIndex = [[GameManager sharedGameManager] isSoundEffectsON] ? 0 : 1;
    [menu addChild:soundToggle];
    
    // Tutorial
    optionLabel = [CCLabelBMFont labelWithString:@"Tutorial:"
                                         fntFile:@"score.fnt"];
    optionLabel.anchorPoint = ccp(1.0, 0.5);
    optionLabel.color = kColorUI;
    optionLabel.position = ccp(winSize.width * 0.45, winSize.height * 0.40);
    [self addChild:optionLabel];
    
    onLabel = [CCLabelBMFont labelWithString:@"On"
                                     fntFile:@"score.fnt"];
    onItem = [CQMenuItemFont itemWithLabel:onLabel];
    onItem.color = kColorButton;
    offLabel = [CCLabelBMFont labelWithString:@"Off"
                                      fntFile:@"score.fnt"];
    offItem = [CQMenuItemFont itemWithLabel:offLabel];
    offItem.color = kColorButton;
    tutorialToggle = [CCMenuItemToggle itemWithTarget:self
                                          selector:@selector(toggleTutorial)
                                             items:onItem, offItem, nil];
    tutorialToggle.anchorPoint = ccp(0.0, 0.5);
    tutorialToggle.position = ccp(winSize.width * 0.55, winSize.height * 0.40);
    tutorialToggle.selectedIndex = [[GameManager sharedGameManager] shouldShowTutorial] ? 0 : 1;
    [menu addChild:tutorialToggle];

    
#ifdef DEBUG
    // Reset achievements!!!  Remove in release builds.
    CCLabelBMFont *resetLabel = [CCLabelBMFont labelWithString:@"Reset Achievements"
                                                       fntFile:@"score.fnt"];
    CQMenuItemFont *resetAchievements = [CQMenuItemFont itemWithLabel:resetLabel
                                                               target:[GCHelper sharedInstance]
                                                             selector:@selector(resetAchievements)];
    resetAchievements.color = ccRED;
    resetAchievements.position = ccp(winSize.width / 2, winSize.height * 0.25);
    
    [menu addChild:resetAchievements];
#endif
    
}

#pragma mark - CCTargetedTouchDelegate

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if ([self isButtonTouch:touch]) {
        [self resumeParent];
    }
}

@end
