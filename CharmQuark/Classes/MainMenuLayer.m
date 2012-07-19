//
//  MainMenuLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/18/12.
//  Copyright (c) 2012 Aether Theory, LLC. All rights reserved.
//

#import "MainMenuLayer.h"
#import "Constants.h"
#import "GameManager.h"
#import "GameOverLayer.h"

@interface MainMenuLayer()
-(void)displayMainMenu;
@end

@implementation MainMenuLayer

-(void)showOptions {
    CCLOG(@"Show the Options screen");
}

-(void)playSurvival {
    CCLOG(@"Play the game.");
    [[GameManager sharedGameManager] runSceneWithID:kGameSceneSurvival];
}

-(void)playTimeAttack {
    CCLOG(@"Play the game.");
    [[GameManager sharedGameManager] runSceneWithID:kGameSceneTimeAttack];
}

-(void)showScores {
    CCLOG(@"Show high scores.");
}

-(void)showCredits {
    CCLOG(@"Show credits screen.");
}

-(void)displayMainMenu {
    CGSize winSize = [CCDirector sharedDirector].winSize; 
    //self.isTouchEnabled = YES;

    CCLabelTTF *title = [CCLabelTTF labelWithString:@"Charm Quark" fontName:@"Courier" fontSize:40.0f];
    title.color = ccWHITE;
    title.position = ccp(winSize.width * 0.5, winSize.height * 0.95);
    [self addChild:title z:100];
    
    //TODO: Replace with CCMenuItemAtlasFont
    //Play
    CCMenuItemFont *survivalItem = [CCMenuItemFont itemWithString:@"Survival" target:self selector:@selector(playSurvival)];
    [survivalItem setFontName:@"Courier"];
    [survivalItem setColor:ccWHITE];

    CCMenuItemFont *timeAttackItem = [CCMenuItemFont itemWithString:@"Time Attack" target:self selector:@selector(playTimeAttack)];
    [timeAttackItem setFontName:@"Courier"];
    [timeAttackItem setColor:ccWHITE];
    
    //Options
    CCMenuItemFont *optionsItem = [CCMenuItemFont itemWithString:@"Options" target:self selector:@selector(showOptions)];
    [optionsItem setFontName:@"Courier"];
    [optionsItem setColor:ccWHITE];
    
    //High Scores
    CCMenuItemFont *scoresItem = [CCMenuItemFont itemWithString:@"High Scores" target:self selector:@selector(showScores)];
    [scoresItem setFontName:@"Courier"];
    [scoresItem setColor:ccWHITE];
    
    //Credits
    CCMenuItemFont *creditsItem = [CCMenuItemFont itemWithString:@"Credits" target:self selector:@selector(showCredits)];
    [creditsItem setFontName:@"Courier"];
    [creditsItem setColor:ccWHITE];
    
    mainMenu = [CCMenu menuWithItems:survivalItem, timeAttackItem, optionsItem, scoresItem, creditsItem, nil];
    [mainMenu alignItemsVerticallyWithPadding:10];
    
    [self addChild:mainMenu z:100];

    // Animate in menu.
    [mainMenu setPosition:ccp(winSize.width * 0.5, - 1 * winSize.height)];
    id moveAction = 
    [CCMoveTo actionWithDuration:1.2f 
                        position:ccp(winSize.width * 0.5, winSize.height * 0.5)];
    id moveEffect = [CCEaseIn actionWithAction:moveAction rate:1.0f];
    //id playChorus = [CCCallFunc actionWithTarget:
    //                 self selector:@selector(playChorus)];
    //id sequenceAction = [CCSequence actions:moveEffect,playChorus,nil];
    [mainMenu runAction:moveEffect];
    
}

-(void)onEnter {
    [super onEnter];

    [self displayMainMenu];
}

-(id)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
