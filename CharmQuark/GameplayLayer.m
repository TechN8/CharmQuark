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
static CGPoint viewCenter;
static CGPoint nextParticlePos;
static CGPoint scorePosition;

@interface GameplayLayer()

-(void)resetViewportAndParticles;
-(Particle*)randomParticle;
-(void) addNewSpriteX: (float)x Y:(float)y;
-(void) step: (ccTime) dt;
-(void) addNewSpriteX:(float)x Y:(float)y;
-(void) scoreParticles:(NSMutableSet*)particles;

@end

#pragma mark -
#pragma mark C Functions

static void postStepRemoveParticle(cpSpace *space, cpShape *shape, GameplayLayer *self) {
    // You have these parameters reversed?
    Particle *particle = shape->data;
    cpSpaceRemoveBody(space, shape->body);
    cpBodyFree(shape->body);
    
    cpSpaceRemoveShape(space, shape);
    cpShapeFree(shape);

    // Free particle last or you will get EXECBADACCESS!
    //[sprite.streak reset];
    [self.scoredParticles removeObject:particle];
    [particle removeFromParentAndCleanup:YES];
}

static void scheduleForRemoval(cpShape *shape, GameplayLayer *self) {
    cpSpaceAddPostStepCallback(self.space, (cpPostStepFunc)postStepRemoveParticle, shape, self);
}

static int collisionBegin(cpArbiter *arb, struct cpSpace *space, GameplayLayer *self)
{
    // Check for chain, if found use cpSpaceAddPostStepCallback to remove and score.
    CP_ARBITER_GET_SHAPES(arb, a, b);
    
    Particle *p1 = a->data;
    Particle *p2 = b->data;
    
    if (p1.particleColor == p2.particleColor) {
        // Link particle objects.
        [p1 addMatchingParticle:p2];
        [p2 addMatchingParticle:p1];
        
        // Count chain
        NSMutableSet *matchedParticles = [NSMutableSet setWithCapacity:kMinMatchSize];
        [p1 addMatchingParticlesToSet:matchedParticles];
        if ([matchedParticles count] >= kMinMatchSize) {
            [self scoreParticles:matchedParticles];
        }
    }
    
    return true;
}

static int collisionPreSolve(cpArbiter *arb, cpSpace *space, GameplayLayer *self)
{
    // Doing nothing here.
    return true;
}

static void collisionPostSolve(cpArbiter *arb, cpSpace *space, GameplayLayer *self)
{
    // Doing nothing here.
}

void collisionSeparate(cpArbiter *arb, cpSpace *space, GameplayLayer *self)
{
    // Unlink particle objects.
    CP_ARBITER_GET_SHAPES(arb, a, b);
    
    Particle *p1 = a->data;
    Particle *p2 = b->data;
    
    if (p1.particleColor == p2.particleColor) {
        // Link particle objects.
        [p1 removeMatchingParticle:p2];
        [p2 removeMatchingParticle:p1];
    }
}

