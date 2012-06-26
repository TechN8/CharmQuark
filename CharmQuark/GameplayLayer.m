//
//  GameplayLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/19/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "GameplayLayer.h"

static CGFloat simRate = 1 / 120.0;
static CGPoint up = {0, 1};
static CGPoint screenCenter;
static CGPoint viewCenter;

enum {
	kTagBatchNode = 1,
};

#pragma mark -
#pragma mark C Functions

static void shapeFreeWrap(cpSpace *space, cpShape *shape, void *unused) {
    CCSprite *sprite = shape->data;
    [sprite.parent removeChild:sprite cleanup:YES];
	cpSpaceRemoveShape(space, shape);
	cpShapeFree(shape);
}

static void postShapeFree(cpShape *shape, cpSpace *space) {
	cpSpaceAddPostStepCallback(space, (cpPostStepFunc)shapeFreeWrap, shape, NULL);
}

static void constraintFreeWrap(cpSpace *space, cpConstraint *constraint, void *unused) {
	cpSpaceRemoveConstraint(space, constraint);
	cpConstraintFree(constraint);
}

static void postConstraintFree(cpConstraint *constraint, cpSpace *space) {
	cpSpaceAddPostStepCallback(space, (cpPostStepFunc)constraintFreeWrap, constraint, NULL);
}

static void bodyFreeWrap(cpSpace *space, cpBody *body, void *unused) {
	cpSpaceRemoveBody(space, body);
	cpBodyFree(body);
}

static void postBodyFree(cpBody *body, cpSpace *space) {
	cpSpaceAddPostStepCallback(space, (cpPostStepFunc)bodyFreeWrap, body, NULL);
}

