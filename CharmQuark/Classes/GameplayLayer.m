//
//  GameplayLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/19/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "GameplayLayer.h"
#import "Particle.h"
#import "Constants.h"
#import "PauseLayer.h"
#import "GameOverLayer.h"

static CGPoint puzzleCenter;
static CGPoint nextParticlePos;
static CGPoint scorePosition;
static CGPoint levelPosition;
static CGPoint launchPoint;
static cpFloat launchV;

@interface GameplayLayer()

-(void)resetGame;
-(Particle*)randomParticle;
-(void) step: (ccTime) dt;
-(void) addParticle:(Particle*)particle atPosition:(CGPoint)position;
-(void) scoreParticles;
-(void) pause;
-(void) resume;
-(void) end;

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
        [particle explode];
        [particle removeFromParentAndCleanup:YES];
    }
}

static void scheduleForRemoval(cpBody *body, GameplayLayer *self) {
    cpSpaceAddPostStepCallback(self.space, (cpPostStepFunc)postStepRemoveParticle, body, self);
}

// This function synchronizes the body with the sprite.
static void syncSpriteToBody(cpBody *body, GameplayLayer* self) {
	Particle *sprite = body->data;
	if( sprite ) {
		[sprite setPosition: body->p];
        
        if ([sprite isLive] && (cpvlength(cpBodyGetPos(body)) >= kFailRadius)) {
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
        g = cpvmult(cpvnormalize(p), -1 * launchV);
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
    
    return true;
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
    
    return true;
}

static void collisionPostSolve(cpArbiter *arb, cpSpace *space, GameplayLayer *self)
{
    // Play sound effects here?
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
    gameOver = NO;
    dropTime = kDropTimeInit;
    launchV = kLaunchV;
    colors = kColorsInit;
    level = 1;
    matchesToNextLevel = kMatchesPerLevel;
    
    // Clear the scoreboard
    [levelLabel setString:@"1"];
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
    nextParticle = [self randomParticle];
    nextParticle.position = nextParticlePos;
    [self addChild:nextParticle];
    
    // Reschedule droptimer.
    [self schedule: @selector(drop) interval:dropTime];
    
    // Schedule scoring timer.
    [self schedule:@selector(scoreParticles) interval:0.5];
    
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

-(void) launchParticle:(Particle*)particle {
//    cpVect launchVect = cpvmult(cpvnormalize(cpvsub(target, launchPoint)), launchV);
    
//    cpVect launchVect = cpvmult(cpv, <#const cpFloat s#>)
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
    CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [centerNode getChildByTag:kTagBatchNode];
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
    cpShape* shape = cpCircleShapeNew(body, 15.0f, CGPointZero);
    cpShapeSetFriction(shape, kParticleFriction);
    cpShapeSetElasticity(shape, kParticleElasticity);
    //cpShapeSetCollisionType(shape, kParticleCollisionType);
	cpSpaceAddShape(space, shape);
    
    // Create sensor shape to handle slow collisions.
    cpShape* sensor = cpCircleShapeNew(body, 15.5f, CGPointZero);
    cpShapeSetSensor(sensor, YES);
    cpShapeSetCollisionType(sensor, kParticleCollisionType);
	cpSpaceAddShape(space, sensor);
    
    // Add body to space.
    body->velocity_func = gravityVelocityIntegrator;
    cpBodySetVelLimit(body, kVelocityLimit);
    cpBodySetPos(body, position);
    cpSpaceAddBody(space, body);
    
    // Remove from in-flight list.
    [inFlightParticles removeObject:particle];
}

-(void) scoreParticles {
    NSInteger matches = 0;
    
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
            }
        }
    }
    
    
    // Update score
    matches = [scoredParticles count];
    //NSInteger multiplier = 1 + matches - kMinMatchSize ;
    NSInteger points = kPointsPerMatch * (matches - kMinMatchSize + 1);
    
    // Run some kind of animation here to display points.
    if (matches > 0) {
        score += points;
        [scoreLabel setString:[[[NSString alloc] initWithFormat:@"%d", score] autorelease]];
        id scaleUp = [CCScaleTo actionWithDuration:0.2f scaleX:1.5 scaleY:0.0];
        id scaleDown = [CCScaleTo actionWithDuration:0.2f scale:1.0];
        id seq = [CCSequence actions: scaleUp, scaleDown, nil];
        [scoreLabel runAction:seq];
    }
    
    // Update level
    if (matchesToNextLevel <= 0) {
        matchesToNextLevel = kMatchesPerLevel;
        level++;
        dropTime -= kDropTimeStep;
        if (dropTime <= kDropTimeMin) {
            dropTime = kDropTimeMin;
        }
        [levelLabel setString:[[[NSString alloc] initWithFormat:@"%d", level] autorelease]];
        [self unschedule:@selector(drop)];
        [self schedule:@selector(drop) interval:dropTime];
    }
    
    // Delete scored particles.  If this is done in the iterator, will throw exceptions.
    while (scoredParticles.count > 0) {
        Particle *particle = [scoredParticles objectAtIndex:0];
        [scoredParticles removeObject:particle];
        
        // TODO: Add a method which animates out the particle before removing the sprite.
        //[particle explode];
        postStepRemoveParticle(space, particle.body, self);  // Don't need to schedule, called from update.
    }
 }

