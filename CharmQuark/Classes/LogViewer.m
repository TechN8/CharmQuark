//
//  LogViewer.m
//  CharmQuark
//
//  Created by Nathan Babb on 7/23/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "LogViewer.h"
#import "RemoveFromParentAction.h"

@implementation LogViewer

-(void)scrollMessages {
    CGPoint top = ccp(0, lineHeight * messages.count);
    
    // Scroll messages.
    for (CCLabelBMFont *message in messages) {
        id moveTo = [CCMoveTo actionWithDuration:0.5 position:top];
        top.y = top.y - lineHeight;
        [message runAction:moveTo];
    }
    
    // Remove overflow
    while (messages.count > maxEntries) {
        CCLabelBMFont *oldMessage = [messages objectAtIndex:0];
//        id fadeout = [CCFadeOut actionWithDuration:0.5];
//        id remove = [RemoveFromParentAction action];
//        [oldMessage runAction:[CCSequence actions:fadeout, remove, nil]];
        [oldMessage removeFromParentAndCleanup:YES];
        [messages removeObject:oldMessage];
    }
}

-(void)addMessage:(NSString *)message {
    // Add new message
    CCLabelBMFont *newMessage = [CCLabelBMFont labelWithString:message fntFile:@"score.fnt"];
    newMessage.color = ccc3(200, 255, 200);
    newMessage.anchorPoint = ccp(0.5, 0.0);
    newMessage.position = ccp(0, [[messages lastObject] position].y - lineHeight);
    
    CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:2.0];
    [newMessage runAction:[CCEaseExponentialIn actionWithAction:fadeOut]];
    
    [self addChild:newMessage z:0];
    [messages addObject:newMessage];
    [self scheduleOnce:@selector(scrollMessages) delay:0.1];
}

#pragma mark - CCNode

-(void)onExit {
    [self unscheduleAllSelectors];
    [super onExit];
}

-(void)onEnter {
    [super onEnter];
    
//    [self schedule:@selector(scrollMessages) interval:0.25];
}

#pragma mark - NSObject

-(id)init {
    self = [super init];
    if (self) {
        messages = [[[NSMutableArray alloc] init] retain];
        CCLabelBMFont *newMessage = [CCLabelBMFont labelWithString:@"> tail EventLog" fntFile:@"score.fnt"];
//        newMessage.color = ccc3(200, 255, 200);
//        [messages addObject:newMessage];
        lineHeight = newMessage.contentSize.height;
        [newMessage cleanup];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            maxEntries = kMaxLogEntriesiPad;
        } else {
            maxEntries = kMaxLogEntriesiPhone;
        }
//        newMessage.anchorPoint = ccp(0, 1);
//        newMessage.position = ccp(0,lineHeight);
//        [self addChild:newMessage z:0];
    }
    return self;
}

-(void)dealloc {
    [super dealloc];
    [messages release];
}

@end
