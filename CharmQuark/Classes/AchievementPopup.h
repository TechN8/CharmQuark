//
//  AchievementPopup.h
//  CharmQuark
//
//  Created by Nathan Babb on 8/22/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <GameKit/GameKit.h>

@interface AchievementPopup : CCNode {
    
}

+(AchievementPopup*)popupWithDescription: (GKAchievementDescription *)achievement
                                   image: (UIImage *)image;

@end
