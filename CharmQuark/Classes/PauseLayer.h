//
//  PauseLayer.h
//  CharmQuark
//
//  Created by Nathan Babb on 7/11/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DialogNode.h"

@interface PauseLayer : DialogNode {
    CCMenuItemToggle *musicToggle;
    CCMenuItemToggle *soundToggle;
}

@end
