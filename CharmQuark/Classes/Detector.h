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
//    CCSpriteBatchNode *batchNode;
    CCRenderTexture *trackTexture;
};

-(void)animateAtAngle:(CGFloat)angle;

-(void)gameOverAtAngle:(CGFloat)angle;

@end

//@interface Track : NSObject {
//    CGFloat angle;
//    CGFloat distance;
//    ccTime ttl;
//}
//
//@property CGFloat angle;
//@property CGFloat distance;
//@property ccTime ttl;
//
//+(id)trackWithAngle:(CGFloat)angle distance:(CGFloat)distance ttl:(ccTime)ttl;
//@end