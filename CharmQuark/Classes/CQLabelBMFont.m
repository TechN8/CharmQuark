//
//  CQLabelBMFont.m
//  CharmQuark
//
//  Created by Nathan Babb on 8/27/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "CQLabelBMFont.h"


// This class is a pixel - aligned extension of CCLabelBMFont.  

@implementation CQLabelBMFont

- (void) fixPosition {
    
    CGSize dim = self.texture.contentSize;    
    
    [super setPosition:intendedPosition_];
    if (scaleX_ < 0.3 || scaleY_ < 0.3) return;
    
    // compute world (= screen) coordinate of top left position of label  
    CGPoint worldSpaceTopleft = [self convertToWorldSpace: ccp(0,dim.height)];
    
    // align origin on a pixel boundary on screen coordinates
    worldSpaceTopleft.x = roundf(worldSpaceTopleft.x * CC_CONTENT_SCALE_FACTOR()) / CC_CONTENT_SCALE_FACTOR();
    worldSpaceTopleft.y = roundf(worldSpaceTopleft.y * CC_CONTENT_SCALE_FACTOR()) / CC_CONTENT_SCALE_FACTOR();
    
    // transform back into node space
    CGPoint nodeSpaceTopleft = [self convertToNodeSpace:worldSpaceTopleft];
    
    // adjust position by the computed delta
    CGPoint delta = ccpSub(nodeSpaceTopleft, ccp(0,dim.height));
    CGPoint newPos = ccpAdd(position_, delta);
    
    // finally set the position data
    [super setPosition:newPos];      
}

// capture modification calls to adjust position
- (void)onEnter {
    [self fixPosition];
    [super onEnter];
}

- (void)setParent:(CCNode *)parent {
    [super setParent:parent];
    [self fixPosition];
}

- (void)setString:(NSString *)str {
    [super setString:str];
    [self fixPosition];
}

- (void)setPosition:(CGPoint)position {
    intendedPosition_ = position;
    [self fixPosition];
}

-(void)setRotation:(float)rotation {
    [super setRotation:rotation];
    [self fixPosition];
}

@end
