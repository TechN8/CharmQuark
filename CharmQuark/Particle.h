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
    kParticleRed = 0,
    kParticleOrange,
    kParticleYellow,
    kParticleGreen,
    kParticleBlue,
    kParticleIndigo,
    kParticleViolet,
} ParticleColors;

@interface Particle : CCSprite {
    //ParticleTypes type;
    CCMotionStreak *streak;
    ParticleColors particleColor;
    NSMutableArray *matchedParticles;
    cpShape* shape;
}

@property (retain) CCMotionStreak *streak;
@property ParticleColors particleColor;
@property (retain) NSMutableArray *matchedParticles;
@property (assign) cpShape *shape;

+ (id) particleWithColor:(ParticleColors)color;

- (id) initWithParticleColor:(ParticleColors)color;

- (void) addMatchingParticle:(Particle*)particle;

- (void) removeMatchingParticle:(Particle*)particle;

- (void) addMatchingParticlesToSet:(NSMutableSet*)particleSet;


@end
