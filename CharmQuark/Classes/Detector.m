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
//    angle = 7.5 + 15;
    CCSprite *light = [CCSprite spriteWithSpriteFrameName:@"blink.png"];
    
    CGFloat miss = fmodf(angle, 15.0f);
    angle -= miss;
    angle += 7.5;
//    if (miss < 7.5) {
//        angle += 15 - miss;
//    } else {
//        angle -= miss;
//    }
    light.rotation = 90 - angle;

    // TODO: Limit angle to graphic subdivisions.
    angle = CC_DEGREES_TO_RADIANS(angle);
    light.position = ccp(center.x + radius * cosf(angle),
                         center.y + radius * sinf(angle));

    [self addChild:light z:100];
    id fadeIn = [CCFadeIn actionWithDuration:0.5f];
    id fadeOut = [CCFadeOut actionWithDuration:1.0f];
    id remove = [RemoveFromParentAction action];
    id seq = [CCSequence actions:fadeIn, fadeOut, remove, nil];
    [light runAction:seq];
}

@end
