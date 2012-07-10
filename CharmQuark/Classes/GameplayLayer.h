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
#define kMatchesPerLevel        10
#define kRotationRate           1.0
#define kFailRadius             110.0
#define kColorsInit             6
#define kColorsMax              6 //9

#define kLaunchV                800.0f
#define kGravity                400.0f

#define kLaunchVMax             1800.0f

#define kDropTimeInit           4.0f
#define kDropTimeMin            1.0f
#define kDropTimeStep           0.2f

// Simulation Constants
#define kSimulationRate         0.016667
#define kParticleMass           10.0f
#define kParticleFriction       0.07f // 0.0f
#define kParticleFrictionB      0.07f // 0.2f
#define kParticleElasticity     0.3f // 0.5f
#define kParticleElasticityB    0.3f // 0.8f
#define kVelocityLimit          2000.0f
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
    CCLabelAtlas *levelLabel;
    
    // Cocos2D View Objects
    CCNode *centerNode;
    CCSpriteBatchNode *sceneSpriteBatchNode;
    CCMenuItemSprite *resetButton;
    
	// Touch handling
    UITouch *rotationTouch;
	CGFloat rotTouchAngleInit;
	CGFloat rotTouchAngleCur;
	CGFloat centerNodeAngleInit;
    
    UITouch *aimTouch;
    CGFloat aimTouchAngleInit;
    CGFloat aimTouchAngleCur;
    CGFloat aimAngleInit;
    
    UITouch *launchTouch;
    
    // Game State
    long score;
    NSMutableSet *particles;
    NSMutableSet *countedParticles;
    NSMutableArray *scoredParticles;
    NSMutableSet *visitedParticles;
    NSMutableArray *inFlightParticles;
    //CGPoint targetPoint;
    BOOL scoring;
    BOOL gameOver;
    cpFloat dropTime;
    NSInteger colors;
    long level;
    NSInteger matchesToNextLevel;
    //ccTime timeToNextDrop;
    ccTime timeScale;

    CGFloat aimAngle;
}

@property cpSpace *space;
@property long score;

@end
