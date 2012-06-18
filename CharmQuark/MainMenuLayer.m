//
//  MainMenuLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/18/12.
//  Copyright (c) 2012 Aether Theory, LLC. All rights reserved.
//

#import "MainMenuLayer.h"

@implementation MainMenuLayer
- (id)init
{
    self = [super init];
    if (self) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        CCSprite *background = [CCSprite spriteWithFile:@"MainMenuBackground.png"];
        [background setPosition:ccp(screenSize.width/2, 
                                    screenSize.height/2)];
        [self addChild:background];

    }
    return self;
}
@end
