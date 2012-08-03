//
//  ClipNode.m
//  CharmQuark
//
//  Created by Nathan Babb on 8/3/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "ClipNode.h"


@implementation ClipNode

#pragma mark - CCNode

-(void)visit {
    glEnable(GL_SCISSOR_TEST);
    CGPoint pos = CC_POINT_POINTS_TO_PIXELS([self.parent convertToWorldSpace:self.position]);
    CGPoint size = CC_POINT_POINTS_TO_PIXELS(ccp(self.contentSize.width, 
                                                 self.contentSize.height));
    pos.x -= self.anchorPoint.x * size.x;
    pos.y -= self.anchorPoint.y * size.y;
    glScissor(pos.x,
              pos.y,
              size.x,
              size.y);
    [super visit];
    glDisable(GL_SCISSOR_TEST);
}

@end
