//
//  GameScene.h
//  CharmQuark
//
//  Created by Nathan Babb on 6/19/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "cocos2d.h"


@class GameplayLayer;
@class ControlLayer;

@interface GameScene : CCScene {
    GameplayLayer *gameplayLayer;
    ControlLayer *controlLayer;
}

@end
