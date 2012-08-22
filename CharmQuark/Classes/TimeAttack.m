//
//  TimeAttack.m
//  CharmQuark
//
//  Created by Nathan Babb on 8/22/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "TimeAttack.h"
#import "GCHelper.h"

@implementation TimeAttack

-(void) end:(Particle *)particle {
    [super end:particle];
    
    // Award score achievements
    GCHelper *gc = [GCHelper sharedInstance];
    [gc reportAchievement:kAchievementTimeAttack percentComplete:100.0];   
    if (score >= 100000) {
        [gc reportAchievement:kAchievementTimeAttack100K percentComplete:100.0];
    }
}

-(void) gameStep {
    [super gameStep]; 
    
    // Check for gameover or drop conditions.
    if (timeRemaining <= 0) {
        timeRemaining = 0;
        [super end:nil]; // Game over.
    }
    
    // Update time attack countdown.
    [timerLabel setString:[NSString stringWithFormat:@"%01d:%02d.%02d", 
                           (int)timeRemaining / 60,
                           (int)(fmodf(timeRemaining, 60)),
                           (int)(fmodf(timeRemaining, 1.0) * 100)]];
}

-(void) initUI {
    [super initUI];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // Add timer.
    CGPoint timerPosition = ccp(winSize.width * 0.5f, winSize.height * 0.95f);
    timerLabel= [CCLabelBMFont labelWithString:@"2:00.00" fntFile:@"score.fnt"];
    timerLabel.position = timerPosition;
    timerLabel.color = kColorUI;
    [self addChild:timerLabel z:kZUIElements];
}

-(void) resetGame {
    [super resetGame];
    
    dropFrequency = kTimeLimit;
    timeRemaining = dropFrequency;
    [timerLabel setString:[NSString stringWithFormat:@"%01d:%02d.%02d", 
                           (int)timeRemaining / 60,
                           (int)(fmodf(timeRemaining, 60)),
                           (int)(fmodf(timeRemaining, 1.0) * 100)]];
}

-(BOOL) updateLevel {
    if ([super updateLevel]) {
        // Add time
        timeRemaining += kTimeAttackAdd;
        [logViewer addMessage:[NSString stringWithFormat:@"+%d Seconds!", (int)kTimeAttackAdd]
                        color:kColorTimeAdd];
        return YES;
    }
    return NO;
}


@end
