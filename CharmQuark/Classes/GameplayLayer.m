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
#import "GCHelper.h"
#import "CQLabelBMFont.h"
#import "iRate.h"

static CGPoint nextParticlePos;
static CGPoint launchPoint;
static cpFloat launchV;
static CGFloat scaleFactor;
static CGPoint skewVector;

@interface GameplayLayer()

-(void) addBodyToSpace:(cpBody *)body;
-(void) addParticle:(Particle*)particle atPosition:(CGPoint)position;
-(void) alignParticleToCenter:(Particle *)particle;
-(Particle*) randomParticle;
-(Particle *) readyNextParticle;
-(void) resume;
-(BOOL) scoreParticles;
-(void) playRandomCollisionAtVolume:(ALfloat)volume;
-(void) playRandomExplosionAtVolume:(ALfloat)volume;

@end

static CGPoint worldToView(CGPoint point) {
    CGPoint newXY = cpvadd(cpvmult(point, scaleFactor), skewVector);
    return newXY;
}

#pragma mark -
#pragma mark Chipmunk Callbacks

void removeShapesFromBody(cpBody *body, cpShape *shape, GameplayLayer *self) {
    cpSpace *space = cpBodyGetSpace(body);
    cpSpaceRemoveShape(space, shape);
    cpShapeFree(shape);
}

void postStepRemoveBody(cpSpace *space, cpBody *body, GameplayLayer *self) {
    cpBodyEachShape(body, (cpBodyShapeIteratorFunc)removeShapesFromBody, self);
    cpSpaceRemoveBody(space, body);
    cpBodyFree(body);
}

void scheduleForRemoval(cpBody *body, GameplayLayer *self) {
    cpSpaceAddPostStepCallback(self.space, (cpPostStepFunc)postStepRemoveBody, body, self);
}

// This function synchronizes the body with the sprite.
void syncSpriteToBody(cpBody *body, GameplayLayer* self) {
	Particle *particle = body->data;
	if( particle ) {
		[particle setPosition: cpvmult(body->p, scaleFactor)];
	}
}

