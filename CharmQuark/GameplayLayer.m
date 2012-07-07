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

//static CGFloat kSimulationRate = 1 / 60.0;

static CGPoint screenCenter;
static CGPoint nextParticlePos;
static CGPoint scorePosition;
static ccTime deltaTime;

@interface GameplayLayer()

-(void)resetViewportAndParticles;
-(Particle*)randomParticle;
-(void) step: (ccTime) dt;
-(void) addParticle:(Particle*)particle atPosition:(CGPoint)position;
-(void) scoreParticles:(ccTime)dt;

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
        // Free particle last or you will get EXECBADACCESS!
        //[sprite.streak reset];
        //[self.particleSets removeObject:particle.matchingParticles];  // HACK!
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
        //[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
        //[sprite.streak setPosition:body->p];
		
        
        
        if ([sprite isLive] && (cpvlength(cpBodyGetPos(body)) >= kFailRadius)) {
            // Game over.
            self.gameOver = YES;
        }
	}
}

// This is what makes the particles cluster.  Tries to move towards the origin.
static void gameVelocityFunc(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	cpVect p = cpBodyGetPos(body);
    //cpVect g = cpvmult(p, -200 * cpvlength(p) / (1.5f * screenCenter.y));
    // TODO This can crash of the body is at (0,0)?
    cpVect g = cpvmult(cpvnormalize(p), -1500);
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
    
//    // Check for and link matching particles.
//    if (p1.particleColor == p2.particleColor) {
//        [p1 touchParticle:p2];
//        
//        [self.collidedParticles addObject:p1];
//        [self.collidedParticles addObject:p2];
//    }
    return true;
}

static int collisionPreSolve(cpArbiter *arb, cpSpace *space, GameplayLayer *self)
{
    // Do nothing here.
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
    
//    if (p1.particleColor == p2.particleColor) {
//        // Unlink particle objects.
//        [p1 separateFromParticle:p2];
//
//        if (p1.matchingParticles.count == 0) {
//            [self.collidedParticles removeObject:p1];
//        }
//        
//        if (p2.matchingParticles.count == 0) {
//            [self.collidedParticles removeObject:p2];
//        }
//
//        // We're done.
//    }
}

#pragma mark -

@implementation GameplayLayer

@synthesize space;
@synthesize particles;
@synthesize score;
@synthesize scoreLabel;
@synthesize scoring;
@synthesize visitedParticles;
@synthesize scoredParticles;
@synthesize countedParticles;
@synthesize gameOver;

-(void)resetViewportAndParticles {
    // Reset angle
    centerNode.rotation = 0;
    
    // Remove all objects from the space.
    cpSpaceEachBody(space, (cpSpaceBodyIteratorFunc)scheduleForRemoval, self);
    
    // Add the initial set of particles.
    for (NSInteger i = 0; i < 7; i++) {
        Particle *particle = [self randomParticle];
        [self addParticle:particle atPosition:ccp(screenCenter.x+(rand()%32), screenCenter.y+(rand()%32))];
    }
   
    // Clear the scoreboard
    [particles removeAllObjects];
    score = 0;
    [scoreLabel setString:@"0"];
    gameOver = NO;
}

-(Particle*)randomParticle {
    Particle *particle = nil;
    ParticleColors color = rand() % 9;
    particle = [Particle particleWithColor:color]; 
    //particle = [Particle particleWithColor:kParticleGreen]; 
    return particle;
}

-(void) addParticle:(Particle*)particle atPosition:(CGPoint)position
{
    // Add to list for scoring.
    [particles addObject:particle];
    
    // Convert position from world to viewLayer coordinates.
    position = [centerNode convertToNodeSpace:position];

    // Set position and add to batch node.
	particle.position = position;
    CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [centerNode getChildByTag:kTagBatchNode];
    [batch addChild: particle];

	// Create physics body.
    cpBody *body = cpBodyNew(kParticleMass, cpMomentForCircle(1.0f, 0, 15.0f, CGPointZero));
    cpBodySetPos(body, position);
    body->velocity_func = gameVelocityFunc;
    cpBodySetVelLimit(body, kVelocityLimit);
    body->data = particle;
    particle.body = body;

    // Create physics shape.
//    cpShape* sensor = cpCircleShapeNew(body, 15.0f, CGPointZero);
//    cpShapeSetSensor(sensor, YES);
//    cpShapeSetCollisionType(sensor, kParticleCollisionType); // Is this really the best way to do this?

    cpShape* shape = cpCircleShapeNew(body, 15.0f, CGPointZero);
    cpShapeSetCollisionType(shape, kParticleCollisionType);
    cpShapeSetFriction(shape, kParticleFriction);
    cpShapeSetElasticity(shape, kParticleElasticity);

    cpSpaceAddBody(space, body);
	cpSpaceAddShape(space, shape);
	//cpSpaceAddShape(space, sensor);
}

