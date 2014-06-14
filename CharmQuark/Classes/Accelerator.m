//
//  Accelerator.m
//  CharmQuark
//
//  Created by Nathan Babb on 8/22/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "Accelerator.h"
#import "GCHelper.h"
#import "CQLabelBMFont.h"

@implementation Accelerator

-(void) end:(Particle *)particle {
    [super end:particle];
    
    // Award score achievements
    GCHelper *gc = [GCHelper sharedInstance];
    [gc reportAchievement:kAchievementAccelerator percentComplete:100.0];   
    if (score >= 100000) {
        [gc reportAchievement:kAchievementAccelerator100K percentComplete:100.0];
    }
    
}

-(void) gameStep {
    [super gameStep];
    
    // Check for gameover or drop conditions.
    if (timeRemaining <= 0) {
        [self launch];
    }
}

-(void) initUI {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    [super initUI];
    
    CGPoint levelPosition = ccp(winSize.width * 0.5f, winSize.height * 0.95f);
    levelLabel = [CQLabelBMFont labelWithString:@"Level 1" fntFile:@"score.fnt"];
    levelLabel.position = levelPosition;
    levelLabel.color = kColorUI;
    [self addChild:levelLabel z:kZUIElements];
    
}

-(BOOL) launch {
    if ([super launch]) {
        timeRemaining = dropFrequency;   
        return YES;
    }
    return NO;
}

-(void) resetGame {
    [super resetGame];
    
    dropFrequency = kDropTimeInit;
    timeRemaining = dropFrequency;
    [levelLabel setString:@"Level 1"];
}

-(BOOL) updateLevel {
    if ([super updateLevel]) {
        // Update level
        level++;
        dropFrequency -= kDropTimeStep;
        if (dropFrequency <= kDropTimeMin) {
            dropFrequency = kDropTimeMin;
        }
        [levelLabel setString:[NSString stringWithFormat:@"Level %ld", (long)level]];
        [logViewer addMessage:[NSString stringWithFormat:@"Level %ld!", (long)level]
                        color:kColorLevelUp];
        return YES;
    }
    return NO;
}

@end
