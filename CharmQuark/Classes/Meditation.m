//
//  Meditation.m
//  CharmQuark
//
//  Created by Nathan Babb on 8/22/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "Meditation.h"
#import "GCHelper.h"

@implementation Meditation

-(void) end:(Particle *)particle {
    [super end:particle];

    // Award achievement.
    GCHelper *gc = [GCHelper sharedInstance];
    [gc reportAchievement:kAchievementMeditation percentComplete:100.0];
}

-(void) resetGame {
    [super resetGame];
    
    dropFrequency = kDropTimeInit;
    timeRemaining = dropFrequency;
}

@end
