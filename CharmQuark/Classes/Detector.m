//
//  Detector.m
//  CharmQuark
//
//  Created by Nathan Babb on 7/19/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "Detector.h"
#import "RemoveFromParentAction.h"
#import "GameplayLayer.h"

@interface Detector()
-(void)blinkAtAngle:(CGFloat)angle;
-(void)graphAtAngle:(CGFloat)angle color:(ccColor3B)color;
@end

@implementation Detector

-(id)init {
    self = [super initWithSpriteFrameName:@"detector.png"];
    if (self) {
        int radius = self.contentSize.height / 2;
        blinkRadius = radius * 0.88;
        graphRadius = radius * 0.52;
        trackRadius = radius * 1.5;
    }
    return self;
}

-(void)onEnter {
    [super onEnter];
    center = self.position;
}

-(void)dealloc {
    [super dealloc];
}

// This takes radians.
-(void)gameOverAtAngle:(CGFloat)angle {
    // Work in radians.
    angle = CC_DEGREES_TO_RADIANS(angle);
    
    float deviation = (fmodf(angle, M_PI / 12));
    if (angle < 0) {
        angle -= M_PI / 24 + deviation;
    } else {
        angle += M_PI / 24 - deviation;
    }
    
    CCSprite *blink = [CCSprite spriteWithSpriteFrameName:@"blink.png"];
    blink.color = ccRED;
    blink.anchorPoint = ccp(0.5, 0.5);
    blink.position = ccp(center.x + blinkRadius * cosf(angle),
                         center.y - blinkRadius * sinf(angle));
    blink.rotation = CC_RADIANS_TO_DEGREES(angle);
    [self.parent addChild:blink z:self.zOrder + 1];

//    id flash = [CCBlink actionWithDuration:1.0 blinks:2];
//    id loop = [CCRepeatForever actionWithAction:flash];

    id fadeout = [CCFadeTo actionWithDuration:0.5 opacity:128];
    id fadein = [CCFadeTo actionWithDuration:0.5 opacity:255];
    id seq = [CCSequence actions:fadeout, fadein, nil];
    id loop = [CCRepeatForever actionWithAction:seq];

    [blink runAction:loop];
}

-(void)blinkAtAngle:(CGFloat)angle {
    CCSprite *blink = [CCSprite spriteWithSpriteFrameName:@"blink.png"];
    blink.color = ccYELLOW;
    blink.anchorPoint = ccp(0.5, 0.5);
    blink.scale = 0.3 + (float)rand()/((float)RAND_MAX/0.7);
    blink.position = ccp(center.x + blinkRadius * cosf(angle),
                         center.y - blinkRadius * sinf(angle));
    blink.rotation = CC_RADIANS_TO_DEGREES(angle);
    [self.parent addChild:blink z:self.zOrder + 1];
    id flash = [CCBlink actionWithDuration:0.5 + (float)rand()/((float)RAND_MAX/0.5) 
                                    blinks:rand() % 4];
    id remove = [RemoveFromParentAction action];
    id seq = [CCSequence actions:flash, remove, nil];
    [blink runAction:seq];
}

-(void)graphAtAngle:(CGFloat)angle color:(ccColor3B)color {
    CCSprite *graph = [CCSprite spriteWithSpriteFrameName:@"graph.png"];
    graph.color = color;
    graph.anchorPoint = ccp(0,0.5);
    graph.scaleX = 0.5 + (float)rand()/((float)RAND_MAX/1.0);
    graph.position = ccp(center.x + graphRadius * cosf(angle),
                         center.y - graphRadius * sinf(angle));
    graph.rotation = CC_RADIANS_TO_DEGREES(angle);
    id scaleOut = [CCScaleTo actionWithDuration:0.5 + (float)rand()/((float)RAND_MAX/0.5) 
                                         scaleX:0
                                         scaleY:1];
    id remove = [RemoveFromParentAction action];
    id seq = [CCSequence actions:scaleOut, remove, nil];
    [self.parent addChild:graph z:self.zOrder + 1];
    [graph runAction:seq];
}

-(void)animateAtAngle:(CGFloat)angle graphColor:(ccColor3B)color {
    // Work in radians.
    angle = CC_DEGREES_TO_RADIANS(angle);

    // Adjust to nearest multiple of M_PI / 12.
    float deviation = (fmodf(angle, M_PI / 12));
    if (angle < 0) {
        angle -= M_PI / 24 + deviation;
    } else {
        angle += M_PI / 24 - deviation;
    }

    // Draw three blinks.
    float blinkAngle = angle - M_PI / 12;
    for (int i = 0; i < 3; i++) {
        [self blinkAtAngle:blinkAngle];
        blinkAngle += M_PI / 12;
    }
    
    // Draw 5 graphs.
    float graphAngle = angle - M_PI / 24;
    for (int i = 0; i < 5; i++) {
        [self graphAtAngle:graphAngle color:color];
        graphAngle += M_PI / 24;
    }
}

@end