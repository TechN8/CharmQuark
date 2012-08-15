//
//  GameplayLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/19/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "GameplayLayer.h"
#import "PauseLayer.h"
#import "GameOverLayer.h"
#import "RemoveFromParentAction.h"
#import "GameManager.h"

static CGPoint puzzleCenter;
static CGPoint nextParticlePos;
static CGPoint launchPoint;
static cpFloat launchV;
static CGFloat scaleFactor;
static CGPoint skewVector;

@interface GameplayLayer()

-(void) addBodyToSpace:(cpBody *)body;
-(void) addParticle:(Particle*)particle atPosition:(CGPoint)position;
-(void) alignParticleToCenter:(Particle *)particle;
-(void) end:(Particle*)particle;
-(void) launch;
-(void) pause;
-(Particle*) randomParticle;
-(Particle *) readyNextParticle;
-(void)resetGame;
-(void) resume;
-(BOOL) scoreParticles;
-(void) step: (ccTime) dt;
-(void) playRandomNoteAtVolume:(ALfloat)volume;

@end

static CGPoint worldToView(CGPoint point) {
    CGPoint newXY = cpvadd(cpvmult(point, scaleFactor), skewVector);
    return newXY;
}

#pragma mark -
#pragma mark Chipmunk Callbacks

static void removeShapesFromBody(cpBody *body, cpShape *shape, GameplayLayer *self) {
    cpSpace *space = cpBodyGetSpace(body);
    cpSpaceRemoveShape(space, shape);
    cpShapeFree(shape);
}

static void postStepRemoveParticle(cpSpace *space, cpBody *body, GameplayLayer *self) {
    Particle *particle = body->data;
    
    cpBodyEachShape(body, (cpBodyShapeIteratorFunc)removeShapesFromBody, self);
    
    cpSpaceRemoveBody(space, body);
    cpBodyFree(body);
    
    if (particle) {
//        [particle removeFromParentAndCleanup:YES];
    }
}

static void scheduleForRemoval(cpBody *body, GameplayLayer *self) {
    cpSpaceAddPostStepCallback(self.space, (cpPostStepFunc)postStepRemoveParticle, body, self);
}

// This function synchronizes the body with the sprite.
static void syncSpriteToBody(cpBody *body, GameplayLayer* self) {
	Particle *particle = body->data;
	if( particle ) {
		[particle setPosition: cpvmult(body->p, scaleFactor)];
	}
}

// This is what makes the particles cluster.  Tries to move towards the origin.
static void gravityVelocityIntegrator(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	cpVect p = cpBodyGetPos(body);
    //    //cpVect g = cpvmult(p, -200 * cpvlength(p) / (1.5f * screenCenter.y));
    cpVect g = cpv(0.0, 0.0);
    if (0.0f != cpvdist(g, p)) {
        // This can crash of the body is at (0,0).
        g = cpvmult(cpvnormalize(p), -1 * kGravity);
    }
	cpBodyUpdateVelocity(body, g, damping, dt);
}

#pragma mark -
#pragma mark Collision Handlers

static int collisionBegin(cpArbiter *arb, struct cpSpace *space, GameplayLayer *self)
{
    // Keep track of what particles this particle is touching.
    CP_ARBITER_GET_BODIES(arb, a, b);
    
    Particle *p1 = a->data;
    Particle *p2 = b->data;
    
    [p1 touchParticle:p2];
    [p2 touchParticle:p1];

    return TRUE;
}

static int collisionPreSolve(cpArbiter *arb, cpSpace *space, GameplayLayer *self)
{
    // Do nothing here.
    CP_ARBITER_GET_BODIES(arb, a, b);
    Particle *p1 = a->data;
    Particle *p2 = b->data;
    
    if (p1.particleColor == p2.particleColor) {
        cpArbiterSetElasticity(arb, kParticleElasticityB);
        cpArbiterSetFriction(arb, kParticleFrictionB);
    }
    
    return TRUE;
}

static void collisionPostSolve(cpArbiter *arb, cpSpace *space, GameplayLayer *self)
{
    // Do nothing here.
    CP_ARBITER_GET_BODIES(arb, a, b);
    
    if (cpArbiterIsFirstContact(arb)) {
        cpFloat impulse = cpvlength(cpArbiterTotalImpulse(arb));
        
        if(impulse > kMinSoundImpulse){
            ALfloat volume 
            = fmax(fminf((impulse - kMinSoundImpulse)/(kMaxSoundImpulse - kMinSoundImpulse), 1.0f), 0.0f);
            //CCLOG(@"Impulse = %f. Volume = %f", impulse, volume);
            [self playRandomNoteAtVolume:volume];
        }
    }
}

