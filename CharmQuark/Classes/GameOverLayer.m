//
//  GameOverLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 7/11/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "GameOverLayer.h"
#import "GameManager.h"

@implementation GameOverLayer

- (void) newGame {
    [[GameManager sharedGameManager] runSceneWithID:kGameScene];
}

#pragma mark - ModalMenuLayer

-(void)initMenus {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CCLabelTTF *title = [CCLabelTTF labelWithString:@"Game Over" fontName:@"American Typewriter" fontSize:40.0f];
    title.color = ccRED;
    title.position = ccp(winSize.width * 0.5, winSize.height * 0.8);
    [self addChild:title];
    
    //TODO: Replace with CCMenuItemAtlasFont
    //New Game
    CCMenuItemFont *newGameItem = [CCMenuItemFont itemWithString:@"New Game" target:self selector:@selector(newGame)];
    [newGameItem setFontName:@"American Typewriter"];
    [newGameItem setColor:ccBLACK];
    
    CCMenu *menu = [CCMenu menuWithItems:newGameItem, nil];
    [menu alignItemsVerticallyWithPadding:5];
    menu.position = ccp(winSize.width * 0.5, winSize.height * 0.5f);
    [self addChild:menu z:100];
    [menu runAction:[CCFadeIn actionWithDuration:1.0]];
}

@end
