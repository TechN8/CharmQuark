//
//  GameplayLayer.h
//  CharmQuark
//
//  Created by Nathan Babb on 6/19/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "chipmunk.h"
#import "Clock.h"

// Gameplay Constants
#define kMinMatchSize           4
#define kPointsPerMatch         800
#define kMatchesPerLevel        5
#define kRotationRate           1.0f
#define kFailRadius             235.0f
#define kColorsInit             6
#define kColorsMax              6 //9

#define kLaunchV                1200.0f
#define kGravity                1200.0f

#define kLaunchVMax             1800.0f

#define kDropTimeInit           4.0f //4.0f
#define kDropTimeMin            1.4f
#define kDropTimeStep           0.2f

// Simulation Constants
#define kSimulationRate         0.016667f
#define kParticleRadius         32.0f
#define kParticleMass           10.0f
#define kParticleFriction       0.07f // 0.0f
#define kParticleFrictionB      0.07f // 0.2f
#define kParticleElasticity     0.3f // 0.5f
#define kParticleElasticityB    0.3f // 0.8f
#define kVelocityLimit          2000.0f
#define kParticleDamping        0.1f
#define kShapeCollisionType     1
#define kSensorCollisionType    2
#define kUnitVectorUp           ccp(0, 1)

// Device support
#define kiPhoneScaleFactor      0.46875f
#define kiPadScaleFactor        1.0f

enum {
	kTagBatchNode = 1,
};

@class Particle;

@interface GameplayLayer : CCLayerColor {
    // Chipmunk
    cpSpace *space;
    
    // Cocos2D Objects
    CCLabelBMFont *scoreLabel;
    CCLabelBMFont *levelLabel;
    CCNode *centerNode;
    CCSpriteBatchNode *sceneSpriteBatchNode;
    CCMenuItemSprite *resetButton;
    Particle *nextParticle;
    Clock *clock;
    
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
    NSInteger score;
    NSInteger comboLevel;
    NSInteger comboCount;
    NSInteger level;
    NSInteger matchesToNextLevel;

    cpFloat dropTime;
    cpFloat dropClock;
    NSInteger colors;

    NSMutableSet *particles;
    NSMutableSet *countedParticles;
    NSMutableArray *scoredParticles;
    NSMutableSet *visitedParticles;
    NSMutableArray *inFlightParticles;

    CGFloat aimAngle;
}

@property cpSpace *space;
@property NSInteger score;

@end
