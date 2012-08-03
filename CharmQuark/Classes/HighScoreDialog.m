//
//  OptionsLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/18/12.
//  Copyright (c) 2012 Aether Theory, LLC. All rights reserved.
//

#import "HighScoreDialog.h"
#import "RemoveFromParentAction.h"
#import "GameManager.h"
#import "Constants.h"

@implementation HighScoreDialog

- (void) resumeParent {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGPoint offScreen = ccp(0, 2 * winSize.height);
    CCSequence *seq = [CCSequence actions:[CCMoveTo actionWithDuration:0.5f position:offScreen], 
                       [CCCallFunc actionWithTarget:self.parent selector:@selector(dismissDialog)], 
                       [RemoveFromParentAction action],
                       nil];
    [self runAction:seq];
}

#pragma mark - ModalMenuLayer

-(void)initUI {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCLabelBMFont *title = [CCLabelBMFont labelWithString:@"High Scores" fntFile:@"score.fnt"];
    title.color = ccGREEN;
    title.position = ccp(winSize.width * 0.5, winSize.height * 0.7);
    title.scale = 1.5;
    [self addChild:title z:100];
    
    CCMenu *menu = [CCMenu node];
    
    // Accelerator
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"Accelerator" fntFile:@"score.fnt"];
    CCMenuItemFont *item = [CCMenuItemFont itemWithLabel:label];
    item.disabledColor = ccWHITE;
    item.isEnabled = NO;
    [menu addChild:item];
    
    NSString *scoreString = [NSString stringWithFormat:@"%d",
                            [[GameManager sharedGameManager] getHighScoreForSceneWithID:kGameSceneSurvival]];
    label = [CCLabelBMFont labelWithString:scoreString
                                   fntFile:@"score.fnt"];
    item = [CCMenuItemFont itemWithLabel:label];
    item.disabledColor = kScoreColor;
    item.isEnabled = NO;
    [menu addChild:item];
   
    // Time attack
    label = [CCLabelBMFont labelWithString:@"Time Attack" fntFile:@"score.fnt"];
    item = [CCMenuItemFont itemWithLabel:label];
    item.disabledColor = ccWHITE;
    item.isEnabled = NO;
    [menu addChild:item];
    
    scoreString = [NSString stringWithFormat:@"%d",
                             [[GameManager sharedGameManager] getHighScoreForSceneWithID:kGameSceneTimeAttack]];
    label = [CCLabelBMFont labelWithString:scoreString
                                   fntFile:@"score.fnt"];
    item = [CCMenuItemFont itemWithLabel:label];
    item.disabledColor = kScoreColor;
    item.isEnabled = NO;
    [menu addChild:item];

    
    // Meditation
    label = [CCLabelBMFont labelWithString:@"Meditation" fntFile:@"score.fnt"];
    item = [CCMenuItemFont itemWithLabel:label];
    item.disabledColor = ccWHITE;
    item.isEnabled = NO;
    [menu addChild:item];
    
    scoreString = [NSString stringWithFormat:@"%d",
                   [[GameManager sharedGameManager] getHighScoreForSceneWithID:kGameSceneMomMode]];
    label = [CCLabelBMFont labelWithString:scoreString
                                   fntFile:@"score.fnt"];
    item = [CCMenuItemFont itemWithLabel:label];
    item.disabledColor = kScoreColor;
    item.isEnabled = NO;
    [menu addChild:item];
    
    //Done
    CCLabelBMFont *resumeLabel = [CCLabelBMFont labelWithString:@"Done" fntFile:@"score.fnt"];
    CCMenuItemFont *resumeItem = [CCMenuItemFont itemWithLabel:resumeLabel 
                                                          target:self 
                                                        selector:@selector(resumeParent)];
    [menu addChild:resumeItem];
    
//    [menu alignItemsVerticallyWithPadding:0.03 * winSize.height];
    [menu alignItemsInColumns:[NSNumber numberWithUnsignedInt:2],
     [NSNumber numberWithUnsignedInt:2],
     [NSNumber numberWithUnsignedInt:2],
     [NSNumber numberWithUnsignedInt:1],
     nil];

    menu.position = ccp(winSize.width * 0.5, winSize.height * 0.42f);
    [self addChild:menu z:100];
}

@end
