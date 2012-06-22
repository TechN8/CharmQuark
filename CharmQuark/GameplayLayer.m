//
//  GameplayLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/19/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "GameplayLayer.h"

static cpFloat gravityStrength = 1.0e5f;
static cpVect centerMass = {320.0f, 240.0f}; 

enum {
	kTagBatchNode = 1,
};

static void
eachShape(cpShape *ptr, void* unused)
{
	cpShape *shape = (cpShape*) ptr;
	CCSprite *sprite = shape->data;
	if( sprite ) {
		cpBody *body = shape->body;
		
		// TIP: cocos2d and chipmunk uses the same struct to store it's position
		[sprite setPosition: body->p];
		
		[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
	}
}

static void
planetGravityVelocityFunc(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	// Gravitational acceleration is proportional to the inverse square of
	// distance, and directed toward the origin. The central planet is assumed
	// to be massive enough that it affects the satellites but not vice versa.
	//cpVect p = cpBodyGetPos(body);
	//cpFloat sqdist = cpvlengthsq(p);
	//cpVect g = cpvmult(p, -gravityStrength / (sqdist * cpfsqrt(sqdist)));
    
    
	cpVect p = cpBodyGetPos(body);
    cpVect d = cpvsub(p, centerMass);
	cpFloat sqdist = cpvlengthsq(d);
    cpVect g = cpvmult(d, -gravityStrength / (sqdist * cpfsqrt(sqdist)));
    CCLOG(g);
	
	cpBodyUpdateVelocity(body, g, damping, dt);
}

@implementation GameplayLayer


- (id)init
{
    self = [super initWithColor:ccc4(255, 255, 255, 255)];
    if (self) {
        self.isTouchEnabled = YES;
        self.isAccelerometerEnabled = NO;

        CGSize winSize = [[CCDirector sharedDirector] winSize];
        centerMass.x = winSize.width / 2.0f;
        centerMass.y = winSize.height / 2.0f;
        cpInitChipmunk();
        
        cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
        space = cpSpaceNew();
        
        space->gravity = ccp(0, 0);
        
        cpShape *shape;
        
        // bottom
		shape = cpSegmentShapeNew(staticBody, ccp(0,0), ccp(winSize.width,0), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		// top
		shape = cpSegmentShapeNew(staticBody, ccp(0,winSize.height), ccp(winSize.width,winSize.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		// left
		shape = cpSegmentShapeNew(staticBody, ccp(0,0), ccp(0,winSize.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		// right
		shape = cpSegmentShapeNew(staticBody, ccp(winSize.width,0), ccp(winSize.width,winSize.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"Quark.png" capacity:100];
		[self addChild:batch z:0 tag:kTagBatchNode];
		
		[self addNewSpriteX: 200 Y:200];
		
		[self schedule: @selector(step:)];
    }
    return self;
}

-(void) addNewSpriteX: (float)x Y:(float)y
{
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
	
	CCSprite *sprite = [CCSprite spriteWithTexture:[batch texture] rect:CGRectMake(0, 0, 23, 23)];
	[batch addChild: sprite];
	
	sprite.position = ccp(x,y);
	
    cpBody *body = cpBodyNew(1.0f, cpMomentForCircle(1.0f, 0, 11.0f, CGPointZero));
	
	body->p = ccp(x, y);
    body->velocity_func = planetGravityVelocityFunc;

    // Set velocity to put it into a circular
	//cpFloat r = cpvlength(sprite.position);
    cpFloat r = cpvdist(sprite.position, centerMass);
	cpFloat v = cpfsqrt(gravityStrength / r) / r;
    //cpBodySetVel(body, cpvmult(cpvperp(sprite.position), v));
    cpVect d = cpvsub(sprite.position, centerMass); 
    cpBodySetVel(body, cpvmult(cpvperp(d), v));
    
    
    
	// Set the box's angular velocity to match its orbital period and
	// align its initial angle with its position.
	cpBodySetAngVel(body, v);
	cpBodySetAngle(body, cpfatan2(sprite.position.y, sprite.position.x));
    
    cpSpaceAddBody(space, body);
	
    cpShape* shape = cpCircleShapeNew(body, 11.0f, CGPointZero);
	shape->e = 0.5f; shape->u = 0.5f;
	shape->data = sprite;
	cpSpaceAddShape(space, shape);
	
}

-(void) step: (ccTime) delta
{
	int steps = 2;
	CGFloat dt = delta/(CGFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(space, dt);
	}
    cpSpaceEachShape(space, &eachShape, nil);
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		[self addNewSpriteX: location.x Y:location.y];
	}
}
@end
