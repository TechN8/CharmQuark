//
//  PauseLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 7/11/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "PauseLayer.h"
#import "GameManager.h"

@implementation PauseLayer

- (void) quitGame {
    [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
}

- (void) removeSelf {
    CCNode *parent = self.parent;
    [self removeFromParentAndCleanup:YES];
    [parent resumeSchedulerAndActions];
}

- (void) resumeParent {
    CCSequence *seq = [CCSequence actions:[CCFadeTo actionWithDuration:1.0f opacity:0], 
                       [CCCallFunc actionWithTarget:self selector:@selector(removeSelf)], 
                       nil];
    [self runAction:seq];
}

#pragma mark - ModalMenuLayer

-(void)initMenus {
    CGSize winSize = [[CCDirector sharedDirector] winSize];

    CCLabelTTF *title = [CCLabelTTF labelWithString:@"Game Paused" fontName:@"American Typewriter" fontSize:40.0f];
    title.color = ccBLACK;
    title.position = ccp(winSize.width * 0.5, winSize.height * 0.8);
    [self addChild:title];
    
    //TODO: Replace with CCMenuItemAtlasFont
    //Resume
    CCMenuItemFont *resumeItem = [CCMenuItemFont itemWithString:@"Resume" target:self selector:@selector(resumeParent)];
    [resumeItem setFontName:@"American Typewriter"];
    [resumeItem setColor:ccBLACK];
    //Quit
    CCMenuItemFont *quitItem = [CCMenuItemFont itemWithString:@"Quit" target:self selector:@selector(quitGame)];
    [quitItem setFontName:@"American Typewriter"];
    [quitItem setColor:ccBLACK];
    CCMenu *menu = [CCMenu menuWithItems:resumeItem, quitItem, nil];
    [menu alignItemsVerticallyWithPadding:5];
    menu.position = ccp(winSize.width * 0.5, winSize.height * 0.5f);
    [self addChild:menu z:100];
}

@end
