//
//  ModalMenuLayer.h
//  CharmQuark
//
//  Created by Nathan Babb on 7/12/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Scale9Sprite.h"

@interface DialogNode : CCNode<CCTouchOneByOneDelegate> {
    Scale9Sprite *windowSprite;
    CCSprite *arrow;
}

@property (readonly) CCSprite *arrow;

-(void)initUI;

-(void)setBackgroundNode:(CCNode*)node;

-(void)addCloseArrow;

-(BOOL) isButtonTouch: (UITouch *)touch;

@end
