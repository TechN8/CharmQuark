//
//  NotificationLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 8/22/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "NotificationLayer.h"
#import "Constants.h"
#import "RemoveFromParentAction.h"

@implementation NotificationLayer

-(void) addChild:(CCNode *)node {
    [super addChild:node];
    
    // Position off screen.
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    node.anchorPoint = ccp(0.5, 1.0);
    node.position = ccp(winSize.width * 0.5, 0.0);
    
    // Add to queue.
    [notificationQueue addObject:node];
}

-(void) scrollNext {
    if (notificationQueue.count > 0) {
        CCNode *next = [notificationQueue objectAtIndex:0];
        [notificationQueue removeObject:next];
        
        CGPoint oldPos = next.position;
        id moveIn = [CCMoveTo actionWithDuration:kPopupSpeed
                                      position:ccp(next.position.x,
                                                   next.contentSize.height)];
        id delay = [CCDelayTime actionWithDuration:1.5];
        id moveOut = [CCMoveTo actionWithDuration:kPopupSpeed
                                         position:oldPos];
        id remove = [RemoveFromParentAction action];
        id seq = [CCSequence actions:moveIn, delay, moveOut, remove, nil];
        [next runAction:seq];
    }
}

#pragma mark - CCNode

-(void)onEnter {
    [super onEnter];    
    
    [self schedule:@selector(scrollNext) interval:2.0 * kPopupSpeed + 1.0];
}

-(void)onExit {
    [super onExit];
    
    [self unscheduleAllSelectors];
}

#pragma mark - NSObject

    
    
-(id)init {
    self = [super init];
    if (self) {
        notificationQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)dealloc {
    [super dealloc];
    [notificationQueue release];
}

@end
