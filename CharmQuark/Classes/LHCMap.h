//
//  Clock.h
//  CharmQuark
//
//  Created by Nathan Babb on 7/16/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Particle.h"

@interface LHCMap : CCNode {
    CCSprite *lhcMap;
    CCSprite *whitePacket;
    CCSprite *colorPacket;
    CCNode *clockwise;
    CCNode *antiClockwise;
}

-(void)setTime:(float)time;

-(void)setColor:(ParticleColors)color;

@end
