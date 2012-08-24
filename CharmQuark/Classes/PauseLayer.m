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

-(void) restart {
    GameManager *gm = [GameManager sharedGameManager];
    [gm runSceneWithID:[gm curLevel]];
}

- (void) toggleMusic {
    GameManager *sharedGameManager = [GameManager sharedGameManager];
    [sharedGameManager setIsMusicON:![sharedGameManager isMusicON]];
}

- (void) toggleSound {
    GameManager *sharedGameManager = [GameManager sharedGameManager];
    [sharedGameManager setIsSoundEffectsON:![sharedGameManager isSoundEffectsON]];
}

#pragma mark - ModalMenuLayer

-(void)initUI {
    [super addCloseArrow];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCLabelBMFont *title = [CCLabelBMFont labelWithString:@"Game Paused" fntFile:@"score.fnt"];
    title.color = kColorDialogTitle;
    title.position = kDialogTitlePos;
    title.scale = kDialogTitleScale;
    [self addChild:title z:100];
    
    CCLabelBMFont *optionLabel, *onLabel, *offLabel;
    CCMenuItemFont *onItem, *offItem;
    
    // Music
    optionLabel = [CCLabelBMFont labelWithString:@"Music:"
                                         fntFile:@"score.fnt"];
    optionLabel.anchorPoint = ccp(1.0, 0.5);
    optionLabel.color = kColorUI;
    optionLabel.position = ccp(winSize.width * 0.45, winSize.height * 0.55);
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
    musicToggle.position = ccp(winSize.width * 0.55, winSize.height * 0.55);
    musicToggle.selectedIndex = [[GameManager sharedGameManager] isMusicON] ? 0 : 1;
    
    // Sound
    optionLabel = [CCLabelBMFont labelWithString:@"Sound:"
                                         fntFile:@"score.fnt"];
    optionLabel.anchorPoint = ccp(1.0, 0.5);
    optionLabel.color = kColorUI;
    optionLabel.position = ccp(winSize.width * 0.45, winSize.height * 0.45);
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
    soundToggle.position = ccp(winSize.width * 0.55, winSize.height * 0.45);
    soundToggle.selectedIndex = [[GameManager sharedGameManager] isSoundEffectsON] ? 0 : 1;
    
    //    //Resume
    //    CCLabelBMFont *resumeLabel = [CCLabelBMFont labelWithString:@"Resume" fntFile:@"score.fnt"];
    //    resumeLabel.color = kColorButton;
    //    CQMenuItemFont *resumeItem = [CQMenuItemFont itemWithLabel:resumeLabel 
    //                                                        target:self 
    //                                                      selector:@selector(resumeParent)];
    
    // Restart
    CCLabelBMFont *restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"score.fnt"];
    CQMenuItemFont *restartItem = [CQMenuItemFont itemWithLabel:restartLabel 
                                                         target:self 
                                                       selector:@selector(restart)];
    restartItem.color = kColorButton;
    restartItem.position = ccp(winSize.width * 0.33, winSize.height * 0.25f);
    
    
    //Quit
    CCLabelBMFont *quitLabel = [CCLabelBMFont labelWithString:@"Quit" fntFile:@"score.fnt"];
    CQMenuItemFont *quitItem = [CQMenuItemFont itemWithLabel:quitLabel
                                                      target:self 
                                                    selector:@selector(quitGame)];
    quitItem.color = kColorButton;
    quitItem.position = ccp(winSize.width * 0.66, winSize.height * 0.25f);
    
    CCMenu *menu1 = [CCMenu menuWithItems:musicToggle, soundToggle, restartItem, quitItem, nil];
    menu1.position = ccp(0,0);
    menu1.anchorPoint = ccp(0,0);
    [self addChild:menu1 z:100];
    
//    CCMenu *menu2 = [CCMenu menuWithItems:restartItem, quitItem, nil];
//    [menu2 alignItemsHorizontallyWithPadding:0.15 * winSize.width];
//    menu2.position = ccp(winSize.width * 0.5, winSize.height * 0.25f);
//    [self addChild:menu2 z:100];
}

#pragma mark - CCTargetedTouchDelegate

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
   
    if ([self isButtonTouch:touch]) {
        [self resumeParent];
    }
    if (location.x > winSize.width * 0.9 
        && location.y > winSize.height * 0.9) {
        [self resumeParent];
    }
}

@end

