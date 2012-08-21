//
//  HighScoreDialog.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/18/12.
//  Copyright (c) 2012 Aether Theory, LLC. All rights reserved.
//

#import "HighScoreDialog.h"
#import "RemoveFromParentAction.h"
#import "GameManager.h"
#import "Constants.h"
#import "GCHelper.h"

@implementation HighScoreDialog

- (void) resumeParent {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGPoint offScreen = ccp(0, 2 * winSize.height);
    CCSequence *seq = [CCSequence actions:[CCMoveTo actionWithDuration:kPopupSpeed position:offScreen], 
                       [RemoveFromParentAction action],
                       nil];
    [self runAction:seq];
}

#pragma mark - ModalMenuLayer

-(void)initUI {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCLabelBMFont *title = [CCLabelBMFont labelWithString:@"High Scores" fntFile:@"score.fnt"];
    title.color = kColorDialogTitle;
    title.position = kDialogTitlePos;
    title.scale = 1.3;
    [self addChild:title z:100];
    
    CCLabelBMFont *label;
    NSString *scoreString;
    
    // Time Attack Label
    label = [CCLabelBMFont labelWithString:@"Time Attack" fntFile:@"score.fnt"];
    label.anchorPoint = ccp(0, 0.5);
    label.alignment = kCCTextAlignmentLeft;
    label.color = kColorUI;
    label.position = ccp(winSize.width * 0.15, winSize.height * 0.55);
    [self addChild:label];
    
    // Time Attack Score
    scoreString = [NSString stringWithFormat:@"%d",
                   [[GameManager sharedGameManager] getHighScoreForSceneWithID:kGameSceneTimeAttack]];
    label = [CCLabelBMFont labelWithString:scoreString
                                   fntFile:@"score.fnt"];
    label.anchorPoint = ccp(1.0, 0.5);
    label.alignment = kCCTextAlignmentRight;
    label.color = kColorScore;
    label.position = ccp(winSize.width * 0.85, winSize.height * 0.55);
    [self addChild:label];
    
    // Accelerator Label
    label = [CCLabelBMFont labelWithString:@"Accelerator" fntFile:@"score.fnt"];
    label.anchorPoint = ccp(0, 0.5);
    label.alignment = kCCTextAlignmentLeft;
    label.color = kColorUI;
    label.position = ccp(winSize.width * 0.15, winSize.height * 0.45);
    [self addChild:label];
    
    // Accelerator Score
    scoreString = [NSString stringWithFormat:@"%d",
                            [[GameManager sharedGameManager] getHighScoreForSceneWithID:kGameSceneSurvival]];
    label = [CCLabelBMFont labelWithString:scoreString
                                   fntFile:@"score.fnt"];
    label.anchorPoint = ccp(1.0, 0.5);
    label.alignment = kCCTextAlignmentRight;
    label.color = kColorScore;
    label.position = ccp(winSize.width * 0.85, winSize.height * 0.45);
    [self addChild:label];
   
    // Meditation Label
    label = [CCLabelBMFont labelWithString:@"Meditation" fntFile:@"score.fnt"];
    label.anchorPoint = ccp(0, 0.5);
    label.alignment = kCCTextAlignmentLeft;
    label.color = kColorUI;
    label.position = ccp(winSize.width * 0.15, winSize.height * 0.35);
    [self addChild:label];
    
    // Meditation Score
    scoreString = [NSString stringWithFormat:@"%d",
                   [[GameManager sharedGameManager] getHighScoreForSceneWithID:kGameSceneMomMode]];
    label = [CCLabelBMFont labelWithString:scoreString
                                   fntFile:@"score.fnt"];
    label.anchorPoint = ccp(1.0, 0.5);
    label.alignment = kCCTextAlignmentRight;
    label.color = kColorScore;
    label.position = ccp(winSize.width * 0.85, winSize.height * 0.35);
    [self addChild:label];
    
    // Leaderboards
    CCLabelBMFont *lbLabel = [CCLabelBMFont labelWithString:@"Leaderboard"
                                                   fntFile:@"score.fnt"];
    CCMenuItemFont *lbItem = [CCMenuItemFont itemWithLabel:lbLabel
                                                   target:[GCHelper sharedInstance]
                                                 selector:@selector(showLeaderboard)];
    lbItem.color = kColorButton;
    lbItem.disabledColor = kColorUI;
    
    // Achievements
    CCLabelBMFont *aLabel = [CCLabelBMFont labelWithString:@"Achievements"
                                                    fntFile:@"score.fnt"];
    CCMenuItemFont *aItem = [CCMenuItemFont itemWithLabel:aLabel
                                                    target:[GCHelper sharedInstance]
                                                  selector:@selector(showAchievements)];
    aItem.color = kColorButton;
    aItem.disabledColor = kColorUI;
    
    if (![[GCHelper sharedInstance] isUserAuthenticated]) {
        lbItem.isEnabled = NO;
        aItem.isEnabled = NO;
    }
    
    // Menu
    CCMenu *menu = [CCMenu menuWithItems:lbItem, aItem, nil];
    //[menu alignItemsHorizontallyWithPadding:0.15 * winSize.width];
    [menu alignItemsHorizontally];
    menu.position = ccp(winSize.width * 0.5, winSize.height * 0.25f);
    
    [self addChild:menu];
}

#pragma mark - CCTargetedTouchDelegate

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self resumeParent];
}

@end
