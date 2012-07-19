//
//  Clock.m
//  CharmQuark
//
//  Created by Nathan Babb on 7/16/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "LHCMap.h"

/*
 r = 1/2 height of LHCMap.png
 Create CW and CCW nodes.
 Attach Sprites to CW and CCW at 0, r
 Rotate CW and CCW in oposite directions.
 */

#define kcwStartAngle   1 * M_PI
#define kcwEndAngle     -1 * M_PI
#define kacwStartAngle  -1 * M_PI
#define kacwEndAngle    1 * M_PI

@implementation LHCMap

-(void)setTime:(float)time {
    // Time is between 0 and 1;
    clockwise = kcwStartAngle - (kcwStartAngle - kcwEndAngle) * time;
    antiClockwise = kacwStartAngle - (kacwStartAngle - kacwEndAngle) * time;
    CGPoint clockPos = ccp(center.x + radius * cosf(clockwise),
                           center.y + radius * sinf(clockwise));
    [colorPacket setPosition:clockPos];
    
    CGPoint antiClockPos = ccp(center.x + radius * cosf(antiClockwise),
                               center.y + radius * sinf(antiClockwise));
    [whitePacket setPosition:antiClockPos];
    
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
        case kParticleBlue:
            displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"blue-small.png"];
            break;
        case kParticleAntiRed:
            displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"antired-small.png"];
            break;
        case kParticleAntiGreen:
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

-(void)onEnter {
    CGPoint clockPos = ccp(center.x + radius * cosf(clockwise),
                           center.y + radius * sinf(clockwise));
    [colorPacket setPosition:clockPos];
    [self addChild:colorPacket z:10];
    
    
    CGPoint antiClockPos = ccp(center.x + radius * cosf(antiClockwise),
                               center.y + radius * sinf(antiClockwise));
    [whitePacket setPosition:antiClockPos];
    [self addChild:whitePacket z:10];
}

#pragma mark - NSObject

-(id)init {
    // Load background LHCMap.png
    self = [super initWithSpriteFrameName:@"lhcmap.png"];
    if (self) {
        
        whitePacket = [CCSprite spriteWithSpriteFrameName:@"white-small.png"];
        colorPacket = [CCSprite spriteWithSpriteFrameName:@"white-small.png"];
        
        radius = self.contentSize.height / 2.0 - whitePacket.contentSize.height / 4.0;
        center = ccp(self.contentSize.width - self.contentSize.height / 2,
                     self.contentSize.height / 2);
        
        clockwise = kcwStartAngle;
        antiClockwise = kacwStartAngle;
    }    
    return self;
}

@end
