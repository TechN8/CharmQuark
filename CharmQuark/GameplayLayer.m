//
//  GameplayLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/19/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "GameplayLayer.h"

enum {
	kTagBatchNode = 1,
};

static void
eachShape(void *ptr, void* unused)
{
	cpShape *shape = (cpShape*) ptr;
	CCSprite *sprite = shape->data;
	if( sprite ) {
		cpBody *body = shape->body;
		
		// TIP: cocos2d and chipmunk uses the same struct to store it's position
		// chipmunk uses: cpVect, and cocos2d uses CGPoint but in reality the are the same
		// since v0.7.1 you can mix them if you want.		
		[sprite setPosition: body->p];
		
		//[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
	}
}

@implementation GameplayLayer

- (id)init
{
    self = [super initWithColor:ccc4(255, 255, 255, 255)];
    if (self) {
        self.isTouchEnabled = YES;
        self.isAccelerometerEnabled = NO;

        CGSize winSize = [[CCDirector sharedDirector] winSize];
        cpInitChipmunk();
        
        cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
        space = cpSpaceNew();
        cpSpaceResizeStaticHash(space, 400.0f, 40);
        cpSpaceResizeActiveHash(space, 100.0f, 600);
        
        space->gravity = ccp(0, 0);
        space->elasticIterations = space->iterations;
        
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
	
	CCSprite *sprite = [CCSprite spriteWithBatchNode:batch rect:CGRectMake(0, 0, 23, 23)];
	[batch addChild: sprite];
	
	sprite.position = ccp(x,y);
	
    cpBody *body = cpBodyNew(1.0f, cpMomentForCircle(1.0f, 0, 11.0f, CGPointZero));
	
	// TIP:
	// since v0.7.1 you can assign CGPoint to chipmunk instead of cpVect.
	// cpVect == CGPoint
	body->p = ccp(x, y);
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
	cpSpaceHashEach(space->activeShapes, &eachShape, nil);
	cpSpaceHashEach(space->staticShapes, &eachShape, nil);
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
