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

@interface MainMenuLayer()
-(void)displayMainMenu;
@end

@implementation MainMenuLayer

-(void)showOptions {
    CCLOG(@"Show the Options screen");
}

-(void)playGame {
    CCLOG(@"Play the game.");
    [[GameManager sharedGameManager] runSceneWithID:kGameScene];
}

-(void)displayMainMenu {
    CGSize screenSize = [CCDirector sharedDirector].winSize; 
    //    if (sceneSelectMenu != nil) {
    //        [sceneSelectMenu removeFromParentAndCleanup:YES];
    //    }
    
    CCMenuItemImage *playButton = [CCMenuItemImage 
                                   itemFromNormalImage:@"PlayButtonNormal.png" 
                                   selectedImage:@"PlayButtonSelected.png" 
                                   disabledImage:nil 
                                   target:self 
                                   selector:@selector(playGame)];
    CCMenuItemImage *optionsButton = [CCMenuItemImage 
                                      itemFromNormalImage:@"OptionsButtonNormal.png" 
                                      selectedImage:@"OptionsButtonSelected.png" 
                                      disabledImage:nil 
                                      target:self 
                                      selector:@selector(showOptions)];
    mainMenu = [CCMenu menuWithItems:playButton,optionsButton, nil];
    [mainMenu alignItemsVerticallyWithPadding:screenSize.height * 0.059f];
    [mainMenu setPosition:
     ccp(screenSize.width * 2.0f,
         screenSize.height / 2.0f)];
    float scaleX = self.scaleX;
    id moveAction = 
    [CCMoveTo actionWithDuration:1.2f 
                        position:ccp(screenSize.width * 0.9f,
                                     screenSize.height/2.0f)];
    id moveEffect = [CCEaseIn actionWithAction:moveAction rate:1.0f];
    //id playChorus = [CCCallFunc actionWithTarget:
    //                 self selector:@selector(playChorus)];
    //id sequenceAction = [CCSequence actions:moveEffect,playChorus,nil];
    [mainMenu runAction:moveEffect];
    [self addChild:mainMenu z:0 tag:kMainMenuTagValue];
    
}

-(id)init {
    self = [super init];
    if (self) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        CCSprite *background = [CCSprite spriteWithFile:@"MainMenuBackground.png"];
        [background setPosition:ccp(screenSize.width/2, 
                                    screenSize.height/2)];
        [self addChild:background];
        
        [self displayMainMenu];
        
    }
    return self;
}
@end
