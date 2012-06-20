//
//  AppDelegate.h
//  CharmQuark
//
//  Created by Nathan Babb on 6/18/12.
//  Copyright Aether Theory, LLC 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
