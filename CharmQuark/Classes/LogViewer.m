//
//  LogViewer.m
//  CharmQuark
//
//  Created by Nathan Babb on 7/23/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "LogViewer.h"
#import "RemoveFromParentAction.h"
#import "Constants.h"

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
        [oldMessage removeFromParentAndCleanup:YES];
        [messages removeObject:oldMessage];
    }
}

-(void)addMessage:(NSString *)message color:(ccColor3B)color {
    // Add new message
    CCLabelBMFont *newMessage = [CCLabelBMFont labelWithString:message fntFile:@"score.fnt"];
    newMessage.color = color;
    newMessage.anchorPoint = ccp(0.5, 0.0);
    newMessage.position = ccp(0, [[messages lastObject] position].y - lineHeight);
    
    CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:1.0];
    CCEaseExponentialIn *fadeEase = [CCEaseExponentialIn actionWithAction:fadeOut];
    CCScaleTo *scaleTo = [CCScaleTo actionWithDuration:0.5 scale:1.3];
    CCSequence *seq = [CCSequence actions:scaleTo, fadeEase, nil];
    [newMessage runAction:seq];
    
    [self addChild:newMessage z:0];
    [messages addObject:newMessage];
    [self scheduleOnce:@selector(scrollMessages) delay:0.1];
}


#pragma mark - NSObject

-(id)init {
    self = [super init];
    if (self) {
        messages = [[[NSMutableArray alloc] init] retain];
        CCLabelBMFont *newMessage = [CCLabelBMFont labelWithString:@"> tail EventLog" fntFile:@"score.fnt"];
        lineHeight = newMessage.contentSize.height;
        [newMessage cleanup];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            maxEntries = kMaxLogEntriesiPad;
        } else {
            maxEntries = kMaxLogEntriesiPhone;
        }
    }
    return self;
}

-(void)dealloc {
    [super dealloc];
    [messages release];
}

@end
