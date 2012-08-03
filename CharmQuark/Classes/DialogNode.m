//
//  ModalMenuLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 7/12/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "DialogNode.h"

@implementation DialogNode

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

#pragma mark - Touch handling

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:kCCMenuHandlerPriority swallowsTouches:YES];
}

- (void) unregisterWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];   
}

#pragma mark - CCNode

// Set the opacity of all of our children that support it
-(void) setOpacity: (GLubyte) opacity
{
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
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    self.contentSize = winSize;
    
    windowSprite = [[[Scale9Sprite alloc] initWithFile:@"window.png" 
                                                ratioX:0.49 ratioY:0.49] autorelease];;
    [windowSprite setContentSize:CGSizeMake(winSize.width * .75, winSize.height * .75)];
    [windowSprite setPosition:ccp(winSize.width / 2, winSize.height / 2)];
    [self addChild:windowSprite];
    
    [self registerWithTouchDispatcher];

    [self initUI];
}

-(void)onExit {
    [self unregisterWithTouchDispatcher];
    [super onExit];
}

#pragma mark - NSObject

-(void)dealloc {
    [super dealloc];
}

@end
