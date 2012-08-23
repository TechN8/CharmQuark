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
    [super addCloseArrow];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCLabelBMFont *title = [CCLabelBMFont labelWithString:@"Records" fntFile:@"score.fnt"];
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
    label.position = ccp(winSize.width * 0.15, winSize.height * 0.60);
    [self addChild:label];
    
    // Time Attack Score
    scoreString = [NSString stringWithFormat:@"%d",
                   [[GameManager sharedGameManager] getHighScoreForSceneWithID:kGameSceneTimeAttack]];
    label = [CCLabelBMFont labelWithString:scoreString
                                   fntFile:@"score.fnt"];
    label.anchorPoint = ccp(1.0, 0.5);
    label.alignment = kCCTextAlignmentRight;
    label.color = kColorScore;
    label.position = ccp(winSize.width * 0.85, winSize.height * 0.60);
    [self addChild:label];
    
    // Accelerator Label
    label = [CCLabelBMFont labelWithString:@"Accelerator" fntFile:@"score.fnt"];
    label.anchorPoint = ccp(0, 0.5);
    label.alignment = kCCTextAlignmentLeft;
    label.color = kColorUI;
    label.position = ccp(winSize.width * 0.15, winSize.height * 0.50);
    [self addChild:label];
    
    // Accelerator Score
    scoreString = [NSString stringWithFormat:@"%d",
                            [[GameManager sharedGameManager] getHighScoreForSceneWithID:kGameSceneSurvival]];
    label = [CCLabelBMFont labelWithString:scoreString
                                   fntFile:@"score.fnt"];
    label.anchorPoint = ccp(1.0, 0.5);
    label.alignment = kCCTextAlignmentRight;
    label.color = kColorScore;
    label.position = ccp(winSize.width * 0.85, winSize.height * 0.50);
    [self addChild:label];
   
    // Meditation Label
    label = [CCLabelBMFont labelWithString:@"Meditation" fntFile:@"score.fnt"];
    label.anchorPoint = ccp(0, 0.5);
    label.alignment = kCCTextAlignmentLeft;
    label.color = kColorUI;
    label.position = ccp(winSize.width * 0.15, winSize.height * 0.40);
    [self addChild:label];
    
    // Meditation Score
    scoreString = [NSString stringWithFormat:@"%d",
                   [[GameManager sharedGameManager] getHighScoreForSceneWithID:kGameSceneMomMode]];
    label = [CCLabelBMFont labelWithString:scoreString
                                   fntFile:@"score.fnt"];
    label.anchorPoint = ccp(1.0, 0.5);
    label.alignment = kCCTextAlignmentRight;
    label.color = kColorScore;
    label.position = ccp(winSize.width * 0.85, winSize.height * 0.40);
    [self addChild:label];
    
    // Leaderboards
    CCSprite *lbNormal = [CCSprite spriteWithSpriteFrameName:@"leaderboard.png"];
    CCSprite *lbSelected = [CCSprite spriteWithSpriteFrameName:@"leaderboard.png"];
    CCSprite *lbDisabled = [CCSprite spriteWithSpriteFrameName:@"leaderboard.png"];
    lbNormal.color = kColorButton;
    lbSelected.color = kColorButtonSelected;
    lbDisabled.color = kColorUI;
    CCMenuItemSprite *lbItem = [CCMenuItemSprite itemWithNormalSprite:lbNormal
                                                       selectedSprite:lbSelected
                                                       disabledSprite:lbDisabled
                                                               target:[GCHelper sharedInstance]
                                                             selector:@selector(showLeaderboard)];
    
    // Achievements
    CCSprite *aNormal = [CCSprite spriteWithSpriteFrameName:@"achievements.png"];
    CCSprite *aSelected = [CCSprite spriteWithSpriteFrameName:@"achievements.png"];
    CCSprite *aDisabled = [CCSprite spriteWithSpriteFrameName:@"achievements.png"];
    aNormal.color = kColorButton;
    aSelected.color = kColorButtonSelected;
    aDisabled.color = kColorUI;
    CCMenuItemSprite *aItem = [CCMenuItemSprite itemWithNormalSprite:aNormal
                                                       selectedSprite:aSelected
                                                       disabledSprite:aDisabled
                                                               target:[GCHelper sharedInstance]
                                                             selector:@selector(showAchievements)];
    
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
    if ([self isButtonTouch:touch]) {
        [self resumeParent];
    }
}

@end
