//
//  AppDelegate.h
//  CharmQuark
//
//  Created by Nathan Babb on 6/18/12.
//  Copyright Aether Theory, LLC 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
