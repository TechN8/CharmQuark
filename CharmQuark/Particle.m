//
//  Particle.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/20/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "Particle.h"

@implementation Particle

@synthesize particleColor;
@synthesize streak;
@synthesize body;
@synthesize matchingParticles;
@synthesize timeSinceLastCollision;
@synthesize live;

- (void) linkMatchingParticle:(Particle*)particle {
    // Put particles in eachothers node arrays.
    [matchingParticles addObject:particle];
    [particle.matchingParticles addObject:self];
    timeSinceLastCollision = 0;
}

- (void) separateMatchingParticle:(Particle*)particle {
    [matchingParticles removeObject:particle];
    [particle.matchingParticles removeObject:self];
    timeSinceLastCollision = 0;
}

- (void) addMatchingParticlesToSet:(NSMutableSet*)particleSet addTime:(ccTime)time {
    timeSinceLastCollision = timeSinceLastCollision + time;
    [particleSet addObject:self];
    for (Particle *particle in matchingParticles) {
        if (![particleSet containsObject:particle]) {
            [particle addMatchingParticlesToSet:particleSet addTime:time];
        }
    }
}

+ (id) particleWithColor:(ParticleColors)color 
{
    return [[[self alloc] initWithParticleColor:color] autorelease];
}

- (id) initWithParticleColor:(ParticleColors)color 
{
    switch (color) {
        case kParticleWhite:
            self = [super initWithSpriteFrameName:@"White.png"];
            break;
        case kParticleRed:
            self = [super initWithSpriteFrameName:@"Red.png"];
            break;
        case kParticleOrange:
            self = [super initWithSpriteFrameName:@"Orange.png"];
            break;
        case kParticleYellow:
            self = [super initWithSpriteFrameName:@"Yellow.png"];
            break;
        case kParticleGreen:
            self = [super initWithSpriteFrameName:@"Green.png"];
            break;
        case kParticleBlue:
            self = [super initWithSpriteFrameName:@"Blue.png"];
            break;
        case kParticleIndigo:
            self = [super initWithSpriteFrameName:@"Indigo.png"];
            break;
        case kParticleViolet:
            self = [super initWithSpriteFrameName:@"Violet.png"];
            break;
        case kParticleBlack:
            self = [super initWithSpriteFrameName:@"Black.png"];
            break;
        default:
            break;
    }
    if (self) {
        self.particleColor = color;
        self.streak = nil;
        self.matchingParticles = [NSMutableSet setWithCapacity:6];
        self.body = NULL;
        self.timeSinceLastCollision = 0;
        self.live = NO;
        
        // Add motion streak.
        // CCMotionStreak can't be parented to batch node....  Sad.
//        CCTexture2D *texture = nil; 
//        self.streak = [CCMotionStreak streakWithFade:0.5 minSeg:3 width:2 color:ccWHITE texture: texture];
//        [self addChild:streak];
    }
    return self;
}

#pragma mark -
#pragma mark NSObject

- (id)init
{
    return [self initWithParticleColor:kParticleRed];
}

- (void)dealloc
{
    [streak release];
    [matchingParticles release];
    [super dealloc];
}

@end