void collisionSeparate(cpArbiter *arb, cpSpace *space, GameplayLayer *self)
{
    // Unlink particle objects.
    CP_ARBITER_GET_BODIES(arb, a, b);
    
    Particle *p1 = a->data;
    Particle *p2 = b->data;
    
    [p1 separateFromParticle:p2];
    [p2 separateFromParticle:p1];
}

#pragma mark -

@implementation GameplayLayer

@synthesize space;
@synthesize score;

-(void)playRandomNoteAtVolume:(ALfloat)volume {
    switch(rand() % 15) {
        case 0:
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE_1, volume);
            break;
        case 1:
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE_2, volume);
            break;
        case 2:
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE_3, volume);
            break;
        case 3:
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE_4, volume);
            break;
        case 4:
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE_5, volume);
            break;
        case 5:
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE_6, volume);
            break;
        case 6:
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE_7, volume);
            break;
        case 7:
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE_8, volume);
            break;
        case 8:
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE_9, volume);
            break;
        case 9:
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE_10, volume);
            break;
        case 10:
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE_11, volume);
            break;
        case 11:
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE_12, volume);
            break;
        case 12:
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE_13, volume);
            break;
        case 13:
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE_14, volume);
            break;
        case 14:
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE_15, volume);
            break;
        case 15:
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE_16, volume);
            break;
        default:
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE_2, volume);
            break;
    }
}

-(void)resetGame {
    paused = NO;
    
    // Each level should be the same?
    srand(94876);
    
    // Reset angle
    centerNode.rotation = 0;
    
    score = 0;
    comboLevel = 0;
    comboCount = 0;
    level = 1;
    matchesToNextLevel = kMatchesPerLevel;
    
    switch ([GameManager sharedGameManager].curLevel) {
        case kGameSceneTimeAttack:
            dropFrequency = kTimeLimit;
            timeRemaining = dropFrequency;
            [levelLabel setString:[NSString stringWithFormat:@"%01d:%02d.%02d", 
                                   (int)timeRemaining / 60,
                                   (int)(fmodf(timeRemaining, 60)),
                                   (int)(fmodf(timeRemaining, 1.0) * 100)]];
            break;
        case kGameSceneSurvival:
        default:
            dropFrequency = kDropTimeInit;
            timeRemaining = dropFrequency;
            [levelLabel setString:@"Level 1"];
            break;
    }
    
    launchV = kLaunchV;
    colors = kColorsInit;
    
    // Clear the scoreboard
    [scoreLabel setString:@"0"];
    
    // Remove all objects from the space.
    cpSpaceEachBody(space, (cpSpaceBodyIteratorFunc)scheduleForRemoval, self);
    for (Particle *particle in particles) {
        [particle removeFromParentAndCleanup:YES];
    }
    [particles removeAllObjects];
    
    // Remove in-flight perticles too.
    for (Particle *particle in inFlightParticles) {
        cpBodyFree(particle.body);
        [particle removeFromParentAndCleanup:YES];
    }
    [inFlightParticles removeAllObjects];
    
    // Set up the next particle.
    if (nextParticle) {
        [nextParticle removeFromParentAndCleanup:YES];
    }
    nextParticle = [self randomParticle];
    
    // Add the initial set of particles.
    Particle *particle = [self readyNextParticle];
    [self addParticle:particle atPosition:puzzleCenter];
    CGFloat angle = 0.0;
    for (NSInteger i = 0; i < 6; i++) {
        Particle *particle = [self readyNextParticle];
        CGPoint pos = ccp(puzzleCenter.x + (kParticleRadius * 2 * scaleFactor) * cos(angle),
                          puzzleCenter.y - (kParticleRadius * 2 * scaleFactor) * sin(angle));
        
        [self addParticle:particle atPosition:pos];
        angle += M_PI / 3;
    }
    
    // Schedule scoring timer.
    [self schedule:@selector(scoreParticles) interval:kSweepRate];
    
    // Start animation / simulation timer.
    [self schedule: @selector(step:)];
}

