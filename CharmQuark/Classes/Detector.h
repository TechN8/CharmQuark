//
//  Detector.h
//  CharmQuark
//
//  Created by Nathan Babb on 7/19/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Detector : CCSprite {
    CGPoint center;
    CGFloat radius;
}

-(void)blinkAtAngle:(CGFloat)angle;

@end
