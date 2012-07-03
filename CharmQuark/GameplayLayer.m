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

@interface GameplayLayer()

-(void)resetViewportAndParticles;
-(Particle*)randomParticle;
-(void) step: (ccTime) dt;
-(void) addParticle:(Particle*)particle atPosition:(CGPoint)position;
-(void) scoreParticles:(NSMutableSet*)particles;

@end

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
        [self.scoredParticles removeObject:particle];
        [particle removeFromParentAndCleanup:YES];
    }
}

static void scheduleForRemoval(cpBody *body, GameplayLayer *self) {
    cpSpaceAddPostStepCallback(self.space, (cpPostStepFunc)postStepRemoveParticle, body, self);
}



// This function synchronizes the body with the sprite.
static void syncSpriteToBody(cpBody *body, void* unused) {
	Particle *sprite = body->data;
	if( sprite ) {
		[sprite setPosition: body->p];
        //[sprite.streak setPosition:body->p];
		[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
	}
}

// This is what makes the particles cluster.  Tries to move towards the origin.
static void gameVelocityFunc(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	cpVect p = cpBodyGetPos(body);
    //cpVect g = cpvmult(p, -200 * cpvlength(p) / (1.5f * screenCenter.y));
    cpVect g = cpvmult(cpvnormalize(p), -1500);
	cpBodyUpdateVelocity(body, g, damping, dt);
}

#pragma mark Collision Handlers

static int collisionBegin(cpArbiter *arb, struct cpSpace *space, GameplayLayer *self)
{
    // Keep track of what particles this particle is touching.
    CP_ARBITER_GET_BODIES(arb, a, b);
    
    Particle *p1 = a->data;
    Particle *p2 = b->data;
    
    if (p1.particleColor == p2.particleColor) {
        // Link particle objects.
        [p1 addMatchingParticle:p2];
        [p2 addMatchingParticle:p1];
    }
    return true;
}

static int collisionPreSolve(cpArbiter *arb, cpSpace *space, GameplayLayer *self)
{
    // Don't do this on the first collision.
    CP_ARBITER_GET_BODIES(arb, a, b);
    
    Particle *p1 = a->data;
    Particle *p2 = b->data;
    
    if (p1.particleColor == p2.particleColor) {
        //        cpArbiterSetElasticity(arb, 0.2);
        if (cpvlength(cpvsub(a->v, b->v)) < 0.001) {
            // Should already be linked, so...
            
            // Count chain
            NSMutableSet *matchedParticles = [NSMutableSet setWithCapacity:kMinMatchSize];
            [p1 addMatchingParticlesToSet:matchedParticles];
            if ([matchedParticles count] >= kMinMatchSize) {
                [self scoreParticles:matchedParticles];
                //cpArbiterIgnore(arb);  // Stop calling this, we're done.
            }
        }
        return true;
    }
    return false;
}

static void collisionPostSolve(cpArbiter *arb, cpSpace *space, GameplayLayer *self)
{
    // Do nothing here.  Since we're using sensors.
}

void collisionSeparate(cpArbiter *arb, cpSpace *space, GameplayLayer *self)
{
    // Unlink particle objects.
    CP_ARBITER_GET_BODIES(arb, a, b);
    
    Particle *p1 = a->data;
    Particle *p2 = b->data;
    
    if (p1.particleColor == p2.particleColor) {
        // Link particle objects.
        [p1 removeMatchingParticle:p2];
        [p2 removeMatchingParticle:p1];
    }
}

@implementation GameplayLayer

@synthesize space;
@synthesize scoredParticles;
@synthesize score;
@synthesize scoreLabel;

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
    score = 0;
    [scoreLabel setString:@"0"];
}

-(Particle*)randomParticle {
    Particle *particle = nil;
    ParticleColors color = rand() % 7;
    particle = [Particle particleWithColor:color]; 
    //particle = [Particle particleWithColor:kParticleGreen]; 
    return particle;
}

-(void) addParticle:(Particle*)particle atPosition:(CGPoint)position
{
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
    cpShape* sensor = cpCircleShapeNew(body, 20.0f, CGPointZero);
    cpShapeSetSensor(sensor, YES);
    cpShapeSetCollisionType(sensor, kParticleCollisionType); // Is this really the best way to do this?

    cpShape* shape = cpCircleShapeNew(body, 15.0f, CGPointZero);
    cpShapeSetFriction(shape, kParticleFriction);
    cpShapeSetElasticity(shape, kParticleElasticity);

    cpSpaceAddBody(space, body);
	cpSpaceAddShape(space, shape);
	cpSpaceAddShape(space, sensor);
}

-(void) scoreParticles:(NSMutableSet*)particles {
    NSInteger points = 0;
    NSMutableSet *newScoredParticles = [[NSMutableSet alloc] initWithCapacity:10];
    for (Particle *particle in particles) {
        // See if this one has already been scored.
        if (![scoredParticles containsObject:particle]) {
            // Add to global score.  Prevents duplicate scores for multi-way collisions.
            [scoredParticles addObject:particle];
            [newScoredParticles addObject:particle];
            scheduleForRemoval(particle.body, self);
            points += kPointsPerMatch;
        } 
    }
    // Add multiplier.
    NSInteger multiplier = 1 + [newScoredParticles count] - kMinMatchSize ;
    [newScoredParticles release];
    if (multiplier > 1) {
        // TODO Show an animation!
        points *= multiplier;
    }
    score += points;
    [scoreLabel setString:[[[NSString alloc] initWithFormat:@"%d", score] autorelease]];
}

-(void) step: (ccTime)dt {
    static ccTime remainder = 0;
    dt += remainder;
    int steps = dt / kSimulationRate;
    remainder = fmodf(dt, kSimulationRate);
    
    for (int i = 0; i < steps; i++) {
        cpSpaceStep(space, kSimulationRate);
        cpSpaceEachBody(space, &syncSpriteToBody, self);
    }
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
        
        // Set up fields
        self.scoredParticles = [NSMutableSet setWithCapacity:10];
		
        // Start timer.
		[self schedule: @selector(step:)];
    }
    return self;
}

- (void)dealloc
{
    //TODO Clean up your mess.
    [scoredParticles release];
    [super dealloc];
}

@end