-(Particle*)randomParticle {
    Particle *particle = nil;
    ParticleColors color = rand() % colors; //9;
    particle = [Particle particleWithColor:color]; 
    
    // May want to add the below to the Particle class.
	// Create physics body.
    cpBody *body = cpBodyNew(kParticleMass, cpMomentForCircle(1.0f, 0, 15.0f, CGPointZero));
    
    body->data = particle;
    particle.body = body;
    cpBodySetPos(body, cpv(INT16_MAX, INT16_MAX));
    
    return particle;
}

-(Particle *)readyNextParticle {
    Particle *particle = nextParticle;
    particle.scale = 1.0;
    // Set up next particle
    nextParticle = [self randomParticle];
    nextParticle.position = nextParticlePos;
    [map setColor:nextParticle.particleColor];
    [[self getChildByTag:kTagUIBatchNode] addChild:nextParticle];
    
    // Create physics shape.
    cpShape* shape = cpCircleShapeNew(particle.body, kParticleRadius, CGPointZero);
    cpShapeSetFriction(shape, kParticleFriction);
    cpShapeSetElasticity(shape, kParticleElasticity);
    cpShapeSetCollisionType(shape, kShapeCollisionType);
	cpSpaceAddShape(space, shape);
    
    // Create sensor shape to handle slow collisions.
    cpShape* sensor = cpCircleShapeNew(particle.body, kParticleRadius + 0.5, CGPointZero);
    cpShapeSetSensor(sensor, YES);
    cpShapeSetCollisionType(sensor, kSensorCollisionType);
	cpSpaceAddShape(space, sensor);
    
    return particle;
}

-(void) launch {
    // Make sure it's legal.
    if (lastLaunch < kLaunchCoolDown) {
        CCLOG(@"Ignored launch during cooldown.");
        return;
    }
    
    // Launch!
    if (mode == kGameSceneSurvival) {
        timeRemaining = dropFrequency;   
    }
    lastLaunch = 0;
    
    // Calculate launch position and vector.
    cpVect rot = cpvforangle(CC_DEGREES_TO_RADIANS(centerNode.rotation));
    CGPoint pos = cpvrotate(rot, kLaunchPoint);
    cpVect launchVect = cpvmult(cpvnormalize(cpvsub(ccp(0,0), pos)), kLaunchV);

    // Set position and velocity of particle.
    Particle *particle = [self readyNextParticle];
    cpBody *body = particle.body;
    cpBodySetPos(body, pos);
    cpBodySetVel(body, launchVect);
    particle.position = [centerNode convertToWorldSpace:launchPoint];
    
    // Mark particle as in-flight.
    particle.isInFlight = YES;
    [inFlightParticles addObject:particle];
    
    // Add to batch node for rendering.
    [particle removeFromParentAndCleanup:NO];
    CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [centerNode getChildByTag:kTagPacketBatchNode];
    [batch addChild: particle];
}

-(void) addBodyToSpace:(cpBody *)body {
    // Add body to space.
    body->velocity_func = gravityVelocityIntegrator;
    cpBodySetVelLimit(body, kVelocityLimit);
    cpSpaceAddBody(space, body);
}

-(void) addParticle:(Particle*)particle atPosition:(CGPoint)position
{
    // Add to list for scoring.
    [particles addObject:particle];
    
    // Convert position coordinates.
    position = [centerNode convertToNodeSpace:position];
	particle.position = position;
    
    // Remove from layer and add to batch node.
    [particle removeFromParentAndCleanup:NO];
    CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [centerNode getChildByTag:kTagPacketBatchNode];
    [batch addChild: particle];
    
    cpBody *body = particle.body;
    
    // Rotate body to match centerNode.
    cpFloat v = cpvlength(body->v);
    if (v > 0.0f) {
        cpVect rot = cpvforangle(CC_DEGREES_TO_RADIANS(centerNode.rotation));
        cpVect a = cpvrotate(cpvnormalize(body->v), rot);
        cpBodySetVel(body, cpvmult(a, v));
    }
    cpBodySetPos(body, cpvmult(position, 1.0/scaleFactor));
    [self addBodyToSpace:body];
}

-(void) addPoints:(NSInteger)points {
    if (points > 0) {
        score += points;
        [scoreLabel setString:[[[NSString alloc] initWithFormat:@"%d", score] autorelease]];
    }
}

