//
//  Clock.m
//  CharmQuark
//
//  Created by Nathan Babb on 7/16/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "Clock.h"

/*
 r = 1/2 height of LHCMap.png
 Create CW and CCW nodes.
 Attach Sprites to CW and CCW at 0, r
 Rotate CW and CCW in oposite directions.
 */

#define kcwStartAngle   -32.0f
#define kcwEndAngle     270.0f
#define kacwStartAngle  32.0f
#define kacwEndAngle    -270.0f

@implementation Clock

-(void)setTime:(float)time {
    // Time is between 0 and 1;
    [clockwise setRotation:kcwStartAngle + (kcwEndAngle - kcwStartAngle) * time];
    [antiClockwise setRotation:kacwStartAngle + (kacwEndAngle - kacwStartAngle) * time];
}

-(void)setColor:(ParticleColors)color {
    CCSpriteFrame *displayFrame = nil;
    switch (color) {
        case kParticleRed:
            displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"red-small.png"];
            break;
        case kParticleGreen:
            displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"green-small.png"];
            break;
        case kParticleIndigo:
            displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"blue-small.png"];
            break;
        case kParticleBlue:
            displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"antired-small.png"];
            break;
        case kParticleViolet:
            displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"antigreen-small.png"];
            break;
        case kParticleAntiBlue:
            displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"antiblue-small.png"];
            break;
        default:
            displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"white-small.png"];
            break;
    }
    [colorPacket setDisplayFrame:displayFrame];
}

#pragma mark - NSObject

-(id)init {
    self = [super init];
    if (self) {
        // Load background LHCMap.png
        lhcMap = [CCSprite spriteWithSpriteFrameName:@"LHCMap.png"];
        whitePacket = [CCSprite spriteWithSpriteFrameName:@"white-small.png"];
        colorPacket = [CCSprite spriteWithSpriteFrameName:@"antired-small.png"];
        
        [lhcMap setPosition:ccp(0,0)];
        [self addChild:lhcMap z:0];
        
        CGFloat radius = lhcMap.contentSize.height / 2.0 - whitePacket.contentSize.height / 4.0;
        CGPoint center = ccp(lhcMap.contentSize.width / 2.0 - radius - whitePacket.contentSize.height / 3.0, 0);
        clockwise = [CCNode node];
        [clockwise setRotation:kcwStartAngle];
        [clockwise setPosition:center];
        [self addChild:clockwise z:10];
        
        [colorPacket setPosition:ccp(0, radius)];
        
        [clockwise addChild:colorPacket z:0];
        
        antiClockwise = [CCNode node];
        [antiClockwise setRotation:kacwStartAngle];
        [antiClockwise setPosition:center];
        [self addChild:antiClockwise z:20];
        [whitePacket setPosition:ccp(0, -1*radius)];
        [antiClockwise addChild:whitePacket z:0];
    }
    return self;
}

@end
