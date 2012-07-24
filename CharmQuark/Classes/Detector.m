//
//  Detector.m
//  CharmQuark
//
//  Created by Nathan Babb on 7/19/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "Detector.h"
#import "RemoveFromParentAction.h"

@implementation Detector

-(id)init {
    self = [super initWithSpriteFrameName:@"detector.png"];
    if (self) {
        int radius = self.contentSize.height / 2;
        blinkRadius = radius * 0.88;
        graphRadius = radius * 0.52;

        center = ccp(self.contentSize.width / 2,
                     self.contentSize.height / 2);
    }
    return self;
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
    [self addChild:blink z:100];
    id flash = [CCBlink actionWithDuration:1.0 blinks:2];
    id loop = [CCRepeatForever actionWithAction:flash];
    [blink runAction:loop];

}

-(void)blinkAtAngle:(CGFloat)angle {
    // Work in radians.
    angle = CC_DEGREES_TO_RADIANS(angle);
    
    // Draw three blinks.
    float blinkAngle = angle - M_PI / 12;
    for (int i = 0; i < 3; i++) {
        CCSprite *blink = [CCSprite spriteWithSpriteFrameName:@"blink.png"];
        blink.color = ccYELLOW;
        blink.anchorPoint = ccp(0.5, 0.5);
        blink.scaleX = 0.5 + (float)rand()/((float)RAND_MAX/0.5);
        blink.position = ccp(center.x + blinkRadius * cosf(blinkAngle),
                              center.y - blinkRadius * sinf(blinkAngle));
        blink.rotation = CC_RADIANS_TO_DEGREES(blinkAngle);
        [self addChild:blink z:100];
        id scaleOut = [CCScaleTo actionWithDuration:0.7 + (float)rand()/((float)RAND_MAX) 
                                             scaleX:0.1 scaleY:0.1];
        id remove = [RemoveFromParentAction action];
        id seq = [CCSequence actions:scaleOut, remove, nil];
        [blink runAction:seq];
        blinkAngle += M_PI / 12;
    }
    
    // Draw 7 graphs.
    float graphAngle = angle - M_PI / 12;
    for (int i = 0; i < 5; i++) {
        CCSprite *graph = [CCSprite spriteWithSpriteFrameName:@"graph.png"];
        graph.color = ccGREEN;
        graph.anchorPoint = ccp(0,0.5);
        graph.scaleX = (float)rand()/((float)RAND_MAX/40);
        graph.position = ccp(center.x + graphRadius * cosf(graphAngle),
                             center.y - graphRadius * sinf(graphAngle));
        graph.rotation = CC_RADIANS_TO_DEGREES(graphAngle);
        id scaleOut = [CCScaleTo actionWithDuration:0.7 + (float)rand()/((float)RAND_MAX) 
                                             scaleX:0.0 scaleY:0.7];
        id remove = [RemoveFromParentAction action];
        id seq = [CCSequence actions:scaleOut, remove, nil];
        [self addChild:graph];
        [graph runAction:seq];
        graphAngle += M_PI / 24;
    }
}

@end
