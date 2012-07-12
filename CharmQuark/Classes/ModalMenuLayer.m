//
//  ModalMenuLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 7/12/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "ModalMenuLayer.h"


@implementation ModalMenuLayer

-(void)initMenus {
    NSAssert(NO, @"Must override initMenus for ModalMenuLayer.");
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

#pragma mark - NSObject

-(id)init {
    self = [super initWithColor:ccc4(200, 255, 200, 128)];
    if (self) {
        self.isTouchEnabled = YES;
        
        //TODO: Add Background
        
        [self initMenus];
    }
    return self;
}

@end
