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

#define kMinMatchAge            0.5

typedef enum {
    kParticleWhite = 0,
    kParticleRed,
    kParticleOrange,
    kParticleYellow,
    kParticleGreen,
    kParticleBlue,
    kParticleIndigo,
    kParticleViolet,
    kParticleBlack,
} ParticleColors;

@interface Particle : CCSprite {
    //ParticleTypes type;
    CCMotionStreak *streak;
    ParticleColors particleColor;
    cpBody* body;
    NSMutableSet *matchingParticles;
    ccTime timeSinceLastCollision;
    BOOL live;
}

@property (retain) CCMotionStreak *streak;
@property ParticleColors particleColor;
@property cpBody *body;
@property (retain) NSMutableSet *matchingParticles;
@property ccTime timeSinceLastCollision;
@property BOOL live;

+ (id) particleWithColor:(ParticleColors)color;

- (id) initWithParticleColor:(ParticleColors)color;

- (void) linkMatchingParticle:(Particle*)particle;

- (void) separateMatchingParticle:(Particle*)particle;

- (void) addMatchingParticlesToSet:(NSMutableSet*)set addTime:(ccTime)time;

@end
