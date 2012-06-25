//
//  GameplayLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/19/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "GameplayLayer.h"

static cpVect restPosition = {320.0f, 240.0f};
static CGFloat simRate = 1 / 120.0;
static cpFloat nextMass = 1.0f;

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
		
		// TIP: cocos2d and chipmunk uses the same struct to store it's position
		[sprite setPosition: body->p];
		
		[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
	}
}

/*
static void
planetGravityVelocityFunc(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	// Gravitational acceleration is proportional to the inverse square of
	// distance, and directed toward the origin. 
	cpVect p = cpBodyGetPos(body);
    cpVect d = cpvsub(p, centerMass);
	cpFloat sqdist = cpvlengthsq(d);
    cpVect g = cpvmult(d, -gravityStrength / (sqdist * cpfsqrt(sqdist)));
	
	cpBodyUpdateVelocity(body, g, damping, dt);
}
*/

static void
gameVelocityFunc(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	cpVect p = cpBodyGetPos(body);
    cpVect d = cpvsub(p, restPosition);
	cpVect g = cpvmult(d, -1 * powf(cpvlength(d), 4.0f) / powf(1.5f * restPosition.y, 3.0));
	cpBodyUpdateVelocity(body, g, damping, dt);
}

@implementation GameplayLayer

-(void)resetButtonPressed {
    // Remove all objects from the space.
    cpSpaceEachShape(space, (cpSpaceShapeIteratorFunc)postShapeFree, space);
	cpSpaceEachConstraint(space, (cpSpaceConstraintIteratorFunc)postConstraintFree, space);
	cpSpaceEachBody(space, (cpSpaceBodyIteratorFunc)postBodyFree, space);

    // Add a starting sprite back in.
    [self addNewSpriteX: restPosition.x Y:restPosition.y];
}

-(void) initSpace {
    cpInitChipmunk();
    
    //cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
    space = cpSpaceNew();
    cpSpaceSetGravity(space, ccp(0,0));
    cpSpaceSetDamping(space, 0.7f);
    
    //        cpShape *shape;
    
    //        // bottom
    //		shape = cpSegmentShapeNew(staticBody, ccp(0,0), ccp(winSize.width,0), 10.0f);
    //		shape->e = 1.0f; shape->u = 1.0f;
    //		cpSpaceAddStaticShape(space, shape);
    //		
    //		// top
    //		shape = cpSegmentShapeNew(staticBody, ccp(0,winSize.height), ccp(winSize.width,winSize.height), 10.0f);
    //		shape->e = 1.0f; shape->u = 1.0f;
    //		cpSpaceAddStaticShape(space, shape);
    //		
    //		// left
    //		shape = cpSegmentShapeNew(staticBody, ccp(0,0), ccp(0,winSize.height), 10.0f);
    //		shape->e = 1.0f; shape->u = 1.0f;
    //		cpSpaceAddStaticShape(space, shape);
    //		
    //		// right
    //		shape = cpSegmentShapeNew(staticBody, ccp(winSize.width,0), ccp(winSize.width,winSize.height), 10.0f);
    //		shape->e = 1.0f; shape->u = 1.0f;
    //		cpSpaceAddStaticShape(space, shape);
    
    CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"SpriteSheet.png" capacity:100];
    [self addChild:batch z:0 tag:kTagBatchNode];
    
    [self addNewSpriteX: restPosition.x Y:restPosition.y];
}

-(void) addNewSpriteX: (float)x Y:(float)y
{
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
	
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
	
	sprite.position = ccp(x,y);
	
    cpFloat mass = nextMass;
    //nextMass *= 2;
    cpBody *body = cpBodyNew(mass, cpMomentForCircle(1.0f, 0, 11.0f, CGPointZero));
    //cpBody *body = cpBodyNew(mass, INFINITY);
    cpBodySetPos(body, ccp(x, y));
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

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		[self addNewSpriteX: location.x Y:location.y];
	}
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
        restPosition.x = winSize.width * 0.7f;
        restPosition.y = winSize.height * 0.5f;
        
        CCMenuItemImage *resetButton 
        = [CCMenuItemImage itemWithNormalImage:@"ResetButton.png" 
                                 selectedImage:@"ResetButtonSelected.png" 
                                        target:self 
                                      selector:@selector(resetButtonPressed)];
        
        CCMenu *menu = [CCMenu menuWithItems:resetButton, nil];
        
        [menu setPosition:ccp(winSize.width * 0.93f, winSize.height * 0.9f)];
        [self addChild:menu z:100];
        
        // Moved all the Chipmunk setup here.
        [self initSpace];
		
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