-(void) moveInFlightBodies {
    for (NSInteger i=0; i < inFlightParticles.count; i++) {
        Particle *particle = [inFlightParticles objectAtIndex:i];
        cpBody * body = particle.body;
        cpBodyUpdatePosition(body, kSimulationRate);
        [particle setPosition: body->p];
        cpFloat d = cpvlength(cpvsub(puzzleCenter, body->p));
        if (d < kFailRadius + 30.0 || body->p.x > puzzleCenter.x) {
            [self addParticle:particle atPosition:body->p];
            i--;
        }
    }
}

-(void) step: (ccTime)dt {
    static ccTime remainder = 0;
    
    //dt *= timeScale;
    
    dt += remainder;
    int steps = dt / kSimulationRate;
    remainder = fmodf(dt, kSimulationRate);
    
    //[self scoreParticles];  // Doesn't need to run at simulation resolution.

    for (int i = 0; i < steps; i++) {
        cpSpaceStep(space, kSimulationRate);
        cpSpaceEachBody(space, (cpSpaceBodyIteratorFunc)syncSpriteToBody, self);
        [self moveInFlightBodies];
    }
}

-(void) drop {
    [self launchParticle:nextParticle];
    // Refactor these three lines
    nextParticle = [self randomParticle];
    nextParticle.position = nextParticlePos;
    [self addChild:nextParticle];
}

-(void) pause {
    [self pauseSchedulerAndActions];
    PauseLayer *pauseLayer = [[PauseLayer alloc] init];
    [self addChild:pauseLayer z:1000];
    GLubyte opacity = pauseLayer.opacity;
    pauseLayer.opacity = 0;
    [pauseLayer runAction:[CCFadeTo actionWithDuration:1.0f opacity:opacity]];
}

-(void) resume {
    [self resumeSchedulerAndActions];
}

-(void)end {
    gameOver = YES;
    [self unscheduleAllSelectors];
    GameOverLayer *gameOverLayer = [[GameOverLayer alloc] init];
    [self addChild:gameOverLayer z:1000];
    GLubyte opacity = gameOverLayer.opacity;
    gameOverLayer.opacity = 0;
    [gameOverLayer runAction:[CCFadeTo actionWithDuration:1.0f opacity:opacity]];
}

