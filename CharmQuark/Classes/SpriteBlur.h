//
//  SpriteBlur.h
//  CharmQuark
//
//  Created by Nathan Babb on 7/12/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SpriteBlur : CCSprite
{
	CGPoint blur_;
	GLfloat	sub_[4];
    
	GLuint	blurLocation;
	GLuint	subLocation;
}

-(void) setBlurSize:(CGFloat)f;
@end

