//
//  LogViewer.h
//  CharmQuark
//
//  Created by Nathan Babb on 7/23/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define kMaxLogEntriesiPhone  4
#define kMaxLogEntriesiPad    6

@interface LogViewer : CCNode {
    NSMutableArray *messages;
    NSInteger maxEntries;
    CGFloat lineHeight;
}

-(void)addMessage:(NSString*)message;

@end
