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

-(void)setParticleColor:(ParticleColors)color {
    switch (color) {
        case kParticleRed:
            colorPacket.color = kCC3ParticleRed;
            break;
        case kParticleGreen:
            colorPacket.color = kCC3ParticleGreen;
            break;
        case kParticleBlue:
            colorPacket.color = kCC3ParticleBlue;
            break;
        case kParticleAntiRed:
            colorPacket.color = kCC3ParticleAntiRed;
            break;
        case kParticleAntiGreen:
            colorPacket.color = kCC3ParticleAntiGreen;
            break;
        case kParticleAntiBlue:
            colorPacket.color = kCC3ParticleAntiBlue;
            break;
        default:
            break;
    }
    whitePacket.color = colorPacket.color;
}

-(void)onEnter {
    [super onEnter];
    [self.parent addChild:colorPacket z:10];
    [self.parent addChild:whitePacket z:10];
    
    center = ccp(self.position.x + self.contentSize.width - self.contentSize.height / 2,
                 self.position.y);

    CGPoint clockPos = ccp(center.x + radius * cosf(clockwise),
                           center.y + radius * sinf(clockwise));
    [colorPacket setPosition:clockPos];
    
    CGPoint antiClockPos = ccp(center.x + radius * cosf(antiClockwise),
                               center.y + radius * sinf(antiClockwise));
    [whitePacket setPosition:antiClockPos];

}

#pragma mark - NSObject

-(id)init {
    // Load background LHCMap.png
    self = [super initWithSpriteFrameName:@"lhcmap.png"];
    if (self) {
        whitePacket = [[CCSprite spriteWithSpriteFrameName:@"white-small.png"] retain];
        colorPacket = [[CCSprite spriteWithSpriteFrameName:@"white-small.png"] retain];
        
        radius = self.contentSize.height / 2.0 - whitePacket.contentSize.height * 0.4;
        
        clockwise = kcwStartAngle;
        antiClockwise = kacwStartAngle;
    }    
    return self;
}

-(void)dealloc {
    [super dealloc];
    
    [whitePacket release];
    [colorPacket release];
}

@end
