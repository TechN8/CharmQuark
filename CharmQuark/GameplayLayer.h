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
#define kRotationRate           1.4

// Simulation Constants
#define kSimulationRate         0.00833
#define kParticleMass           5.0f
#define kParticleFriction       0.0f
#define kParticleElasticity     0.2f
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
    
    // Viewport
    CCNode *centerNode;
    CCSpriteBatchNode *sceneSpriteBatchNode;
    
	// Touch handling
	CGFloat initialTouchAngle;
	CGFloat currentTouchAngle;
	CGFloat initialRotation;
    BOOL touchesMoved;
    
    // Game Objects
    Particle *nextParticle;
    CCLabelAtlas *scoreLabel;
    NSMutableSet *scoredParticles;
    long score;
}

@property (assign) cpSpace *space;
@property (retain) NSMutableSet *scoredParticles;
@property (assign) long score;
@property (retain) CCLabelAtlas *scoreLabel;

@end
