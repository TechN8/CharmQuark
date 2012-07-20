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
        radius = self.contentSize.height * 0.445;
        center = ccp(self.contentSize.width / 2,
                     self.contentSize.height / 2);
    }
    return self;
}

-(void)blinkAtAngle:(CGFloat)angle {
    CCSprite *light = [CCSprite spriteWithSpriteFrameName:@"blink.png"];
    light.anchorPoint = ccp(0.0, 0.5);
    light.color = ccYELLOW;

    float blinkRadius = radius - 0.5 * light.contentSize.width;
    
    // Limit angle to graphic subdivisions?
//    CGFloat miss = fmodf(angle, 15.0f);
//    angle -= miss;
//    angle += 7.5;

    light.rotation = angle;
    angle = CC_DEGREES_TO_RADIANS(angle);
    light.position = ccp(center.x + blinkRadius * cosf(angle),
                         center.y - blinkRadius * sinf(angle));

    [self addChild:light z:100];
    id fadeOut = [CCFadeOut actionWithDuration:0.5 + (float)rand()/((float)RAND_MAX)];
    id scaleOut = [CCScaleTo actionWithDuration:0.5 + (float)rand()/((float)RAND_MAX) scaleX:0.0 scaleY:0.7];
    id remove = [RemoveFromParentAction action];
    id seq = [CCSequence actions:scaleOut, remove, nil];
    [light runAction:seq];

    // Obfuscation!  What is it good for?
    angle += rand() % 2 ? M_PI / 12.0 : -1 * M_PI / 12.0;
    CCSprite *light2 = [CCSprite spriteWithSpriteFrameName:@"blink.png"];
    light2.anchorPoint = ccp(0.0, 0.5);
    light2.color = ccYELLOW;
    light2.position = ccp(center.x + blinkRadius * cosf(angle),
                          center.y - blinkRadius * sinf(angle));
    light2.rotation = CC_RADIANS_TO_DEGREES(angle);
    [self addChild:light2 z:100];
    fadeOut = [CCFadeOut actionWithDuration:0.5 + (float)rand()/((float)RAND_MAX)];
    scaleOut = [CCScaleTo actionWithDuration:0.5 + (float)rand()/((float)RAND_MAX) scaleX:0.0 scaleY:0.7];
    remove = [RemoveFromParentAction action];
    seq = [CCSequence actions:scaleOut, remove, nil];
    [light2 runAction:seq];
}

@end
