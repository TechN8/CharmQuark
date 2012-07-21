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
//static CGSize fieldSize = {1024.0, 768.0};
static cpFloat launchV;
static CGFloat scaleFactor;


@interface GameplayLayer()

-(void)resetGame;
-(Particle*)randomParticle;
-(void) step: (ccTime) dt;
-(void) addParticle:(Particle*)particle atPosition:(CGPoint)position;
-(void) scoreParticles;
-(void) pause;
-(void) resume;
-(void) end;
-(void) launch;
-(Particle *) readyNextParticle;

@end

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
        [particle removeFromParentAndCleanup:YES];
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
        
        if ([particle isLive] && 
            (cpvlength(cpBodyGetPos(body)) >= kFailRadius - kParticleRadius)) {
            [self end];
        }
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
            PLAYSOUNDEFFECT(PARTICLE_COLLIDE, volume);
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

-(void)resetGame {
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
            [levelLabel setString:[NSString stringWithFormat:@"%d:%f.2", timeRemaining / 60, fmodf(timeRemaining, 60)]];
            break;
        case kGameSceneSurvival:
        default:
            dropFrequency = kDropTimeInit;
            timeRemaining = dropFrequency;
            [levelLabel setString:@"Level: 1"];
            break;
    }

    launchV = kLaunchV;
    colors = kColorsInit;
    
    // Clear the scoreboard
    [scoreLabel setString:@"0"];
    
    // Reset aim.
    //targetPoint = puzzleCenter;
    aimAngle = 0;
    
    // Remove all objects from the space.
    cpSpaceEachBody(space, (cpSpaceBodyIteratorFunc)scheduleForRemoval, self);
    [particles removeAllObjects];
    
    // Remove in-flight perticles too.
    for (Particle *particle in inFlightParticles) {
        cpBodyFree(particle.body);
        [particle removeFromParentAndCleanup:YES];
    }
    [inFlightParticles removeAllObjects];
    
    // Add the initial set of particles.
    for (NSInteger i = 0; i < 7; i++) {
        Particle *particle = [self randomParticle];
        [self addParticle:particle atPosition:ccp(puzzleCenter.x+(rand()%32), puzzleCenter.y+(rand()%32))];
    }
    
    // Fast forward the space
    for (int i = 0; i < 340; i++) {
        cpSpaceStep(space, kSimulationRate);
        cpSpaceEachBody(space, (cpSpaceBodyIteratorFunc)syncSpriteToBody, self);
    }
    
    // Set up the next particle.
    if (nextParticle) {
        [nextParticle removeFromParentAndCleanup:YES];
    }
    [self readyNextParticle];
    
    // Schedule scoring timer.
    [self schedule:@selector(scoreParticles) interval:kSweepRate];
    
    // Start animation / simulation timer.
    [self schedule: @selector(step:)];
}

-(Particle*)randomParticle {
    Particle *particle = nil;
    ParticleColors color = rand() % colors; //9;
    particle = [Particle particleWithColor:color]; 
    //particle = [Particle particleWithColor:kParticleGreen]; 
    
    // May want to add the below to the Particle class.
	// Create physics body.
    cpBody *body = cpBodyNew(kParticleMass, cpMomentForCircle(1.0f, 0, 15.0f, CGPointZero));

    body->data = particle;
    particle.body = body;
    
    return particle;
}

-(Particle *)readyNextParticle {
    Particle *particle = nextParticle;
    // Set up next particle
    nextParticle = [self randomParticle];
    nextParticle.position = nextParticlePos;
    [map setColor:nextParticle.particleColor];
    [[self getChildByTag:kTagUIBatchNode] addChild:nextParticle];
    return particle;
}

-(void) launch {
    Particle *particle = [self readyNextParticle];
    
    PLAYSOUNDEFFECT(PARTICLE_LAUNCH, 1.0);
    
//    cpVect launchVect = cpvmult(cpvnormalize(cpvsub(target, launchPoint)), launchV);
    cpVect rot = cpvforangle(CC_DEGREES_TO_RADIANS(aimAngle));
    cpVect launchVect = cpvmult(rot, launchV);
    
    cpBody *body = particle.body;
    cpBodySetPos(body, launchPoint);
    cpBodySetVel(body, launchVect);
    
    // Now what?
    [inFlightParticles addObject:particle];
    
    particle.position = launchPoint;
}

