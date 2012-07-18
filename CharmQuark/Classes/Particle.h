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
    kParticleRed = 0,
    kParticleGreen,
    kParticleBlue,
    kParticleAntiRed,
    kParticleAntiGreen,
    kParticleAntiBlue,
    kParticleWhite
} ParticleColors;

@interface Particle : CCSprite {
    //ParticleTypes type;
    CCMotionStreak *streak;
    ParticleColors particleColor;
    cpBody* body;
    NSMutableSet *matchingParticles;
    ccTime timeSinceLastCollision;
    NSInteger touchingCount;
}

@property (retain) CCMotionStreak *streak;
@property ParticleColors particleColor;
@property cpBody *body;
@property (retain) NSMutableSet *matchingParticles;
@property ccTime timeSinceLastCollision;


+ (id) particleWithColor:(ParticleColors)color;

- (id) initWithParticleColor:(ParticleColors)color;

- (BOOL) isLive;

- (void) touchParticle:(Particle*)particle;

- (void) separateFromParticle:(Particle*)particle;

- (void) addMatchingParticlesToSet:(NSMutableSet*)set minMatch:(NSInteger) minMatch;

- (void) explode;

@end
