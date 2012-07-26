//
//  Detector.m
//  CharmQuark
//
//  Created by Nathan Babb on 7/19/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "Detector.h"
#import "RemoveFromParentAction.h"
#import "FRCurve.h"
#import "GameplayLayer.h"

@interface Detector()
    -(void)blinkAtAngle:(CGFloat)angle;
    -(void)graphAtAngle:(CGFloat)angle;
    -(void)trackAtAngle:(CGFloat)angle;
@end

@implementation Detector

-(void) tick: (ccTime) dt {
    
}

-(id)init {
    self = [super initWithSpriteFrameName:@"detector.png"];
    if (self) {
        int radius = self.contentSize.height / 2;
        blinkRadius = radius * 0.88;
        graphRadius = radius * 0.52;
        trackRadius = radius * 1.5;

//        center = ccp(self.contentSize.width / 2,
//                     self.contentSize.height / 2);
        
    }
    return self;
}

-(void)onEnter {
    batchNode = (CCSpriteBatchNode*)[self.parent getChildByTag:kTagUIBatchNode];
    center = self.position;
}

-(void)dealloc {
    [super dealloc];
}

// This takes radians.
-(void)gameOverAtAngle:(CGFloat)angle {
    // Work in radians.
    angle = CC_DEGREES_TO_RADIANS(angle);

    CCSprite *blink = [CCSprite spriteWithSpriteFrameName:@"blink.png"];
    blink.color = ccRED;
    blink.anchorPoint = ccp(0.5, 0.5);
    //blink.scaleX = 0.5 + (float)rand()/((float)RAND_MAX/0.5);
    blink.position = ccp(center.x + blinkRadius * cosf(angle),
                         center.y - blinkRadius * sinf(angle));
    blink.rotation = CC_RADIANS_TO_DEGREES(angle);
    [batchNode addChild:blink z:100];
    id flash = [CCBlink actionWithDuration:1.0 blinks:2];
    id loop = [CCRepeatForever actionWithAction:flash];
    [blink runAction:loop];

}

-(void)blinkAtAngle:(CGFloat)angle {
    CCSprite *blink = [CCSprite spriteWithSpriteFrameName:@"blink.png"];
    blink.color = ccYELLOW;
    blink.anchorPoint = ccp(0.5, 0.5);
    blink.scaleX = 0.5 + (float)rand()/((float)RAND_MAX/0.5);
    blink.position = ccp(center.x + blinkRadius * cosf(angle),
                         center.y - blinkRadius * sinf(angle));
    blink.rotation = CC_RADIANS_TO_DEGREES(angle);
    [batchNode addChild:blink z:100];
    id scaleOut = [CCScaleTo actionWithDuration:0.7 + (float)rand()/((float)RAND_MAX) 
                                         scaleX:0.1 scaleY:0.1];
    id remove = [RemoveFromParentAction action];
    id seq = [CCSequence actions:scaleOut, remove, nil];
    [blink runAction:seq];
}

-(void)graphAtAngle:(CGFloat)angle {
    CCSprite *graph = [CCSprite spriteWithSpriteFrameName:@"graph.png"];
    graph.color = ccGREEN;
    graph.anchorPoint = ccp(0,0.5);
    graph.scaleX = (float)rand()/((float)RAND_MAX/40);
    graph.position = ccp(center.x + graphRadius * cosf(angle),
                         center.y - graphRadius * sinf(angle));
    graph.rotation = CC_RADIANS_TO_DEGREES(angle);
    id scaleOut = [CCScaleTo actionWithDuration:0.7 + (float)rand()/((float)RAND_MAX) 
                                         scaleX:0.0 scaleY:0.7];
    id remove = [RemoveFromParentAction action];
    id seq = [CCSequence actions:scaleOut, remove, nil];
    [batchNode addChild:graph];
    [graph runAction:seq];
}

-(void)draw {
    [super draw];

    /*
    
    for (Track *track in tracks) {
        CGFloat angle = track.angle;
        
        // Line (Red)
        ccDrawColor4B(255, 0, 0, 255);
        ccDrawLine(center, ccp(center.x + trackRadius * cosf(angle),     // Destination
                               center.y - trackRadius * sinf(angle)));
        
        CGPoint p2 = ccp(center.x + graphRadius * cosf(angle+M_PI/24),     // Control1
                         center.y - graphRadius * sinf(angle+M_PI/24));

        CGPoint p3 = ccp(center.x + graphRadius * cosf(angle+M_PI/24),     // Control1
                         center.y - graphRadius * sinf(angle+M_PI/24));
        
        CGPoint p4 = ccp(center.x + blinkRadius * cosf(angle+M_PI/24),     // Control2
                         center.y - blinkRadius * sinf(angle+M_PI/24));

        // Bezier (Green)
        ccDrawColor4B(0, 255, 0, 255);
        ccDrawCubicBezier(center, 
                          p2, 
                          p3,
                          p4,
                          10);
        
        // Catmull-Rom (Blue)
        ccDrawColor4B(0, 0, 255, 255);
        CCPointArray *points = [CCPointArray arrayWithCapacity:5];
        [points addControlPoint:center];
        [points addControlPoint:p2];
        [points addControlPoint:p3];
        [points addControlPoint:p4];
        ccDrawCatmullRom(points, 5);
     
     */
}

-(void)animateAtAngle:(CGFloat)angle {
    // Work in radians.
    angle = CC_DEGREES_TO_RADIANS(angle);
    
    // Draw three blinks.
    float blinkAngle = angle - M_PI / 12;
    for (int i = 0; i < 3; i++) {
        [self blinkAtAngle:blinkAngle];
        blinkAngle += M_PI / 12;
    }
    
    // Draw 5 graphs.
    float graphAngle = angle - M_PI / 12;
    for (int i = 0; i < 5; i++) {
        [self graphAtAngle:graphAngle];
        graphAngle += M_PI / 24;
    }
}

@end

//@implementation Track

//@synthesize angle, distance, ttl;
//
//+(id)trackWithAngle:(CGFloat)angle distance:(CGFloat)distance ttl:(ccTime)ttl {
//    Track *track = [[[self alloc] init] autorelease];
//    track->angle = angle;
//    track->distance = distance;
//    track->ttl = ttl;
//    return track;
//}

//@end