#pragma mark -
#pragma mark CCTouchDelegateProtocol
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView: [touch view]];
		// location = [[CCDirector sharedDirector] convertToGL: location];
        if (location.x < winSize.width * 0.5) {
            // Touches on the left drop pieces on end.
            if (nil == launchTouch) {
                launchTouch = touch;
                aimAngleInit = aimAngle;
                CGPoint ray = ccpSub(location, launchPoint);
                aimTouchAngleInit = CC_RADIANS_TO_DEGREES(ccpAngleSigned(kUnitVectorUp, ray));
            }
        } else if (nil == rotationTouch) {
            // Touches on the right are for rotation.  
            
            rotationTouch = touch;
            
            // Save game angle from start of touches
            centerNodeAngleInit = centerNode.rotation;
            
            CGPoint ray = ccpSub(location, puzzleCenter);
            rotTouchAngleInit = CC_RADIANS_TO_DEGREES(ccpAngleSigned(kUnitVectorUp, ray));
        }        
    }
}


- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView: [touch view]];
//        if (touch == launchTouch) {
//            // This is now an aim.
//            aimTouch = launchTouch;
//            launchTouch = nil;
//        }
        if (touch == aimTouch) {
            CGPoint ray = ccpSub(location, launchPoint);
            aimTouchAngleCur = CC_RADIANS_TO_DEGREES(ccpAngleSigned(kUnitVectorUp, ray));
            GLfloat newRotation = fmodf(aimAngleInit + (aimTouchAngleInit - aimTouchAngleCur) * kRotationRate, 360.0);
            aimAngle = cpfclamp(newRotation, -20.0f, 20.0f);
        }
        if (touch == rotationTouch) {
            CGPoint ray = ccpSub(location, puzzleCenter);
            rotTouchAngleCur = CC_RADIANS_TO_DEGREES(ccpAngleSigned(kUnitVectorUp, ray));
            GLfloat newRotation = fmodf(centerNodeAngleInit + (rotTouchAngleCur - rotTouchAngleInit) * kRotationRate, 360.0);
            
            centerNode.rotation = newRotation;
        }
    }    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (touch == aimTouch) {
            aimTouch = nil;
        }
        if (touch == launchTouch) {
            // Launch!
            [self unschedule:@selector(drop)];
            [self launchParticle:nextParticle];
            nextParticle = [self randomParticle];
            nextParticle.position = nextParticlePos;
            [self addChild:nextParticle];
            [self schedule:@selector(drop) interval:dropTime];
            
            // Forget this touch.
            launchTouch = nil;
        }
        if (touch == rotationTouch) {
            // Forget this touch.
            rotationTouch = nil;
        }
    }
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (touch == aimTouch) {
            aimTouch = nil;
        }
        if (touch == launchTouch) {
            // Forget this touch.
            launchTouch = nil;
        }
        if (touch == rotationTouch) {
            // Forget this touch.
            rotationTouch = nil;
        }
    }

}

#pragma mark -
#pragma mark CCNode

-(void)onEnter {
    [super onEnter];
    
    self.isTouchEnabled = YES;
    self.isAccelerometerEnabled = NO;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // Static variables.
    puzzleCenter = ccp(winSize.width - winSize.height * 0.4, winSize.height * 0.5f);
    scorePosition = ccp(winSize.width * 0.8f, winSize.height * 0.95f);
    levelPosition = ccp(winSize.width * 0.8f, winSize.height * 0.90f);
    launchPoint = ccp(0, winSize.height * 0.5f);
    //nextParticlePos = ccp(winSize.width * 0.6f, winSize.height * 0.95f);
    nextParticlePos = launchPoint;
    
    // Field initializations
    rotationTouch = nil;
    launchTouch = nil;
    rotTouchAngleInit = 0;
    rotTouchAngleCur = 0;
    centerNodeAngleInit = 0;
    nextParticle = nil;
    
    // Set up simulation.
    // Uncomment this when you need something to attach the sensor shapes to.
    // cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
    space = cpSpaceNew();
    cpSpaceSetGravity(space, ccp(0,0));
    cpSpaceSetDamping(space, kParticleDamping);
    cpSpaceAddCollisionHandler(space, 
                               kParticleCollisionType, kParticleCollisionType, 
                               (cpCollisionBeginFunc)collisionBegin, 
                               (cpCollisionPreSolveFunc)collisionPreSolve, 
                               (cpCollisionPostSolveFunc)collisionPostSolve, 
                               (cpCollisionSeparateFunc)collisionSeparate, 
                               self);
    
    // Load sprite sheet.
    sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"scene1Atlas.png" capacity:100];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"scene1Atlas.plist"];
    
    // Set up controls
