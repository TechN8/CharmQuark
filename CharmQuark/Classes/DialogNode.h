//
//  ModalMenuLayer.h
//  CharmQuark
//
//  Created by Nathan Babb on 7/12/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface DialogNode : CCNode<CCTargetedTouchDelegate> {
    
}

-(void)initUI;

-(void)setBackgroundNode:(CCNode*)node;

@end
