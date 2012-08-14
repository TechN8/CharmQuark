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
    CGFloat blinkRadius;
    CGFloat graphRadius;
    CGFloat trackRadius;
    NSMutableArray *tracks;
    CCSprite *trackSprite;
    CCRenderTexture *trackTexture;
};

-(void)animateAtAngle:(CGFloat)angle graphColor:(ccColor3B)color;

-(void)gameOverAtAngle:(CGFloat)angle;

@end