-(void) updateLevel {
    // Update level
    if (matchesToNextLevel <= 0) {
        matchesToNextLevel += kMatchesPerLevel;
        switch (mode) {
            case kGameSceneTimeAttack:
                timeRemaining += kTimeAttackAdd;
                [logViewer addMessage:[NSString stringWithFormat:@"+%d Seconds!", (int)kTimeAttackAdd]
                                color:kColorTimeAdd];
                break;
            case kGameSceneSurvival:
                level++;
                dropFrequency -= kDropTimeStep;
                if (dropFrequency <= kDropTimeMin) {
                    dropFrequency = kDropTimeMin;
                }
                [levelLabel setString:[NSString stringWithFormat:@"Level %d", level]];
                [logViewer addMessage:[NSString stringWithFormat:@"Level %d!", level]
                                color:kColorLevelUp];
                break;
            default:
                break;
        }
    }
}

-(void) animateText:(NSString *)bonusString atPosition:(CGPoint)position {
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:bonusString fntFile:@"score.fnt"];
    label.position = position;
    id move = [CCMoveBy actionWithDuration:1.0f position:ccp(0, 100)];
    id fade = [CCFadeOut actionWithDuration:1.0f];
    id remove = [RemoveFromParentAction action];
    id seq = [CCSequence actions:fade, remove, nil];
    [self addChild:label z:kZUIElements];
    [label runAction:move];
    [label runAction:seq];
}

-(BOOL) scoreParticles {
    NSInteger multiplier = 0;
    NSInteger points = 0;
    BOOL gameOver = NO;
    Particle *gameOverParticle = nil;
    
    // Reset
    [visitedParticles removeAllObjects];
    
    // Iterate on collidedParticles
    for (Particle *particle in particles) {
        if ([particle isLive]) {
            // Check game over condition.
            if (cpvlength(cpBodyGetPos(particle.body)) >= kFailRadius - kParticleRadius) {
                gameOver = YES;
                gameOverParticle = particle;
            }

            // Don't double count.
            if (![visitedParticles containsObject:particle]) {
                
                // Add self and all matching to scoredParticles && visitedParticles.
                [countedParticles removeAllObjects];
                [particle addMatchingParticlesToSet:countedParticles 
                                           minMatch:kMinMatchSize
                                        requireLive:!gameOver];
                [visitedParticles unionSet:countedParticles];
                
                // If scoredParticles > kMinMatchSize then move them to final array?
                if (countedParticles.count >= kMinMatchSize) {
                    for (Particle *p in countedParticles) {
                        [scoredParticles addObject:p];
                    }
                    matchesToNextLevel--;
                    multiplier = countedParticles.count - kMinMatchSize + 1;
                    points = kPointsPerMatch;
                    
                    if (multiplier > 1) {
                        points *= multiplier;
                        // Play multiplier animation.
                        [logViewer addMessage:[NSString stringWithFormat:@"%dX Bonus!", multiplier]
                                        color:kColorBonus];
                    }
                    
                    if (comboLevel) {
                        points *= comboLevel + 1;
                        [logViewer addMessage:[NSString stringWithFormat:@"%dX Combo!", comboLevel + 1]
                                        color:kColorCombo];
                    }
                    
                    comboCount = 2 / kSweepRate;  // Two seconds.
                    comboLevel++;
                    
                    [self addPoints:points]; // Update score.
                    [logViewer addMessage:[NSString stringWithFormat:@"%d", points]
                                    color:kColorScore];
                }
            }
        }
    }
    
    // Reset combo if no points.
    if (!points) {
        comboCount--;
        if (comboCount <=0) {
            comboLevel = 0;
        }
    }
    
    [self updateLevel]; // Update level.

    if (points) {
//        PLAYSOUNDEFFECT(PARTICLE_EXPLODE, 1.0);
        [self playRandomNoteAtVolume:1.0];
        [self playRandomNoteAtVolume:1.0];
        [self playRandomNoteAtVolume:1.0];
        gameOver = NO;
    }
    
    // Delete scored particles.  If this is done in the iterator, will throw exceptions.
    while (scoredParticles.count > 0) {
        Particle *particle = [scoredParticles objectAtIndex:0];
        [scoredParticles removeObject:particle];
        [particles removeObject:particle];
        
        CCParticleSystemQuad *explosion = [particle explode];  // Play the explosion animation.
        explosion.position = [centerNode convertToWorldSpace:particle.position];
        [[self getChildByTag:kTagParticleBatchNode] addChild:explosion];
        
//        switch (rand() & 3) {
//            case 0:
//                [detector animateAtAngle:-1 * explosion.angle graphColor:ccc3(0, 255, 255)];
//                break;
//            case 1:
//                [detector animateAtAngle:-1 * explosion.angle graphColor:ccc3(255, 255, 0)];
//                break;
//            default:
                [detector animateAtAngle:-1 * explosion.angle graphColor:ccGREEN];
//                break;
//        }
        
//        if (comboLevel > 1) {
//            [detector animateAtAngle:-1 * explosion.angle graphColor:ccc3(0, 255, 128)];
//        } else if (multiplier > 1) {
//            [detector animateAtAngle:-1 * explosion.angle graphColor:ccc3(128, 255, 0)];
//        } else {
//            [detector animateAtAngle:-1 * explosion.angle graphColor:ccGREEN];
//        }

        postStepRemoveParticle(space, particle.body, self);  // Don't need to schedule, called from update.
    }
    
    if (gameOver) {
        [self end:gameOverParticle];
    }
    
    if (points) {
        return YES;
    }
    return NO;
}

