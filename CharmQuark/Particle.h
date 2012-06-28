//
//  Particle.h
//  CharmQuark
//
//  Created by Nathan Babb on 6/20/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"
#import "chipmunk.h"

typedef enum {
    kParticleRed = 1,
    kParticleOrange,
    kParticleYellow,
    kParticleGreen,
    kParticleBlue,
    kParticlePurple,
} ParticleColors;

@interface Particle : CCSprite {
    //ParticleTypes type;
    CCMotionStreak *streak;
    ParticleColors particleColor;
}

@property (retain) CCMotionStreak *streak;
@property ParticleColors particleColor;

+ (id) particleWithColor:(ParticleColors)color;

- (id) initWithParticleColor:(ParticleColors)color;

@end
