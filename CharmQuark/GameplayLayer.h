//
//  GameplayLayer.h
//  CharmQuark
//
//  Created by Nathan Babb on 6/19/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "chipmunk.h"

// Gameplay Constants
#define kMinMatchSize           4
#define kPointsPerMatch         100
#define kRotationRate           1.0
#define kFailRadius             110.0

// Simulation Constants
#define kSimulationRate         0.00833
#define kParticleMass           5.0f
#define kParticleFriction       0.0f
#define kParticleElasticity     0.5f
#define kVelocityLimit          1500.0f
#define kParticleDamping        0.1f
#define kParticleCollisionType  1
#define kUnitVectorUp           ccp(0, 1)


enum {
	kTagBatchNode = 1,
};

@class Particle;

@interface GameplayLayer : CCLayerColor {
    // Chipmunk
    cpSpace *space;
    Particle *nextParticle;
    CCLabelAtlas *scoreLabel;
    
    // Cocos2D View Objects
    CCNode *centerNode;
    CCSpriteBatchNode *sceneSpriteBatchNode;
    
	// Touch handling
	CGFloat initialTouchAngle;
	CGFloat currentTouchAngle;
	CGFloat initialRotation;
    UITouch *rotationTouch;
    UITouch *launchTouch;
    
    // Game State
    long score;
    NSMutableSet *particles;
    NSMutableSet *countedParticles;
    NSMutableArray *scoredParticles;
    NSMutableSet *visitedParticles;
    NSMutableArray *inFlightParticles;
    BOOL scoring;
    BOOL gameOver;
}

@property cpSpace *space;
@property (retain) NSMutableSet *particles;
@property (retain) NSMutableSet *countedParticles;
@property (retain) NSMutableSet *visitedParticles;
@property (retain) NSMutableArray *scoredParticles;
@property (retain) NSMutableArray *inFlightParticles;
@property long score;
@property (retain) CCLabelAtlas *scoreLabel;
@property BOOL scoring;
@property BOOL gameOver;

@end
