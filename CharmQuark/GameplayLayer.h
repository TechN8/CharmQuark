//
//  GameplayLayer.h
//  CharmQuark
//
//  Created by Nathan Babb on 6/19/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "chipmunk.h"

@interface GameplayLayer : CCLayerColor {
    cpSpace *space;
}

-(void) step: (ccTime) dt;
-(void) addNewSpriteX:(float)x Y:(float)y;

@end