-(void) alignParticleToCenter:(Particle *)particle {
    // Rotate particle position and velocity the other way.
    cpBody *body = particle.body;
    cpVect rot = cpvforangle(CC_DEGREES_TO_RADIANS(centerNode.rotation));
    cpFloat distance = -1 * cpvlength(body->p);
    cpFloat speed = cpvlength(body->v);
    cpVect pos = cpvmult(rot, distance);
    cpVect vel = cpvmult(rot, speed);
    cpBodySetPos(body, pos);
    cpBodySetVel(body, vel);
    particle.position = cpvmult(pos, scaleFactor);
}

-(void) moveInFlightBodies {
    for (NSInteger i=0; i < inFlightParticles.count; i++) {
        Particle *particle = [inFlightParticles objectAtIndex:i];
        cpBody * body = particle.body;
        cpBodyUpdatePosition(body, kSimulationRate);
        particle.position = cpvmult(body->p, scaleFactor);
        cpFloat d = cpvlength(cpBodyGetPos(body));
        if (d < 5) particle.isInFlight = NO;
        if (!particle.isInFlight) {
            // Add body to space.
            [self addBodyToSpace:body];
            
            // Add to list for scoring.
            [particles addObject:particle];
            
            // Remove from in-flight list.
            [inFlightParticles removeObject:particle];
            i--;
        }
    }
}

-(void) step: (ccTime)dt {
    static ccTime remainder = 0;
    dt += remainder;
    int steps = dt / kSimulationRate;
    remainder = fmodf(dt, kSimulationRate);
    
    // Run steps
    for (int i = 0; i < steps; i++) {
        // Update clock.
        timeRemaining -= kSimulationRate;
        lastLaunch += kSimulationRate;
        [map setTime:(dropFrequency - timeRemaining) / dropFrequency];
        
        // Check for gameover or drop conditions.
        if (timeRemaining <= 0) {
            switch (mode) {
                case kGameSceneTimeAttack:
                    timeRemaining = 0;
                    [self end:nil]; // Game over.
                    break;
                case kGameSceneSurvival:
                    [self drop];
                    break;
                case kGameSceneMomMode:
                default:
                    timeRemaining = dropFrequency;
                    break;
            }
        }

        // Update time attack countdown.
        if (mode == kGameSceneTimeAttack) {
            [levelLabel setString:[NSString stringWithFormat:@"%01d:%02d.%02d", 
                                   (int)timeRemaining / 60,
                                   (int)(fmodf(timeRemaining, 60)),
                                   (int)(fmodf(timeRemaining, 1.0) * 100)]];
        }
        
        // Update touch inertia.
        if (nil == rotationTouch && fabs(rotAngleV) > 1) {
            centerNode.rotation = fmodf(centerNode.rotation + rotAngleV * dt, 360.0);
            rotAngleV *= 1 - (kRotationFalloff * kSimulationRate);
        }
        
        // Update physics and move stuff.
        cpSpaceStep(space, kSimulationRate);
        cpSpaceEachBody(space, (cpSpaceBodyIteratorFunc)syncSpriteToBody, self);
        [self moveInFlightBodies];
    }
}

-(void) drop {
    launchTouch = nil; // Prevent double launch on touch end.
    fireButton.opacity = 0;
    [self launch];
}

