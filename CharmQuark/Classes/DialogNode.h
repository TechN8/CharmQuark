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

@interface DialogNode : CCNode<CCTargetedTouchDelegate> {
    Scale9Sprite *windowSprite;
}

-(void)initUI;

-(void)setBackgroundNode:(CCNode*)node;

@end
