//
//  AchievementPopup.m
//  CharmQuark
//
//  Created by Nathan Babb on 8/22/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "AchievementPopup.h"
#import "Scale9Sprite.h"
#import "Constants.h"

@implementation AchievementPopup

+(AchievementPopup *)popupWithDescription:(GKAchievementDescription *)achievement {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    AchievementPopup *popup = [self node];

    CGFloat frameWidth 
    = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 13 : 7;
    
    // Image.
    UIImage *image = achievement.image; 
    if (nil == image) {
        image = [GKAchievementDescription placeholderCompletedAchievementImage];
    }
    CCTexture2D *texture = [[[CCTexture2D alloc] initWithCGImage:image.CGImage
                                                 resolutionType:kCCResolutionUnknown] 
                            autorelease];
    CCSprite *achievementSprite = [CCSprite spriteWithTexture:texture];
    achievementSprite.anchorPoint = ccp(0, 0.5);
    achievementSprite.position = ccp(frameWidth, frameWidth + achievementSprite.contentSize.height / 2);
    [popup addChild:achievementSprite z:1];
    
    // Background image.
    Scale9Sprite *windowSprite = [[[Scale9Sprite alloc] initWithFile:@"frame.png" 
                                                              ratioX:0.25 ratioY:0.25] autorelease];
    windowSprite.anchorPoint = ccp(0,0);
    windowSprite.color = kColorUI;
    [windowSprite setContentSize:CGSizeMake(winSize.width, achievementSprite.contentSize.height + 2 * frameWidth)];
    [popup addChild:windowSprite z:0];
    popup.contentSize = windowSprite.contentSize;
    
    // Text.
    NSString *text = [NSString stringWithFormat:@"%@\n%@", 
                      achievement.title, 
                      achievement.achievedDescription];
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:text
                                                  fntFile:@"score.fnt"];
    label.anchorPoint = ccp(0, 0.5);
    label.alignment = kCCTextAlignmentLeft;
    label.color = kColorUI;
    label.scale = 0.8;
    label.position = ccp(2 * frameWidth + achievementSprite.contentSize.width, 
                         popup.contentSize.height * 0.5);
    [popup addChild:label z:1];
    
    return popup;
}

@end