-(void) pause {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    if (!paused) {
        paused = YES;
        [self pauseSchedulerAndActions];
        
        // Throw up modal layer.
        PauseLayer *pauseLayer = [PauseLayer node];
        CGPoint oldPos = pauseLayer.position;
        pauseLayer.position = ccp(0, 2 * winSize.height);
        [self addChild:pauseLayer z:kZPopups];
        [pauseLayer runAction:[CCMoveTo actionWithDuration:kPopupSpeed
                                                  position:oldPos]];
    }
}

-(void) resume {
    paused = NO;
    [self resumeSchedulerAndActions];
}

-(void)end:(Particle *)particle {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    [[GameManager sharedGameManager] stopBackgroundTrack];
    PLAYSOUNDEFFECT(GAME_OVER, 0.5);
    
    // Cancel touches.
    rotationTouch = nil;
    launchTouch = nil;
    
    [self unscheduleAllSelectors];
    
    // Flash the detector.
    if (nil != particle) {
        // Calculate angle
        float angle = -1 * CC_RADIANS_TO_DEGREES(cpvtoangle(cpBodyGetPos(particle.body)));
        angle += centerNode.rotation;
        [detector gameOverAtAngle:angle];
        id flash = [CCBlink actionWithDuration:1.0 blinks:2];
        id loop = [CCRepeatForever actionWithAction:flash];
        [particle runAction:loop];
    }
    
    // Throw up modal layer.
    GameOverLayer *gameOverLayer = [GameOverLayer node];
    CGPoint oldPos = gameOverLayer.position;
    gameOverLayer.position = ccp(0, 2 * winSize.height);
    [gameOverLayer setScore:score];
    [self addChild:gameOverLayer z:kZPopups];
    [gameOverLayer runAction:[CCMoveTo actionWithDuration:kPopupSpeed
                                                 position:oldPos]];
}