-(void) addParticle:(Particle*)particle atPosition:(CGPoint)position
{
    // Add to list for scoring.
    [particles addObject:particle];
    
    // Convert position from world to viewLayer coordinates.
    position = [centerNode convertToNodeSpace:position];
	particle.position = position;
    
    // Remove from layer and add to batch node.
    //[particle retain];
    [particle removeFromParentAndCleanup:NO];
    CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [centerNode getChildByTag:kTagPacketBatchNode];
    [batch addChild: particle];
    //[particle release];
    
    cpBody *body = particle.body;
    
    // Rotate body to match centerNode.
    cpFloat v = cpvlength(body->v);
    if (v > 0.0f) {
        cpVect rot = cpvforangle(CC_DEGREES_TO_RADIANS(centerNode.rotation));
        cpVect a = cpvrotate(cpvnormalize(body->v), rot);
        cpBodySetVel(body, cpvmult(a, v));
    }
    
    // Create physics shape.
    cpShape* shape = cpCircleShapeNew(body, kParticleRadius, CGPointZero);
    cpShapeSetFriction(shape, kParticleFriction);
    cpShapeSetElasticity(shape, kParticleElasticity);
    cpShapeSetCollisionType(shape, kShapeCollisionType);
	cpSpaceAddShape(space, shape);
    
    // Create sensor shape to handle slow collisions.
    cpShape* sensor = cpCircleShapeNew(body, kParticleRadius + 0.5, CGPointZero);
    cpShapeSetSensor(sensor, YES);
    cpShapeSetCollisionType(sensor, kSensorCollisionType);
	cpSpaceAddShape(space, sensor);
    
    // Add body to space.
    body->velocity_func = gravityVelocityIntegrator;
    cpBodySetVelLimit(body, kVelocityLimit);
    //cpBodySetPos(body, position);
    cpBodySetPos(body, cpvmult(position, 1.0/scaleFactor));
    cpSpaceAddBody(space, body);
    
    // Remove from in-flight list.
    [inFlightParticles removeObject:particle];
}

-(void) addPoints:(NSInteger)points {
    if (points > 0) {
        score += points;
        [scoreLabel setString:[[[NSString alloc] initWithFormat:@"%d", score] autorelease]];
        id scaleUp = [CCScaleTo actionWithDuration:0.2f scaleX:1.2 scaleY:1.0];
        id scaleDown = [CCScaleTo actionWithDuration:0.2f scale:1.0];
        id seq = [CCSequence actions: scaleUp, scaleDown, nil];
        [scoreLabel runAction:seq];
    }
}

