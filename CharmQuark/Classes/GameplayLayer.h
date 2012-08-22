//
//  GameplayLayer.h
//  CharmQuark
//
//  Created by Nathan Babb on 6/19/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "chipmunk.h"
#import "LHCMap.h"
#import "Constants.h"
#import "Particle.h"
#import "Detector.h"
#import "LogViewer.h"

// Scoring
#define kMinMatchSize           5
#define kPointsPerMatch         200
#define kMatchesPerLevel        5
#define kFailRadius             235.0f
#define kColorsInit             6
#define kColorsMax              6 //9
#define kSweepRate              0.166667f

// Particle speed.
#define kLaunchV                1200.0f
#define kGravity                1200.0f
#define kLaunchVMax             1800.0f

// Accelerator
#define kDropTimeInit           2.8f
#define kDropTimeMin            0.8f // 2.8 - 0.8 = 10 levels.
#define kDropTimeStep           0.2f

// Time Attack
#define kTimeLimit              60.0f
#define kTimeAttackAdd          20.0

// Collision sound volume control
#define kMinSoundImpulse        1200.0f
#define kMaxSoundImpulse        4800.0f

// Rotation inertia
#define kRotationFalloff        5.0f
#define kRotationMaxAngleV      500.0f
#define kRotationMinAngleV      2.0f

// Simulation Constants
#define kSimulationRate         0.016667f
#define kParticleRadius         31.5f //32.0f
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
#define kLaunchCoolDown         0.10f

enum {
	kTagPacketBatchNode = 1,
    kTagUIBatchNode,
    kTagParticleBatchNode,
};

enum {
    kZBackground = 0,
    kZUIElements = 50,
    kZParticles = 100,
    kZLog = 150,
    kZPopups = 1000
};



@interface GameplayLayer : CCLayerColor {
    // Chipmunk
    cpSpace *space;
    
    // Cocos2D Objects
    CCLabelBMFont *scoreLabel;
//    CCLabelBMFont *levelLabel;
    CCNode *centerNode;
    CCMenuItemSprite *resetButton;
    Particle *nextParticle;
    LHCMap *map;
    CCSprite *thumbGuide;
    CCSprite *fireButton;
    Detector *detector;
    LogViewer *logViewer;
    
	// Rotation handling
    UITouch *rotationTouch;
    NSTimeInterval rotationTouchTime;
	CGPoint rotTouchPointInit;
	CGPoint rotTouchPointCur;
	CGFloat centerNodeAngleInit;
    CGFloat rotAngleV;

    // Launch Handling
    UITouch *launchTouch;
    ccTime lastLaunch;
    
    // Game State
//    SceneTypes mode;
    NSInteger score;
    NSInteger comboLevel;
    NSInteger comboCount;
    NSInteger level;
    NSInteger matchesToNextLevel;
    BOOL paused;
//    NSInteger tutorialStep;
    CGPoint puzzleCenter;

    cpFloat dropFrequency;
    cpFloat timeRemaining;
    NSInteger colors;

    NSMutableSet *particles;
    NSMutableSet *countedParticles;
    NSMutableArray *scoredParticles;
    NSMutableSet *visitedParticles;
    NSMutableArray *inFlightParticles;
}

@property cpSpace *space;
@property NSInteger score;

+(CCScene *) scene;
-(void)initUI;
-(void) gameStep;
-(BOOL) launch;
-(void) end:(Particle*)particle;
-(void) moveInFlightBodies;
-(void) resetGame;
-(BOOL) updateLevel;
-(void) pause;

@end

#pragma mark - Chipmunk Callbacks

void removeShapesFromBody(cpBody *body, cpShape *shape, GameplayLayer *self);
void postStepRemoveBody(cpSpace *space, cpBody *body, GameplayLayer *self);

void scheduleForRemoval(cpBody *body, GameplayLayer *self);

// This function synchronizes the body with the sprite.
void syncSpriteToBody(cpBody *body, GameplayLayer* self);

// This is what makes the particles cluster.  Tries to move towards the origin.
void gravityVelocityIntegrator(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt);

#pragma mark - Collision Handlers

int collisionBegin(cpArbiter *arb, struct cpSpace *space, GameplayLayer *self);
int collisionPreSolve(cpArbiter *arb, cpSpace *space, GameplayLayer *self);
void collisionPostSolve(cpArbiter *arb, cpSpace *space, GameplayLayer *self);
void collisionSeparate(cpArbiter *arb, cpSpace *space, GameplayLayer *self);