-(void) scoreParticles:(ccTime)dt {
    scoring = YES;
    NSInteger matches = 0;
    
    // Reset
    [visitedParticles removeAllObjects];
    
    // Iterate on collidedParticles
    for (Particle *particle in particles) {
        // Don't double count.
        if ([particle isLive] && ![visitedParticles containsObject:particle]) {
            
            // Add self and all matching to scoredParticles && visitedParticles.
            [countedParticles removeAllObjects];
            [particle addMatchingParticlesToSet:countedParticles addTime:dt];
            [visitedParticles unionSet:countedParticles];
            
            // If scoredParticles > kMinMatchSize then move them to final array?
            if (countedParticles.count >= kMinMatchSize) {
                for (Particle *p in countedParticles) {
                    [scoredParticles addObject:p];
                }
            }
        }
    }
    
    
    // Update score
    matches = [scoredParticles count];
    NSInteger multiplier = 1 + matches - kMinMatchSize ;
    // TODO: Run some kind of animation here.
    score += matches * kPointsPerMatch * multiplier;
    [scoreLabel setString:[[[NSString alloc] initWithFormat:@"%d", score] autorelease]];
    
    // Delete scored particles.  Have to do this here to not break mutablesets and such.
    while (scoredParticles.count > 0) {
        Particle *particle = [scoredParticles objectAtIndex:0];
        [scoredParticles removeObject:particle];
        postStepRemoveParticle(space, particle.body, self);  // Don't need to schedule, called from update.
    }

    scoring = NO;
 }

-(void) step: (ccTime)dt {
    deltaTime = dt;
    static ccTime remainder = 0;
    dt += remainder;
    int steps = dt / kSimulationRate;
    remainder = fmodf(dt, kSimulationRate);
    
    [self scoreParticles:dt];  // Doesn't need to run at simulation resolution.

    for (int i = 0; i < steps; i++) {
        cpSpaceStep(space, kSimulationRate);
        cpSpaceEachBody(space, (cpSpaceBodyIteratorFunc)syncSpriteToBody, self);
    }
}

#pragma mark -
#pragma mark CCNode

-(void)draw {
    [super draw];
//#ifdef DEBUG
    
    // Debug draw for fail radius.
    if (gameOver) {
        ccDrawColor4B(255, 0, 0, 128);
    } else {
        ccDrawColor4B(0, 255, 0, 128);
    }
    ccDrawCircle(screenCenter, kFailRadius, 0, 30, NO);
    
    // Debug draw for rotation touch.
    CGPoint location;
    if (nil != rotationTouch) {
        ccDrawColor4B(0, 0, 255, 200);
        location = [rotationTouch locationInView:[rotationTouch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];
        ccDrawCircle(location, 50, 0, 30, NO);
        ccDrawLine(screenCenter, location);
    }
    
    // Debug draw for launch.
    if (nil != launchTouch) {
        ccDrawColor4B(0, 0, 255, 200);
        location = [launchTouch locationInView:[launchTouch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];
        ccDrawCircle(location, 50, 0, 30, NO);
        location.x = 0;
        ccDrawLine(screenCenter, location);
    }
    
//#endif
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
            }
        } else if (nil == rotationTouch) {
            // Touches on the right are for rotation.  
            
            rotationTouch = touch;
            
            // Save game angle from start of touches
            initialRotation = centerNode.rotation;
            
            CGPoint ray = ccpSub(location, screenCenter);
            initialTouchAngle = CC_RADIANS_TO_DEGREES(ccpAngleSigned(kUnitVectorUp, ray));
        }        
    }
}


- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (touch == launchTouch) {
            // Do nothing, animate crosshair later.
        }
        if (touch == rotationTouch) {
            CGPoint location = [touch locationInView: [touch view]];
            //location = [[CCDirector sharedDirector] convertToGL: location];
            CGPoint ray = ccpSub(location, screenCenter);
            currentTouchAngle = CC_RADIANS_TO_DEGREES(ccpAngleSigned(kUnitVectorUp, ray));
            
            GLfloat newRotation = fmodf(initialRotation + (currentTouchAngle - initialTouchAngle) * kRotationRate, 360.0);
            
            centerNode.rotation = newRotation;
        }
    }    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (touch == launchTouch) {
            // Drop a new piece.
            CGPoint location = [touch locationInView: [touch view]];
            location = [[CCDirector sharedDirector] convertToGL: location];
            location.x = 0;
            
            Particle *particle = [Particle particleWithColor:nextParticle.particleColor];
            [self removeChild:nextParticle cleanup:NO];
            nextParticle = [self randomParticle];
            nextParticle.position = nextParticlePos;
            [self addChild:nextParticle];
            
            [self addParticle:particle atPosition:location];
            
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
#pragma mark NSObject

- (id)init
{
    self = [super initWithColor:ccc4(0, 0, 0, 255)];
    if (self) {
        self.isTouchEnabled = YES;
        self.isAccelerometerEnabled = NO;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        screenCenter = ccp(winSize.width - winSize.height * 0.5, winSize.height * 0.5f);
        nextParticlePos = ccp(winSize.width * 0.6f, winSize.height * 0.95f);
        scorePosition = ccp(winSize.width * 0.8f, winSize.height * 0.95f);

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
        CCSprite *resetSprite = [CCSprite spriteWithSpriteFrameName:@"ResetButton.png"];
        CCSprite *resetSpriteSelected = [CCSprite spriteWithSpriteFrameName:@"ResetButtonSelected.png"];
        CCMenuItemSprite *resetButton = [CCMenuItemSprite itemWithNormalSprite:resetSprite 
                                                                selectedSprite:resetSpriteSelected
                                                                        target:self
                                                                      selector:@selector(resetViewportAndParticles)];
        CCMenu *menu = [CCMenu menuWithItems:resetButton, nil];
        [menu setPosition:ccp(winSize.width * 0.5f, winSize.height * 0.95f)];
        [self addChild:menu z:100];
        
        // Add score label.  Replace this later with your own image file.
        CCTexture2DPixelFormat currentFormat = [CCTexture2D defaultAlphaPixelFormat];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        scoreLabel = [[CCLabelAtlas alloc]  initWithString:@"0" charMapFile:@"fps_images.png" itemWidth:12 itemHeight:32 startCharMap:'.'];
        [CCTexture2D setDefaultAlphaPixelFormat:currentFormat];

        [scoreLabel setPosition:scorePosition];
        [self addChild:scoreLabel z:100];
        
        // Configure the node which controls rotation.
        centerNode = [CCNode node];
        centerNode.position = screenCenter;
        centerNode.rotation = 0;
        [centerNode addChild:sceneSpriteBatchNode z:0 tag:kTagBatchNode];
        [self addChild:centerNode];
        
        // This will set up the initial particle system.
        [self resetViewportAndParticles];
        
        // Set up the next particle.
        nextParticle = [self randomParticle];
        nextParticle.position = nextParticlePos;
        [self addChild:nextParticle];
        
        // Zero out touch handling.
        rotationTouch = nil;
        launchTouch = nil;
        initialTouchAngle = 0;
        currentTouchAngle = 0;
        initialRotation = 0;
        
        // Set up scoring fields
        self.particles = [NSMutableSet setWithCapacity:100];
        self.visitedParticles = [NSMutableSet setWithCapacity:100];
        self.scoredParticles = [NSMutableArray arrayWithCapacity:20];
        self.countedParticles = [NSMutableSet setWithCapacity:10];
        self.scoring = NO;
        self.gameOver = NO;
		
        // Start timer.
		[self schedule: @selector(step:)];
    }
    return self;
}

- (void)dealloc
{
    //TODO Clean up your mess.
    [particles release];
    [scoredParticles release];
    [visitedParticles release];
    [countedParticles release];
    [super dealloc];
}

@end