static void eachShape(cpShape *ptr, void* unused) {
	cpShape *shape = (cpShape*) ptr;
	CCSprite *sprite = shape->data;
	if( sprite ) {
		cpBody *body = shape->body;
		[sprite setPosition: body->p];
		[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
	}
}

/*
static void
planetGravityVelocityFunc(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	// Gravitational acceleration is proportional to the inverse square of
	// distance, and directed toward the restPosition. 
	cpVect p = cpBodyGetPos(body);
    cpVect d = cpvsub(p, restPosition);
	cpFloat sqdist = cpvlengthsq(d);
    cpVect g = cpvmult(d, -gravityStrength / (sqdist * cpfsqrt(sqdist)));
	cpBodyUpdateVelocity(body, g, damping, dt);
}
*/

static void
gameVelocityFunc(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	cpVect p = cpBodyGetPos(body);
    cpVect d = cpvsub(p, viewCenter);
	cpVect g = cpvmult(d, -1 * powf(cpvlength(d), 4.0f) / powf(1.5f * viewCenter.y, 3.0));
	cpBodyUpdateVelocity(body, g, damping, dt);
}

@implementation GameplayLayer

-(void)resetViewportAndParticles {
    // Reset angle
    viewLayer.rotation = 0;
    
    // Remove all objects from the space.
    cpSpaceEachShape(space, (cpSpaceShapeIteratorFunc)postShapeFree, space);
	cpSpaceEachConstraint(space, (cpSpaceConstraintIteratorFunc)postConstraintFree, space);
	cpSpaceEachBody(space, (cpSpaceBodyIteratorFunc)postBodyFree, space);

    // Add a starting sprite back in.
    [self addNewSpriteX: screenCenter.x Y:screenCenter.y];
}

-(void) addNewSpriteX: (float)x Y:(float)y
{
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [viewLayer getChildByTag:kTagBatchNode];
	
    CCSprite *sprite = nil;
    int spriteNum = rand() % 3;
    switch (spriteNum) {
        case 0:
            sprite = [CCSprite spriteWithTexture:[batch texture] rect:CGRectMake(0, 0, 25, 25)];
            break;
        case 1:
            sprite = [CCSprite spriteWithTexture:[batch texture] rect:CGRectMake(25, 0, 25, 25)];
            break;
        case 2:
            sprite = [CCSprite spriteWithTexture:[batch texture] rect:CGRectMake(50, 0, 25, 25)];
            break;
        default:
            break;
    }
    [batch addChild: sprite];
	
    CGPoint position = ccp(x,y);
    position = CGPointApplyAffineTransform(position, viewLayer.worldToNodeTransform);
    
	sprite.position = position;
	
    cpFloat mass = 5.0f;
    cpBody *body = cpBodyNew(mass, cpMomentForCircle(1.0f, 0, 11.0f, CGPointZero));
    //cpBody *body = cpBodyNew(mass, INFINITY);
    cpBodySetPos(body, position);
    body->velocity_func = gameVelocityFunc;
    
    // This stops the sprite from moving too fast.
    cpBodySetVelLimit(body, 1500.0);
    
    cpSpaceAddBody(space, body);
	
    cpShape* shape = cpCircleShapeNew(body, 11.0f, CGPointZero);
    cpShapeSetFriction(shape, 0.0f);
	shape->e = 0.5f; shape->u = 0.5f;
	shape->data = sprite;
	cpSpaceAddShape(space, shape);
	
}

-(void) step: (ccTime)dt {
    static ccTime remainder = 0;
    dt += remainder;
    int steps = dt / simRate;
    remainder = fmodf(dt, simRate);
    
    for (int i = 0; i < steps; i++) {
        cpSpaceStep(space, simRate);
        cpSpaceEachShape(space, &eachShape, nil);
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
    initialTouchAngle = CC_RADIANS_TO_DEGREES(ccpAngleSigned(up, ray));
    
    touchesMoved = NO;
}


- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView: [touch view]];

    CGPoint ray = ccpSub(location, screenCenter);
    currentTouchAngle = CC_RADIANS_TO_DEGREES(ccpAngleSigned(up, ray));
    
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
    self = [super initWithColor:ccc4(255, 255, 255, 255)];
    if (self) {
        self.isTouchEnabled = YES;
        self.isAccelerometerEnabled = NO;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        screenCenter = ccp(winSize.width * 0.7f, winSize.height * 0.5f);

        // Set up simulation.
        //cpInitChipmunk();
        //cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
        space = cpSpaceNew();
        cpSpaceSetGravity(space, ccp(0,0));
        cpSpaceSetDamping(space, 0.7f);
        
        // Set up controls
        CCMenuItemImage *resetButton 
        = [CCMenuItemImage itemWithNormalImage:@"ResetButton.png" 
                                 selectedImage:@"ResetButtonSelected.png" 
                                        target:self 
                                      selector:@selector(resetViewportAndParticles)];
        CCMenu *menu = [CCMenu menuWithItems:resetButton, nil];
        [menu setPosition:ccp(winSize.width * 0.93f, winSize.height * 0.9f)];
        [self addChild:menu z:100];

        // Configure viewport layer.  Used to allow rotation of game.
        viewLayer = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255) 
                                           width:winSize.width * 0.5 
                                          height:winSize.width * 0.5];
        CGSize viewSize = [viewLayer contentSize];
        viewCenter = ccp(viewSize.width * 0.5, viewSize.height * 0.5);
        viewLayer.position = ccpSub(screenCenter, viewCenter);
        viewLayer.rotation = 0;
        [self addChild:viewLayer];
        
        // Load sprite sheet.
        CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"SpriteSheet.png" capacity:100];
        [viewLayer addChild:batch z:0 tag:kTagBatchNode];
        
        // This will set up the initial particle system.
        [self resetViewportAndParticles];
        
        // Zero out touch handling angles.
        initialTouchAngle = 0;
        currentTouchAngle = 0;
        initialRotation = 0;
		
        // Start timer.
		[self schedule: @selector(step:)];
    }
    return self;
}

- (void)dealloc
{
    //TODO Clean up your mess.
    [super dealloc];
}

@end