// This is what makes the particles cluster.  Tries to move towards the origin.
void gravityVelocityIntegrator(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
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

int collisionBegin(cpArbiter *arb, struct cpSpace *space, GameplayLayer *self)
{
    // Keep track of what particles this particle is touching.
    CP_ARBITER_GET_BODIES(arb, a, b);
    
    Particle *p1 = a->data;
    Particle *p2 = b->data;
    
    [p1 touchParticle:p2];
    [p2 touchParticle:p1];

    return TRUE;
}

int collisionPreSolve(cpArbiter *arb, cpSpace *space, GameplayLayer *self)
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

void collisionPostSolve(cpArbiter *arb, cpSpace *space, GameplayLayer *self)
{
    // Do nothing here.
    CP_ARBITER_GET_BODIES(arb, a, b);
    
    if (cpArbiterIsFirstContact(arb)) {
        cpFloat impulse = cpvlength(cpArbiterTotalImpulse(arb));
        
        if(impulse > kMinSoundImpulse){
            ALfloat volume 
            = fmax(fminf((impulse - kMinSoundImpulse)/(kMaxSoundImpulse - kMinSoundImpulse), 1.0f), 0.0f);
            //CCLOG(@"Impulse = %f. Volume = %f", impulse, volume);
            [self playRandomCollisionAtVolume:volume];
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

@implementation GameplayLayer

@synthesize space;
@synthesize score;

#pragma mark - Setup

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	GameplayLayer *layer = [self node];
	[scene addChild: layer];
	return scene;
}

-(void)initUI {
    self.isTouchEnabled = YES;
    self.isAccelerometerEnabled = NO;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // Static variables.
    puzzleCenter = worldToView(kPuzzleCenter);
    CGPoint scorePosition = ccp(5, winSize.height * 0.95f);
    
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
    pauseSprite.color = kColorUI;
    pauseSprite.anchorPoint = ccp(1.0, 0.5);
    [pauseSprite setPosition:ccp(winSize.width - 5, winSize.height * 0.95f)];
    //[uiBatchNode addChild:pauseSprite z:kZUIElements];
    
    // Add score label.
    scoreLabel = [CQLabelBMFont labelWithString:@"0" fntFile:@"score.fnt"];
    [scoreLabel setAnchorPoint:ccp(0.0f, 0.5f)];
    [scoreLabel setPosition:scorePosition];
    [scoreLabel setColor:kColorScore];
    [self addChild:scoreLabel z:kZUIElements];
    
    // Add Next
    CGPoint nextLabelPosition = ccp(scorePosition.x,
                                    scorePosition.y - scoreLabel.contentSize.height - 10 * scaleFactor);
    CQLabelBMFont *nextLabel = [CQLabelBMFont labelWithString:@"Next:" fntFile:@"score.fnt"];
    nextLabel.color = kColorUI;
    nextLabel.position = nextLabelPosition;
    [nextLabel setAnchorPoint:ccp(0.0, 0.5)];
    [self addChild:nextLabel z:kZUIElements];
    
    nextParticlePos = ccp(nextLabelPosition.x + nextLabel.contentSize.width + kParticleRadius * scaleFactor,
                          nextLabelPosition.y);
    
    // Add the map.
    map = [LHCMap node];
    map.color = kColorUI;
    map.anchorPoint = ccp(0, 0.5);
    map.position = ccp(-3, puzzleCenter.y);
    
    // Add the log viewer.
    logViewer = [LogViewer node];
    logViewer.position = puzzleCenter;
    [self addChild:logViewer z:kZLog];
    
    // Add the detector.
    detector = [Detector node];
    detector.position = puzzleCenter;
    
    // Render the background.
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:winSize.width
                                                           height:winSize.height];
    [rt begin];
    CCSprite *bg = [CCSprite spriteWithFile:@"background.png"
                                       rect:CGRectMake(0, 0, winSize.width, winSize.height)];
    ccTexParams params = {GL_LINEAR,GL_NEAREST,GL_REPEAT,GL_REPEAT};
    [bg.texture setTexParameters:&params];
    bg.position = ccp(winSize.width / 2, winSize.height / 2);
    bg.color = kColorBackground;
    [bg visit];
    [bg cleanup];
    
    CCSprite *gradient = [CCSprite spriteWithFile:@"bg-gradient.png"];
    gradient.scaleX = winSize.width / gradient.contentSize.width;
    gradient.scaleY = winSize.height / gradient.contentSize.height;
    gradient.position = ccp(winSize.width / 2, winSize.height / 2);
    [gradient visit];
    [gradient cleanup];
    
    [map visit];
    map.visible = NO;
    [uiBatchNode addChild:map z:kZMap];
    
    [detector visit];
    detector.visible = NO;
    [uiBatchNode addChild:detector z:kZDetector];

    [nextLabel visit];
    [nextLabel removeFromParentAndCleanup:YES];
    
    [pauseSprite visit];
    [pauseSprite cleanup];

    [rt end];
    rt.position = ccp(winSize.width / 2, winSize.height / 2);
    [self addChild:rt z:kZBackground];    

    // Add the thumb guides.
    thumbGuide = [CCSprite spriteWithSpriteFrameName:@"thumbguide.png"];
    thumbGuide.color = kColorThumbGuide;
    thumbGuide.opacity = kOpacityThumbGuide;
    thumbGuide.visible = NO;
    [uiBatchNode addChild:thumbGuide z:kZUIElements - 1];
    
    fireButton = [CCSprite spriteWithSpriteFrameName:@"firebutton.png"];
    fireButton.color = kColorThumbGuide;
    fireButton.opacity = kOpacityThumbGuide;
    fireButton.visible = NO;
    [uiBatchNode addChild:fireButton z:kZUIElements];
    
    // Configure the node which controls rotation.
    centerNode = [CCNode node];
    centerNode.position = puzzleCenter;
    centerNode.rotation = 0;
    [centerNode addChild:packetBatchNode z:kZParticles tag:kTagPacketBatchNode];
    [self addChild:centerNode z:kZParticles];
}

#pragma mark - Runloop

-(void) alignParticleToCenter:(Particle *)particle {
    // Rotate particle position and velocity the other way.
    cpBody *body = particle.body;
    cpVect rot = cpvforangle(CC_DEGREES_TO_RADIANS(centerNode.rotation));
    cpFloat distance = cpvlength(body->p);
    cpFloat speed = cpvlength(body->v);
    cpVect pos = cpvmult(rot, -1 * distance);
    cpVect vel = cpvmult(rot, speed);
    cpBodySetPos(body, pos);
    cpBodySetVel(body, vel);
    particle.position = cpvmult(pos, scaleFactor);

    // Adjust sprite position for puzzle offset.
    if (distance > kFailRadius) {
        cpVect skew = ccp(skewVector.x * (distance - kFailRadius) / (kLaunchPoint.x + kFailRadius), 0);
        skew = cpvrotate(skew, rot);
        particle.position = cpvadd(particle.position, skew);
    }
}

-(void) moveInFlightBodies {
    for (NSInteger i=0; i < inFlightParticles.count; i++) {
        Particle *particle = [inFlightParticles objectAtIndex:i];
        cpBody * body = particle.body;
        cpBodyUpdatePosition(body, kSimulationRate);
        //particle.position = cpvmult(body->p, scaleFactor);
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

-(void) gameStep {
    // Update clock.
    timeRemaining -= kSimulationRate;
    lastLaunch += kSimulationRate;
    [map setTime:(dropFrequency - timeRemaining) / dropFrequency];
    
    // Update touch inertia.
    if (nil == rotationTouch && fabs(rotAngleV) > 1) {
        centerNode.rotation = fmodf(centerNode.rotation + rotAngleV * kSimulationRate, 360.0);
        rotAngleV *= 1 - (kRotationFalloff * kSimulationRate);
    }
    
    // Update physics and move stuff.
    cpSpaceStep(space, kSimulationRate);
    cpSpaceEachBody(space, (cpSpaceBodyIteratorFunc)syncSpriteToBody, self);
    [self moveInFlightBodies];
}

-(void) step: (ccTime)dt {
    static ccTime remainder = 0;
    dt += remainder;
    int steps = dt / kSimulationRate;
    remainder = fmodf(dt, kSimulationRate);
    
    // Run steps
    for (int i = 0; i < steps; i++) {
        [self gameStep];
    }
}

#pragma mark - Game Control

-(void)forgetTouches {
    // Cancel touches.
    rotationTouch = nil;
    launchTouch = nil;
    thumbGuide.visible = NO;
    fireButton.visible = NO;
}

-(void)end:(Particle *)particle {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // Don't pause on top of game over.
    paused = YES;
    
    // Change volume.
    GameManager *gm = [GameManager sharedGameManager];
    [gm setMusicVolume:kVolumeMenu];

    [self forgetTouches];
    
    [self unscheduleAllSelectors];
    
    // Flash the detector.
    if (nil != particle) {
        // Calculate angle
        float angle = -1 * CC_RADIANS_TO_DEGREES(cpvtoangle(cpBodyGetPos(particle.body)));
        angle += centerNode.rotation;
        [detector gameOverAtAngle:angle];
        
        id fadeOut = [CCTintTo actionWithDuration:0.5
                                              red:particle.color.r / 2
                                            green:particle.color.g / 2 
                                             blue:particle.color.b / 2];
        id fadeIn = [CCTintTo actionWithDuration:0.5
                                             red:particle.color.r
                                        green:particle.color.g
                                         blue:particle.color.b];
        id seq = [CCSequence actions:fadeOut, fadeIn, nil];
        id loop = [CCRepeatForever actionWithAction:seq];

        [particle runAction:loop];
    }
    
    // Throw up modal layer.
    GameOverLayer *gameOverLayer = [GameOverLayer node];
    CGPoint oldPos = gameOverLayer.position;
    gameOverLayer.position = ccp(0, 2 * winSize.height);
    [gameOverLayer setScore:score];
    [self addChild:gameOverLayer z:kZPopups];
    id wait = [CCDelayTime actionWithDuration:1.0];
    id move = [CCMoveTo actionWithDuration:kPopupSpeed position:oldPos];
    id seq = [CCSequence actions:wait, move, nil];
    [gameOverLayer runAction:seq];
    
    // Count games played for iRate.
    [[iRate sharedInstance] logEvent:YES];
}

-(BOOL) launch {
    launchTouch = nil; // Prevent double launch on touch end.
    fireButton.visible = NO;

    // Make sure it's legal.
    if (lastLaunch < kLaunchCoolDown) {
        CCLOG(@"Ignored launch during cooldown.");
        return NO;
    }
    
    // Launch!
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
    
    return YES;
}

-(void) pause {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    if (!paused) {
        paused = YES;
        [self pauseSchedulerAndActions];

        PLAYSOUNDEFFECT(CLICK, 1.0);

        // Cancel touches.
        [self forgetTouches];
        
        // Change volume
        [[GameManager sharedGameManager] setMusicVolume:kVolumeMenu];
        
        // Throw up modal layer.
        PauseLayer *pauseLayer = [PauseLayer node];
        CGPoint oldPos = pauseLayer.position;
        pauseLayer.position = ccp(0, 2 * winSize.height);
        [self addChild:pauseLayer z:kZPopups];
        [pauseLayer runAction:[CCMoveTo actionWithDuration:kPopupSpeed
                                                  position:oldPos]];
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
    
    launchV = kLaunchV;
    colors = kColorsInit;
    
    // Clear the scoreboard
    [scoreLabel setString:@"0"];
    
    // Remove all objects from the space.
    cpSpaceEachBody(space, (cpSpaceBodyIteratorFunc)scheduleForRemoval, self);
    
    // Remove in-flight particles.
    for (Particle *particle in inFlightParticles) {
        cpSpaceAddBody(space, particle.body);
        scheduleForRemoval(particle.body, self);
        [particle removeFromParentAndCleanup:YES];
    }
    [inFlightParticles removeAllObjects];
    
    // Remove particles from parent.
    for (Particle *particle in particles) {
        [particle removeFromParentAndCleanup:YES];
    }
    [particles removeAllObjects];

    // Set up the next particle.
    if (nextParticle) {
        cpBodyFree(nextParticle.body);
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

-(void) resume {
    paused = NO;
    [self resumeSchedulerAndActions];
    
    // Change volume
    [[GameManager sharedGameManager] setMusicVolume:kVolumeGame];
}

#pragma mark - Sound

-(void)playRandomCollisionAtVolume:(ALfloat)volume {
    switch(rand() % 4) {
        case 0:
            PLAYSOUNDEFFECT(COLLIDE_1, volume);
            break;
        case 1:
            PLAYSOUNDEFFECT(COLLIDE_2, volume);
            break;
        case 2:
            PLAYSOUNDEFFECT(COLLIDE_3, volume);
            break;
        case 3:
            PLAYSOUNDEFFECT(COLLIDE_4, volume);
            break;
    }
}

-(void)playRandomExplosionAtVolume:(ALfloat)volume {
    switch(rand() % 3) {
        case 0:
            PLAYSOUNDEFFECT(EXPLODE_1, volume);
            break;
        case 1:
            PLAYSOUNDEFFECT(EXPLODE_2, volume);
            break;
        case 2:
            PLAYSOUNDEFFECT(EXPLODE_3, volume);
            break;
    }

}

#pragma mark - Particle Management

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
    [map setParticleColor:nextParticle.particleColor];
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



#pragma mark - Scoring

-(void) addPoints:(NSInteger)points {
    if (points > 0) {
        score += points;
        [scoreLabel setString:[[[NSString alloc] initWithFormat:@"%d", score] autorelease]];
    }
}

-(BOOL) updateLevel {
    // Update level
    if (matchesToNextLevel <= 0) {
        matchesToNextLevel += kMatchesPerLevel;
        return YES;
    }
    return NO;
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
                    GCHelper *gc = [GCHelper sharedInstance];
                    for (Particle *p in countedParticles) {
                        [scoredParticles addObject:p];
                    }
                    matchesToNextLevel--;
                    multiplier = countedParticles.count - kMinMatchSize + 1;
                    points = kPointsPerMatch * countedParticles.count;
                    
                    if (multiplier > 1) {
                        points *= multiplier;
                        // Play multiplier animation.
                        [logViewer addMessage:[NSString stringWithFormat:@"%dX Bonus!", multiplier]
                                        color:kColorBonus];
                        if (multiplier == 2) {
                            [gc reportAchievement:kAchievementBonus2X percentComplete:100.0];
                        }
                        if (multiplier == 3) {
                            [gc reportAchievement:kAchievementBonus3X percentComplete:100.0];
                        }
                        if (multiplier == 4) {
                            [gc reportAchievement:kAchievementBonus4X percentComplete:100.0];
                        }
                        if (multiplier == 5) {
                            [gc reportAchievement:kAchievementBonus5X percentComplete:100.0];
                        }
                    }
                    
                    if (comboLevel) {
                        points *= comboLevel + 1;
                        [logViewer addMessage:[NSString stringWithFormat:@"%dX Combo!", comboLevel + 1]
                                        color:kColorCombo];
                        if (comboLevel == 1) {
                            [gc reportAchievement:kAchievementCombo2X percentComplete:100.0];
                        }
                        if (comboLevel == 2) {
                            [gc reportAchievement:kAchievementCombo3X percentComplete:100.0];
                        }
                        if (comboLevel == 3) {
                            [gc reportAchievement:kAchievementCombo4X percentComplete:100.0];
                        }
                        if (comboLevel == 4) {
                            [gc reportAchievement:kAchievementCombo5X percentComplete:100.0];
                        }
                    }
                    
                    comboCount = 2 / kSweepRate;  // Two seconds.
                    comboLevel++;
                    
                    [self addPoints:points]; // Update score.
                    [logViewer addMessage:[NSString stringWithFormat:@"%d", points]
                                    color:kColorScore];
                    
                    // Send achievements
                    [gc reportAchievement:kAchievementFirstMatch 
                          percentComplete:100.0];
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
        [self playRandomExplosionAtVolume:1.0];
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
        [detector animateAtAngle:-1 * explosion.angle graphColor:ccGREEN];

        postStepRemoveBody(space, particle.body, self);  // Don't need to schedule, called from update.
    }
    
    // No Balls!
    if (particles.count == 0) {
        [[GCHelper sharedInstance] reportAchievement:kAchievementNoBalls
                                     percentComplete:100.0];
    }
    
    if (gameOver) {
        [self end:gameOverParticle];
    }
    
    if (points) {
        return YES;
    }
    return NO;
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
                fireButton.visible = YES;
            }
        } else if (location.x >= winSize.width * 0.33) {
            if (nil == rotationTouch) {
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
                thumbGuide.visible = YES;;
            }        
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
        if (touch == rotationTouch) {
            if (touch.timestamp - rotationTouchTime > 0.05 
                || fabsf(rotAngleV) < kRotationMinAngleV) { 
                rotAngleV = 0.0;
            } else {
                rotAngleV = clampf(rotAngleV, -1 * kRotationMaxAngleV, kRotationMaxAngleV);
            }
            
            // Forget this touch.
            rotationTouch = nil;
            thumbGuide.visible = NO;
        }
        if (touch == launchTouch) {
            [self launch];
            
            // Forget this touch.
            launchTouch = nil;
            fireButton.visible = NO;
        }
    }
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (touch == launchTouch) {
            // Forget this touch.
            launchTouch = nil;
            fireButton.visible = NO;
        }
        if (touch == rotationTouch) {
            // Forget this touch.
            rotAngleV = 0.0;
            rotationTouch = nil;
            thumbGuide.visible = NO;
        }
    }
    
}
#pragma mark -
#pragma mark CCNode

-(void)onEnter {
    [super onEnter];

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
}

-(void)cleanup {
    if (nil != nextParticle) {
        cpBodyFree(nextParticle.body);
    }
    [super cleanup];
}

#pragma mark -
#pragma mark NSObject

- (id)init
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    self = [super initWithColor:ccc4(0, 0, 0, 255)];
    if (self) {
        particles = [[NSMutableSet alloc] initWithCapacity:100];
        visitedParticles = [[NSMutableSet alloc] initWithCapacity:100];
        scoredParticles = [[NSMutableArray alloc] initWithCapacity:20];
        countedParticles = [[NSMutableSet alloc] initWithCapacity:10];
        inFlightParticles = [[NSMutableArray alloc] initWithCapacity:5];
        
        if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
            scaleFactor = kiPhoneScale;
            if (winSize.width == 568) {
                skewVector = kiPhone568Skew;
            } else {
                skewVector = kiPhoneSkew;
            }
        } else {
            scaleFactor = kiPadScale;
            skewVector = kiPadSkew;
        }
        
        [self initUI];
        
        // This will set up the initial particle system.
        [self resetGame];
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
