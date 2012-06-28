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
@synthesize matchedParticles;
@synthesize shape;

- (void) addMatchingParticle:(Particle*)particle {
    [matchedParticles addObject:particle];
}

- (void) removeMatchingParticle:(Particle*)particle {
    [matchedParticles removeObject:particle];
}

- (void) addMatchingParticlesToSet:(NSMutableSet*)particleSet {
    [particleSet addObject:self];
    for (Particle *particle in matchedParticles) {
        if (![particleSet containsObject:particle]) {
            [particle addMatchingParticlesToSet:particleSet];
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
        case kParticlePurple:
            self = [super initWithSpriteFrameName:@"Purple.png"];
            break;
        default:
            break;
    }
    if (self) {
        self.particleColor = color;
        self.streak = nil;
        self.matchedParticles = [[[NSMutableArray alloc] init] autorelease];
        self.shape = NULL;
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
    [matchedParticles release];
    [super dealloc];
}

@end