-(void)initUI {
    self.isTouchEnabled = YES;
    self.isAccelerometerEnabled = NO;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // Static variables.
    puzzleCenter = worldToView(kPuzzleCenter);
    CGPoint scorePosition = ccp(10, winSize.height * 0.95f);
    CGPoint levelPosition = ccp(winSize.width * 0.5f, winSize.height * 0.95f);
    
    launchPoint = worldToView(kLaunchPoint);
    
    // Field initializations
    rotationTouch = nil;
    launchTouch = nil;
    centerNodeAngleInit = 0;
    nextParticle = nil;
    
    // Set up simulation.
    space = cpSpaceNew();
    cpSpaceSetGravity(space, ccp(0,0));
    cpSpaceSetDamping(space, kParticleDamping);
    cpSpaceAddCollisionHandler(space, 
                               kSensorCollisionType, kSensorCollisionType, 
                               (cpCollisionBeginFunc)collisionBegin, 
                               (cpCollisionPreSolveFunc)collisionPreSolve, 
                               nil, 
                               (cpCollisionSeparateFunc)collisionSeparate, 
                               self);
    cpSpaceAddCollisionHandler(space, 
                               kShapeCollisionType, kShapeCollisionType, 
                               nil, 
                               nil, 
                               (cpCollisionPostSolveFunc)collisionPostSolve, 
                               nil, 
                               self);   
    
    // Configure the two batch nodes for rendering.
    CCSpriteBatchNode *packetBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"scene1Atlas.png" capacity:45];
    CCSpriteBatchNode *uiBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"scene1Atlas.png" capacity:60];
    CCParticleBatchNode *particleBatch = [CCParticleBatchNode batchNodeWithFile:@"scene1Atlas.png" capacity:100];
    [self addChild:uiBatchNode z:kZUIElements tag:kTagUIBatchNode];
    [self addChild:particleBatch z:kZParticles tag:kTagParticleBatchNode];
    
    // Pause Button
    CCSprite *pauseSprite = [CCSprite spriteWithSpriteFrameName:@"pause.png"];
    [pauseSprite setPosition:ccp(winSize.width * 0.95f, winSize.height * 0.95f)];
    [uiBatchNode addChild:pauseSprite z:kZUIElements];
    
    // Add score label.
    scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"score.fnt"];
    [scoreLabel setAnchorPoint:ccp(0.0f, 0.5f)];
    [scoreLabel setPosition:scorePosition];
    [scoreLabel setColor:kColorScore];
    [self addChild:scoreLabel z:kZUIElements];
    
    // Add level label / clock
    switch (mode) {
        case kGameSceneTimeAttack:
            levelLabel= [CCLabelBMFont labelWithString:@"2:00.00" fntFile:@"score.fnt"];
            levelLabel.position = levelPosition;
            levelLabel.color = kColorUI;
            [self addChild:levelLabel z:kZUIElements];
            break;
        case kGameSceneSurvival:
            levelLabel = [CCLabelBMFont labelWithString:@"Level 1" fntFile:@"score.fnt"];
            levelLabel.position = levelPosition;
            levelLabel.color = kColorUI;
            [self addChild:levelLabel z:kZUIElements];
            break;
        default:
            break;
    }
    
    // Add Next
    CGPoint nextLabelPosition = ccp(scorePosition.x,
                            scorePosition.y - scoreLabel.contentSize.height - 10 * scaleFactor);
    CCLabelBMFont *nextLabel = [CCLabelBMFont labelWithString:@"Next:" fntFile:@"score.fnt"];
    nextLabel.color = kColorUI;
    nextLabel.position = nextLabelPosition;
    [nextLabel setAnchorPoint:ccp(0.0, 0.5)];
    [self addChild:nextLabel z:kZUIElements];

    nextParticlePos = ccp(nextLabelPosition.x + nextLabel.contentSize.width + kParticleRadius * scaleFactor,
                          nextLabelPosition.y);
    
    // Add the map.
    map = [LHCMap node];
    map.anchorPoint = ccp(0.02, 0.5);
    //map.position = ccp(0, winSize.height * 0.62);
    map.position = ccp(0, puzzleCenter.y);
    [uiBatchNode addChild:map z:kZBackground];
    
    // Add the log viewer.
    logViewer = [LogViewer node];
    //logViewer.position = ccp(10, 5);
    //logViewer.position = ccp(winSize.width / 2, winSize.height / 2);
    logViewer.position = puzzleCenter;
    [self addChild:logViewer z:kZLog];
    
    // Add the detector.
    detector = [Detector node];
    detector.position = puzzleCenter;
    [uiBatchNode addChild:detector z:kZBackground];
    
    // Add the thumb guides.
    thumbGuide = [CCSprite spriteWithSpriteFrameName:@"thumbguide.png"];
    thumbGuide.opacity = 0;
    [uiBatchNode addChild:thumbGuide z:kZUIElements - 1];
    
    fireButton = [CCSprite spriteWithSpriteFrameName:@"firebutton.png"];
    fireButton.opacity = 0;
    [uiBatchNode addChild:fireButton z:kZUIElements];
    
    // Configure the node which controls rotation.
    centerNode = [CCNode node];
    centerNode.position = puzzleCenter;
    centerNode.rotation = 0;
    [centerNode addChild:packetBatchNode z:kZParticles tag:kTagPacketBatchNode];
    [self addChild:centerNode z:kZParticles];
}

-(void)bgmManager {
    NSInteger intensity = [GameManager sharedGameManager].bgmIntensity;

    NSInteger count = particles.count;
    if (count > 26 || (mode == kGameSceneTimeAttack && timeRemaining < 16.0)) {
        intensity = intensity % 2 ? 8 : 7;
    } else if (count > 20) {
        intensity = intensity % 2 ? 6 : 5;
    } else if (count > 12) {
        intensity = intensity % 2 ? 4 : 3;
    } else {
        intensity = intensity % 2 ? 2 : 1;
    }
    [GameManager sharedGameManager].bgmIntensity = intensity;
}

#pragma mark -
#pragma mark CCTouchDelegateProtocol
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
        if (location.x > winSize.width * 0.9 
            && location.y > winSize.height * 0.9) {
            [self pause];
        } else if (location.x < winSize.width * 0.33) {
            // Touches on the left drop pieces on end.
            if (nil == launchTouch) {
                launchTouch = touch;
                fireButton.position = location;
                fireButton.opacity = 255;
            }
        } else if (nil == rotationTouch) {
            // Touches on the right are for rotation.  
            rotationTouch = touch;
            rotationTouchTime = touch.timestamp;
            
            // Save game angle from start of touches
            centerNodeAngleInit = centerNode.rotation;
            
            // Calculate initial vector from puzzle to touch.
            CGPoint ray = ccpSub(location, puzzleCenter);
            rotTouchPointInit = ray;
            rotTouchPointCur = ray;
            
            // Show thumb guide.
            thumbGuide.position = location;
            thumbGuide.rotation = CC_RADIANS_TO_DEGREES(atanf(ray.x / ray.y));
            thumbGuide.opacity = 255;
        }        
    }
}


- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];
        if (touch == launchTouch) {
            fireButton.position = location;
        }
        if (touch == rotationTouch) {
            CGPoint ray = ccpSub(location, puzzleCenter);
            rotTouchPointInit = rotTouchPointCur;
            rotTouchPointCur = ray;
            GLfloat change = CC_RADIANS_TO_DEGREES(ccpAngleSigned(rotTouchPointCur, rotTouchPointInit));
            GLfloat newRotation = centerNode.rotation + change;
            centerNode.rotation = fmodf(newRotation, 360);
            
            // Set angleV
            NSTimeInterval deltaTime = touch.timestamp - rotationTouchTime;
            rotationTouchTime = touch.timestamp;
            rotAngleV = fabs(change) > kRotationMinAngleV ? change / deltaTime : 0;
            
            // Move thumb guide.
            thumbGuide.position = location;
            thumbGuide.rotation = CC_RADIANS_TO_DEGREES(atanf(ray.x / ray.y));
        }
    }    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (touch == launchTouch) {
            [self launch];
            
            // Forget this touch.
            launchTouch = nil;
            fireButton.opacity = 0;
        }
        if (touch == rotationTouch) {
            if (touch.timestamp - rotationTouchTime > 0.05 
                || fabsf(rotAngleV) < kRotationMinAngleV) { 
                rotAngleV = 0.0;
            } else {
                rotAngleV = clampf(rotAngleV, -1 * kRotationMaxAngleV, kRotationMaxAngleV);
            }
            
            // Forget this touch.
            rotationTouch = nil;
            thumbGuide.opacity = 0;
        }
    }
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (touch == launchTouch) {
            // Forget this touch.
            launchTouch = nil;
            fireButton.opacity = 0;
        }
        if (touch == rotationTouch) {
            // Forget this touch.
            rotAngleV = 0.0;
            rotationTouch = nil;
            thumbGuide.opacity = 0;
        }
    }
    
}
#pragma mark -
#pragma mark CCNode

-(void)onEnter {
    [super onEnter];
    mode = [GameManager sharedGameManager].curLevel;
    [self initUI];
    
    // This will set up the initial particle system.
    [self resetGame];
    
    // Pause if we get backgrounded.
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(pause) 
     name:UIApplicationWillResignActiveNotification 
     object:nil];
}

-(void)onExit {
    [super onExit];
    // Remove notification observer.
    [[NSNotificationCenter defaultCenter] 
     removeObserver:self 
     name:UIApplicationWillResignActiveNotification
     object:nil];
}

-(void)draw {
    // Have to do this here to prevent tearing.
    for (Particle *particle in inFlightParticles) {
        [self alignParticleToCenter:particle];
    }

    [super draw];
    
    return;
#ifdef DEBUG
    
    // Debug draw for fail radius.
    ccDrawColor4B(0, 255, 0, 128);
    ccDrawCircle(puzzleCenter, kFailRadius * scaleFactor, 0, 30, NO);
    
    // Debug draw for rotation touch.
    CGPoint location;
    if (nil != rotationTouch) {
        ccDrawColor4B(0, 0, 255, 200);
        location = [rotationTouch locationInView:[rotationTouch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];
        ccDrawCircle(location, 50, 0, 30, NO);
        ccDrawLine(puzzleCenter, location);
    }
    
#endif
}

#pragma mark -
#pragma mark NSObject

- (id)init
{
    self = [super initWithColor:ccc4(0, 0, 0, 255)];
    if (self) {
        particles = [[[NSMutableSet alloc] initWithCapacity:100] retain];
        visitedParticles = [[[NSMutableSet alloc] initWithCapacity:100] retain];
        scoredParticles = [[[NSMutableArray alloc] initWithCapacity:20] retain];
        countedParticles = [[[NSMutableSet alloc] initWithCapacity:10] retain];
        inFlightParticles = [[[NSMutableArray alloc] initWithCapacity:5] retain];
        
        if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
            scaleFactor = kiPhoneScale;
            skewVector = kiPhoneSkew;
        } else {
            scaleFactor = kiPadScale;
            skewVector = kiPadSkew;
        }
    }
    return self;
}

- (void)dealloc
{
    // Clean up your mess.
    [particles release];
    [scoredParticles release];
    [visitedParticles release];
    [countedParticles release];
    [inFlightParticles release];
    [super dealloc];
}

@end
