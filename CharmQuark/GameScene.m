//
//  GameScene.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/19/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene
- (id)init
{
    self = [super init];
    if (self) {
        gameplayLayer = [GameplayLayer node];
        [self addChild:gameplayLayer];
    }
    return self;
}
@end