-(void) updateLevel {
    // Update level
    if (matchesToNextLevel <= 0) {
        matchesToNextLevel += kMatchesPerLevel;
        switch (mode) {
            case kGameSceneTimeAttack:
                timeRemaining += 30; // Add 30 seconds
                [self animateText:[NSString stringWithFormat:@"+30 Seconds!", level] 
                       atPosition:[centerNode position]];
                break;
            case kGameSceneSurvival:
            default:
                level++;
                dropFrequency -= kDropTimeStep;
                if (dropFrequency <= kDropTimeMin) {
                    dropFrequency = kDropTimeMin;
                }
                [levelLabel setString:[NSString stringWithFormat:@"Level %d", level]];
//                [levelLabel setString:[NSString stringWithFormat:@"Level %d (%.1f)", level, dropFrequency]];
                id scaleUp = [CCScaleTo actionWithDuration:0.2f scaleX:1.2 scaleY:1.0];
                id scaleDown = [CCScaleTo actionWithDuration:0.2f scale:1.0];
                id seq = [CCSequence actions: scaleUp, scaleDown, nil];
                [levelLabel runAction:seq];
                
                [self animateText:[NSString stringWithFormat:@"Level %d!", level] 
                       atPosition:[centerNode position]];
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

-(void) scoreParticles {
    NSInteger multiplier = 0;
    NSInteger points = 0;
    
    // Reset
    [visitedParticles removeAllObjects];
    
    // Iterate on collidedParticles
    for (Particle *particle in particles) {
        // Don't double count.
        if ([particle isLive] && ![visitedParticles containsObject:particle]) {
            
            // Add self and all matching to scoredParticles && visitedParticles.
            [countedParticles removeAllObjects];
            [particle addMatchingParticlesToSet:countedParticles minMatch:kMinMatchSize];
            [visitedParticles unionSet:countedParticles];
            
            // If scoredParticles > kMinMatchSize then move them to final array?
            if (countedParticles.count >= kMinMatchSize) {
                for (Particle *p in countedParticles) {
                    [scoredParticles addObject:p];
                }
                matchesToNextLevel--;
                multiplier = countedParticles.count - kMinMatchSize + 1;
                points = kPointsPerMatch;
                
                NSString *bonusText = nil;
                if (multiplier > 1) {
                    points *= multiplier;
                    // Play multiplier animation.
                    bonusText = [NSString stringWithFormat:@"%dX Bonus!", multiplier];
                }
                
                if (comboLevel) {
                    points *= comboLevel + 1;
                    if (bonusText) {
                        bonusText = [NSString stringWithFormat:@"%@\n%dX Combo!", bonusText, comboLevel + 1];
                    } else {
                        bonusText = [NSString stringWithFormat:@"%dX Combo!", comboLevel + 1];
                    }
                }
                
                if (bonusText) {
                    [self animateText:bonusText
                           atPosition:[centerNode position]];
                }
                
                comboCount = 1 / kSweepRate;
                comboLevel++;

                [self addPoints:points]; // Update score.
                [self animateText:[NSString stringWithFormat:@"%d", points]
                       atPosition:[centerNode convertToWorldSpace:
                                   [(CCNode *)[countedParticles anyObject] position]]];
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
    
    // Delete scored particles.  If this is done in the iterator, will throw exceptions.
    while (scoredParticles.count > 0) {
        Particle *particle = [scoredParticles objectAtIndex:0];
        [scoredParticles removeObject:particle];
        
        CCParticleSystemQuad *explosion = [particle explode];  // Play the explosion animation.
        [detector blinkAtAngle:explosion.rotation];
        explosion.position = [centerNode convertToWorldSpace:particle.position];
        [self addChild:explosion];
        
        postStepRemoveParticle(space, particle.body, self);  // Don't need to schedule, called from update.
    }
 }

-(void) moveInFlightBodies {
    for (NSInteger i=0; i < inFlightParticles.count; i++) {
        Particle *particle = [inFlightParticles objectAtIndex:i];
        cpBody * body = particle.body;
        cpBodyUpdatePosition(body, kSimulationRate);
        [particle setPosition: ccp(body->p.x * scaleFactor, body->p.y)];
        cpFloat d = cpvlength(cpvsub(puzzleCenter, particle.position));
        if (d < (kFailRadius + kParticleRadius) * scaleFactor) {
            [self addParticle:particle atPosition:particle.position];
            i--;
        }
    }
}

-(void) step: (ccTime)dt {
    static ccTime remainder = 0;
    dt += remainder;
    int steps = dt / kSimulationRate;
    remainder = fmodf(dt, kSimulationRate);

    // Update clock.
    timeRemaining -= dt;
    [map setTime:(dropFrequency - timeRemaining) / dropFrequency];

    if (mode == kGameSceneTimeAttack) {
        int minutes = (int)timeRemaining / 60;
        float seconds = timeRemaining > 0 ? fmodf(timeRemaining, 60.0) : 0.0;
        [levelLabel setString:[NSString stringWithFormat:@"%1d:%2.2f", minutes, seconds]];
    }
    
    // Check for gameover or drop conditions.
    if (timeRemaining <= 0) {
        switch (mode) {
            case kGameSceneTimeAttack:
                [self end]; // Game over.
                break;
            case kGameSceneSurvival:
            default:
                [self drop];
            case kGameSceneMomMode:
                timeRemaining = dropFrequency;
                break;
        }
    }
    
    // Update touch inertia.
    if (nil == rotationTouch && fabs(rotAngleV) > 1) {
        centerNode.rotation = fmodf(centerNode.rotation + rotAngleV * dt, 360.0);
        rotAngleV *= 1 - (kRotationFalloff * dt);
//        rotAngleV = 10; // DEBUG
    }
    
    // Update physics and move stuff.
    for (int i = 0; i < steps; i++) {
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

    [self pauseSchedulerAndActions];

//    // Grab screen shot
//    CCRenderTexture *tf = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];
//    tf.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
//    [tf begin];
//    [self visit];
//    // TODO: Throw a GL_BLEND fade texture on top of the screen shot.
//    [tf end];
   
    // Throw up modal layer.
    PauseLayer *pauseLayer = [[PauseLayer alloc] initWithColor:ccc4(0,0,0,0)];
    CGPoint oldPos = pauseLayer.position;
    pauseLayer.position = ccp(0, -1 * winSize.height);
    //[pauseLayer setBackgroundNode:tf];
    [self addChild:pauseLayer z:kZPopups];
    //[pauseLayer runAction:[CCFadeIn actionWithDuration:1.0f]];
    [pauseLayer runAction:[CCMoveTo actionWithDuration:0.5f position:oldPos]];
}

-(void) resume {
    [self resumeSchedulerAndActions];
}

-(void)end {
    CGSize winSize = [[CCDirector sharedDirector] winSize];

    PLAYSOUNDEFFECT(GAME_OVER, 1.0);
    
    [self unscheduleAllSelectors];

//    // Grab screen shot
//    CCRenderTexture *tf = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];
//    tf.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
//
//    [tf begin];
//    [self visit];
//    // TODO: Throw a GL_BLEND fade texture on top of the screen shot.
//    [tf end];
    
    // Throw up modal layer.
    GameOverLayer *gameOverLayer = [[GameOverLayer alloc] initWithColor:ccc4(0,0,0,0)];
    CGPoint oldPos = gameOverLayer.position;
    gameOverLayer.position = ccp(0, -1 * winSize.height);
    [gameOverLayer setScore:score];
//    [gameOverLayer setBackgroundNode:tf];
    [self addChild:gameOverLayer z:kZPopups];
    [gameOverLayer runAction:[CCMoveTo actionWithDuration:0.5f position:oldPos]];
}


-(void)initUI {
    self.isTouchEnabled = YES;
    self.isAccelerometerEnabled = NO;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // Static variables.
    puzzleCenter = ccp(winSize.width - winSize.height * 0.45, winSize.height * 0.45f);
    CGPoint scorePosition = ccp(winSize.width * 0.05f, winSize.height * 0.95f);
    CGPoint levelPosition = ccp(winSize.width * 0.5f, winSize.height * 0.95f);
    CGPoint nextLabelPosition = ccp(winSize.width * 0.80f, winSize.height * 0.95f);
    nextParticlePos = ccp(winSize.width * 0.85f, winSize.height * 0.95f);

    launchPoint = ccp(0, winSize.height * 0.45f);
    
    // Field initializations
    rotationTouch = nil;
    launchTouch = nil;
    //rotTouchAngleInit = 0;
    //rotTouchAngleCur = 0;
    centerNodeAngleInit = 0;
    nextParticle = nil;
    
    // Set up simulation.
    // Uncomment this when you need something to attach the sensor shapes to.
    // cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
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
    CCSpriteBatchNode *packetBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"scene1Atlas.png" capacity:100];
    CCSpriteBatchNode *uiBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"scene1Atlas.png" capacity:100];
    [self addChild:uiBatchNode z:kZBackground tag:kTagUIBatchNode];

    // Pause Button
    CCSprite *pauseSprite = [CCSprite spriteWithSpriteFrameName:@"pause.png"];
//    CCSprite *pauseSpriteSelected = [CCSprite spriteWithSpriteFrameName:@"pause.png"];
//    CCMenuItemSprite *pauseButton = [CCMenuItemSprite itemWithNormalSprite:pauseSprite 
//                                                            selectedSprite:pauseSpriteSelected
//                                                                    target:self
//                                                                  selector:@selector(pause)];
//    CCMenu *menu = [CCMenu menuWithItems:pauseButton, nil];
//    [menu setPosition:ccp(winSize.width * 0.95f, winSize.height * 0.95f)];
//    [self addChild:menu z:kZUIElements];

    [pauseSprite setPosition:ccp(winSize.width * 0.95f, winSize.height * 0.95f)];
    [uiBatchNode addChild:pauseSprite z:kZUIElements];
    
    // Add score label.
    scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"score.fnt"];
    [scoreLabel setAnchorPoint:ccp(0.0f, 0.5f)];
    [scoreLabel setPosition:scorePosition];
    [self addChild:scoreLabel z:kZUIElements];
    
    // Add level label / clock
    switch (mode) {
        case kGameSceneTimeAttack:
            levelLabel= [CCLabelBMFont labelWithString:@"2:00.00" fntFile:@"score.fnt"];
            break;
        case kGameSceneSurvival:
        default:
            levelLabel = [CCLabelBMFont labelWithString:@"Level: 1" fntFile:@"score.fnt"];
            break;
    }
    [levelLabel setPosition:levelPosition];
    [self addChild:levelLabel z:kZUIElements];
    
    // Add Next:
    CCLabelBMFont *nextLabel = [CCLabelBMFont labelWithString:@"Next:" fntFile:@"score.fnt"];
    nextLabel.position = nextLabelPosition;
    [nextLabel setAnchorPoint:ccp(1.0, 0.5)];
    [self addChild:nextLabel z:kZUIElements];
    
    // Add the map.
    map = [LHCMap node];
    map.position = ccp(winSize.width * 0.19, winSize.height * 0.62);
    //clock.scale = 0.75f;
    [uiBatchNode addChild:map z:kZBackground];
    
    // Add the detector.
    detector = [Detector node];
    detector.position = puzzleCenter;
    [uiBatchNode addChild:detector z:kZBackground];
    
    // Add the thumb guides.
    thumbGuide = [CCSprite spriteWithSpriteFrameName:@"thumbguide.png"];
    thumbGuide.opacity = 0;
    [uiBatchNode addChild:thumbGuide z:kZUIElements];
    
    fireButton = [CCSprite spriteWithSpriteFrameName:@"firebutton.png"];
    fireButton.opacity = 0;
    [uiBatchNode addChild:fireButton z:kZUIElements];
    
    // Configure the node which controls rotation.
    centerNode = [CCNode node];
    centerNode.position = puzzleCenter;
    centerNode.rotation = 0;
    [centerNode addChild:packetBatchNode z:kZBackground tag:kTagPacketBatchNode];
    [self addChild:centerNode];
    
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
            
            // Set angleV
            NSTimeInterval deltaTime = touch.timestamp - rotationTouchTime;
            rotationTouchTime = touch.timestamp;
            rotAngleV = fabs(change) > kRotationMinAngleV ? change / deltaTime : 0;

            // Move thumb guide.
            centerNode.rotation = fmodf(newRotation, 360);
            thumbGuide.position = location;
            thumbGuide.rotation = CC_RADIANS_TO_DEGREES(atanf(ray.x / ray.y));
        }
    }    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (touch == launchTouch) {
            // Launch!
            if (mode == kGameSceneSurvival) {
                timeRemaining = dropFrequency;   
            }
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
}

-(void)draw {
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
    
    // Debug draw for launch.
    ccDrawColor4B(0, 0, 255, 200);
    CGPoint start = launchPoint;
    
    cpVect rot = cpvforangle(CC_DEGREES_TO_RADIANS(aimAngle));
    cpVect launchVel = cpvmult(rot, launchV * scaleFactor);
    launchVel = cpvadd(launchVel, launchPoint);
    
    ccDrawLine(start, launchVel);
    
#endif
}

#pragma mark -
#pragma mark NSObject

- (id)init
{
    self = [super initWithColor:ccc4(20, 20, 20, 255)];
    if (self) {
        particles = [[[NSMutableSet alloc] initWithCapacity:100] retain];
        visitedParticles = [[[NSMutableSet alloc] initWithCapacity:100] retain];
        scoredParticles = [[[NSMutableArray alloc] initWithCapacity:20] retain];
        countedParticles = [[[NSMutableSet alloc] initWithCapacity:10] retain];
        inFlightParticles = [[[NSMutableArray alloc] initWithCapacity:5] retain];
        
        if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
            scaleFactor = kiPhoneScaleFactor;
        } else {
            scaleFactor = kiPadScaleFactor;
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
