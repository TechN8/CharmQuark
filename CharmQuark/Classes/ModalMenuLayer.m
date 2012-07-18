//
//  ModalMenuLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 7/12/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "ModalMenuLayer.h"


@implementation ModalMenuLayer

-(void)initUI {
    NSAssert(NO, @"Must override initMenus for ModalMenuLayer.");
}

-(void)setBackgroundNode:(CCNode*)node {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    node.position = ccp(winSize.width * 0.5f, winSize.height * 0.5f);
    [self addChild:node z:0];
}

#pragma mark - CCTargetedTouchDelegate

// This will consume any touches to this layer.
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return YES;
}

#pragma mark - CCLayer

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:kCCMenuHandlerPriority swallowsTouches:YES];
}

#pragma mark - CCNode

// Set the opacity of all of our children that support it
-(void) setOpacity: (GLubyte) opacity
{
    [super setOpacity:opacity];
    for( CCNode *node in [self children] )
    {
        if( [node conformsToProtocol:@protocol( CCRGBAProtocol)] )
        {
            [(id<CCRGBAProtocol>) node setOpacity: opacity];
        }
        // Handle children that don't support opacity
        else
        {
            node.visible = ( opacity != 0 );
        }
    }
}

-(void)onEnter {
    [super onEnter];
    [self initUI];
}

#pragma mark - NSObject

-(id)initWithColor:(ccColor4B)color {
    self = [super initWithColor:color];
    if (self) {
        self.isTouchEnabled = YES;
    }
    return self;
}

@end