// This function synchronizes the body with the sprite.
static void eachShape(cpShape *ptr, void* unused) {
	cpShape *shape = (cpShape*) ptr;
	Particle *sprite = shape->data;
	if( sprite ) {
		cpBody *body = shape->body;
		[sprite setPosition: body->p];
        //[sprite.streak setPosition:body->p];
		[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
	}
}

// This is what makes the particles cluster.
static void gameVelocityFunc(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	cpVect p = cpBodyGetPos(body);
    cpVect d = cpvsub(p, viewCenter);
	//cpVect g = cpvmult(d, -100 * powf(cpvlength(d), 3.0f) / powf(1.5f * viewCenter.y, 2.0));
    cpVect g = cpvmult(d, -200 * cpvlength(d) / (1.5f * viewCenter.y));
    //cpBodySetMass(body, 5.0f + cpvlength(d));  // Test, make moving objects more massive.
	cpBodyUpdateVelocity(body, g, damping, dt);
}

@implementation GameplayLayer

@synthesize space;
@synthesize scoredParticles;
@synthesize score;
@synthesize scoreLabel;

-(void)resetViewportAndParticles {
    // Reset angle
    viewLayer.rotation = 0;
    
    // Remove all objects from the space.
    cpSpaceEachShape(space, (cpSpaceShapeIteratorFunc)scheduleForRemoval, self);
}

-(Particle*)randomParticle {
    Particle *sprite = nil;
    ParticleColors color = rand() % 6;
    sprite = [Particle particleWithColor:color]; 
    return sprite;
}

-(void) addNewSpriteX: (float)x Y:(float)y
{
    // Convert position from world to viewLayer coordinates.
    CGPoint position = [viewLayer convertToNodeSpace:ccp(x,y)];

    // Create next sprite.
    Particle *sprite = [Particle particleWithColor:nextParticle.particleColor];
    [self removeChild:nextParticle cleanup:NO];
    nextParticle = [self randomParticle];
    nextParticle.position = nextParticlePos;
    [self addChild:nextParticle];
    
	sprite.position = position;
    CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [viewLayer getChildByTag:kTagBatchNode];
    [batch addChild: sprite];

    // Add motion streak.
    //CCMotionStreak *streak = [CCMotionStreak streakWithFade:0.5 minSeg:3 width:2 color:ccGREEN texture: nil];
    //sprite.streak = streak;
    //streak.position = position;
    //[viewLayer addChild:streak];

	// Create physics body.
    cpBody *body = cpBodyNew(kParticleMass, cpMomentForCircle(1.0f, 0, 15.0f, CGPointZero));
    cpBodySetPos(body, position);
    body->velocity_func = gameVelocityFunc;
    cpBodySetVelLimit(body, kVelocityLimit);

    // Create physics shape.
    cpShape* shape = cpCircleShapeNew(body, 15.0f, CGPointZero);
    cpShapeSetFriction(shape, kParticleFriction);
    cpShapeSetElasticity(shape, kParticleElasticity);
    cpShapeSetCollisionType(shape, kParticleCollisionType); // Is this really the best way to do this?
	shape->data = sprite;
    sprite.shape = shape;

    cpSpaceAddBody(space, body);
	cpSpaceAddShape(space, shape);
	
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
            scheduleForRemoval(particle.shape, self);
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
    [scoreLabel setString:[[NSString alloc] initWithFormat:@"%d", score]];
}

-(void) step: (ccTime)dt {
    static ccTime remainder = 0;
    dt += remainder;
    int steps = dt / kSimulationRate;
    remainder = fmodf(dt, kSimulationRate);
    
    for (int i = 0; i < steps; i++) {
        cpSpaceStep(space, kSimulationRate);
        cpSpaceEachShape(space, &eachShape, self);
    }
}

#pragma mark -
#pragma mark CCTouchDelegateProtocol
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // We only support single touches, so anyObject retrieves just that touch from touches
	UITouch *touch = [touches anyObject];
	
	// Save game angle from start of touches
	initialRotation = viewLayer.rotation;
	
	// Capture initial touch and angle from center.
	CGPoint location = [touch locationInView: [touch view]];
    
    CGPoint ray = ccpSub(location, screenCenter);
    initialTouchAngle = CC_RADIANS_TO_DEGREES(ccpAngleSigned(kUnitVectorUp, ray));
    
    touchesMoved = NO;
}


- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView: [touch view]];

    CGPoint ray = ccpSub(location, screenCenter);
    currentTouchAngle = CC_RADIANS_TO_DEGREES(ccpAngleSigned(kUnitVectorUp, ray));
    
	GLfloat newRotation = fmodf(initialRotation + currentTouchAngle - initialTouchAngle, 360.0);
    
	viewLayer.rotation = newRotation;
    
    touchesMoved = YES;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touchesMoved) {
        return;
    }
    
    // Yeah, there should only be one?
	for( UITouch *touch in touches ) {
        CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location]; // You are an idiot!
		
		[self addNewSpriteX: location.x Y:location.y];
	}
    
    touchesMoved = NO;
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
        
        screenCenter = ccp(winSize.width * 0.7f, winSize.height * 0.5f);
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

        // Configure viewport layer.  Used to allow rotation of game.
        viewLayer = [CCLayerColor layerWithColor:ccc4(100, 100, 100, 255) 
                                           width:winSize.width * 0.5 
                                          height:winSize.width * 0.5];
        CGSize viewSize = [viewLayer contentSize];
        viewCenter = ccp(viewSize.width * 0.5, viewSize.height * 0.5);
        viewLayer.position = ccpSub(screenCenter, viewCenter);
        viewLayer.rotation = 0;
        [viewLayer addChild:sceneSpriteBatchNode z:0 tag:kTagBatchNode];
        [self addChild:viewLayer];
        
        // This will set up the initial particle system.
        [self resetViewportAndParticles];
        
        // Set up the next particle.
        nextParticle = [self randomParticle];
        nextParticle.position = nextParticlePos;
        [self addChild:nextParticle];
        
        // Zero out touch handling angles.
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
