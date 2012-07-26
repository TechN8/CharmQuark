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
//        [self addChild:batchNode z:0];
        
        int radius = self.contentSize.height / 2;
        blinkRadius = radius * 0.88;
        graphRadius = radius * 0.52;
        trackRadius = radius * 1.5;

//        tracks = [[NSMutableArray arrayWithCapacity:20] retain];
//        
//        trackTexture = [CCRenderTexture renderTextureWithWidth:1024 height:1024];
//        trackTexture.position = center;
//        [self addChild:trackTexture];
//        trackSprite = [[CCSprite spriteWithSpriteFrameName:@"track.png"] retain];
//        trackSprite.opacity = 0;
//        [trackTexture addChild:trackSprite];
    }
    return self;
}

-(void)onEnter {
    batchNode = (CCSpriteBatchNode*)[self.parent getChildByTag:kTagUIBatchNode];
    center = self.position;
}

-(void)dealloc {
    [super dealloc];
//    [trackSprite cleanup];
//    [trackSprite release];
//    [tracks release];
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

-(void)trackAtAngle:(CGFloat)angle {
    float a1, a2;
    float r1, r2;
    
    CGPoint p1 = center;
    CGPoint p2, p3;
    r1 = 100 + (float)rand()/(float)RAND_MAX * 50;
    r2 = 100 + (float)rand()/(float)RAND_MAX * 100;
    a1 = (-1 * M_PI_4) + ((float)rand()/(float)RAND_MAX * M_PI_2);
    a2 = (-1 * M_PI_2) + ((float)rand()/(float)RAND_MAX * M_PI);
    p2 = ccp(p1.x + r1 * cosf(angle+a1),     // Control1
             p1.y - r2 * sinf(angle+a1));
    p3 = ccp(p1.x + r2 * cosf(angle+a2),     // Control2
             p1.y - r2 * sinf(angle+a2));
    FRCurve *curve = [[FRCurve curveFromType:kFRCurveBezier order:kFRCurveQuadratic segments:64]retain];
    [curve setWidth:1.0f];
    [curve setShowControlPoints:NO];
    [curve setPoint:p1 atIndex:0];
    [curve setPoint:p2 atIndex:1];
    [curve setPoint:p3 atIndex:2];
    [curve setColor:ccc3(0, 255, 255)];
    [curve setOpacity:128];
    [curve invalidate];
    [self.parent addChild:curve z:kZUIElements];
    id fadeout = [CCFadeOut actionWithDuration:(float)rand()/RAND_MAX];
    id remove = [RemoveFromParentAction action];
    id seq = [CCSequence actions:fadeout, remove, nil];
    [curve runAction:seq];
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


-(void)drawTracks {
    CGPoint texCenter = ccp(512,512);
    [trackTexture begin];
    trackSprite.opacity = 255;
    trackSprite.position = texCenter;
//    [trackSprite visit];
    for (Track *track in tracks) {
        CGFloat angle = track.angle;
        CGFloat distance = track.distance;
        CGPoint pos = ccp(texCenter.x + distance * cosf(angle),
                          texCenter.y - distance * sinf(angle));
        ccDrawLine(texCenter, pos);
//        for(int i = 0; i < distance; i+=3) {
//            CGPoint pos = ccp(texCenter.x + i * cosf(angle),
//                              texCenter.y - i * sinf(angle));
//            trackSprite.position = pos;
//            [trackSprite visit];
//        }
    }
    trackSprite.opacity = 0;
    [trackTexture end];
}

-(void)explosionAtAngle:(CGFloat)angle {
    CCParticleSystemQuad *emitter = [CCParticleSystemQuad node];
    emitter.totalParticles = 30;
    CCSprite *spr = [CCSprite spriteWithSpriteFrameName:@"track.png"];
    [emitter setTexture:spr.texture withRect:spr.textureRect];
    emitter.duration = 0.07f;
    emitter.emitterMode = kCCParticleModeGravity;
    emitter.gravity = ccp(0,0);
    // Gravity Mode: speed of particles
    emitter.speed = 1000;
    emitter.speedVar = 400;
    // Gravity Mode: radial
    emitter.radialAccel = 0;
    emitter.radialAccelVar = 0;
    // Gravity Mode: tagential
    emitter.tangentialAccel = 0;
    emitter.tangentialAccelVar = 1000;
    //Angle is OpenGL like and goes CCW.
    //emitter.angle = (float)rand()/((float)RAND_MAX/360);
    emitter.rotation = CC_RADIANS_TO_DEGREES(angle); // (float)rand()/((float)RAND_MAX/360);
    emitter.angle = 0;
    emitter.angleVar = 20;
    //emitter.emissionRate = 10.0f;
    emitter.emissionRate = emitter.totalParticles / emitter.duration;
    emitter.life = 0.5f;
    emitter.lifeVar = 0.5f;
    emitter.positionType = kCCPositionTypeRelative;
    emitter.position = self.position;
    emitter.posVar = CGPointZero;
    // size, in pixels
    emitter.startSize = 11;
    emitter.startSizeVar = 10;
    emitter.endSize = 8;
    emitter.blendAdditive = NO;
    emitter.emissionRate = emitter.totalParticles/emitter.duration;
    
    //emitter.startColor = ccc4FFromccc3B(self.color);
    emitter.startColor = ccc4f(1.0, 1.0, 1.0, 1.0);
    emitter.startColorVar = ccc4f(0.0f, 0.0f, 0.0f, 0.0f);
    emitter.endColor = ccc4f(1.0, 1.0, 1.0, 1.0);// ccc4f(0.0f, 0.0f, 0.0f, 0.0f);
    emitter.endColorVar = ccc4f(0.0f, 0.0f, 0.0f, 1.0f);
    
    emitter.autoRemoveOnFinish=YES;
    //    CCNode *parent = self.parent;
    //    if ([parent isKindOfClass:[CCSpriteBatchNode class]]) {
    //        parent = [parent parent];
    //    }
    emitter.position = self.position;
    [self.parent addChild:emitter z:kZParticles];
}

-(void)animateAtAngle:(CGFloat)angle {
    // Work in radians.
    angle = CC_DEGREES_TO_RADIANS(angle);
    
    // Draw three blinks.
    float blinkAngle = angle - M_PI / 12;
    for (int i = 0; i < 3; i++) {
        [self blinkAtAngle:blinkAngle];
//        [self trackAtAngle:blinkAngle];
        blinkAngle += M_PI / 12;
    }
    
    // Draw 5 graphs.
    float graphAngle = angle - M_PI / 12;
    for (int i = 0; i < 5; i++) {
        [self graphAtAngle:graphAngle];
//        [self trackAtAngle:graphAngle];
        graphAngle += M_PI / 24;
    }

//    [self explosionAtAngle: angle];
    
    // Draw the tracks
//    [self scheduleOnce:@selector(drawTracks) delay:0];
}

@end

@implementation Track

@synthesize angle, distance, ttl;

+(id)trackWithAngle:(CGFloat)angle distance:(CGFloat)distance ttl:(ccTime)ttl {
    Track *track = [[[self alloc] init] autorelease];
    track->angle = angle;
    track->distance = distance;
    track->ttl = ttl;
    return track;
}

@end