//    CCSprite *resetSprite = [CCSprite spriteWithSpriteFrameName:@"ResetButton.png"];
//    CCSprite *resetSpriteSelected = [CCSprite spriteWithSpriteFrameName:@"ResetButtonSelected.png"];
//    resetButton = [CCMenuItemSprite itemWithNormalSprite:resetSprite 
//                                          selectedSprite:resetSpriteSelected
//                                                  target:self
//                                                selector:@selector(resetGame)];
//    CCMenu *menu = [CCMenu menuWithItems:resetButton, nil];
    
    CCSprite *pauseSprite = [CCSprite spriteWithSpriteFrameName:@"PauseButton.png"];
    CCSprite *pauseSpriteSelected = [CCSprite spriteWithSpriteFrameName:@"PauseButtonSelected.png"];
    CCMenuItemSprite *pauseButton = [CCMenuItemSprite itemWithNormalSprite:pauseSprite 
                                          selectedSprite:pauseSpriteSelected
                                                  target:self
                                                selector:@selector(pause)];
    CCMenu *menu = [CCMenu menuWithItems:pauseButton, nil];
    
    
    [menu setPosition:ccp(winSize.width * 0.5f, winSize.height * 0.95f)];
    [self addChild:menu z:100];
    
    // Add score label.  Replace this later with your own image file.
    CCTexture2DPixelFormat currentFormat = [CCTexture2D defaultAlphaPixelFormat];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
    scoreLabel = [[CCLabelAtlas alloc]  initWithString:@"0" charMapFile:@"fps_images.png" itemWidth:12 itemHeight:32 startCharMap:'.'];
    [CCTexture2D setDefaultAlphaPixelFormat:currentFormat];
    [scoreLabel setPosition:scorePosition];
    [self addChild:scoreLabel z:100];
    
    // Add level label.  Replace this later with your own image file.
    currentFormat = [CCTexture2D defaultAlphaPixelFormat];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
    levelLabel = [[CCLabelAtlas alloc]  initWithString:@"0" charMapFile:@"fps_images.png" itemWidth:12 itemHeight:32 startCharMap:'.'];
    [CCTexture2D setDefaultAlphaPixelFormat:currentFormat];
    [levelLabel setPosition:levelPosition];
    [self addChild:levelLabel z:100];
    
    // Configure the node which controls rotation.
    centerNode = [CCNode node];
    centerNode.position = puzzleCenter;
    centerNode.rotation = 0;
    [centerNode addChild:sceneSpriteBatchNode z:0 tag:kTagBatchNode];
    [self addChild:centerNode];
    
    // This will set up the initial particle system.
    [self resetGame];
}

-(void)draw {
    [super draw];
    //#ifdef DEBUG
    
    // Debug draw for fail radius.
    if (gameOver) {
        ccDrawColor4B(255, 0, 0, 128);
    } else {
        ccDrawColor4B(0, 255, 0, 128);
    }
    ccDrawCircle(puzzleCenter, kFailRadius + 15, 0, 30, NO);
    
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
    CGPoint start = {0, puzzleCenter.y};
    
    cpVect rot = cpvforangle(CC_DEGREES_TO_RADIANS(aimAngle));
    cpVect launchVel = cpvmult(rot, launchV);
    launchVel = cpvadd(launchVel, launchPoint);
    
    ccDrawLine(start, launchVel);
    
    //#endif
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
