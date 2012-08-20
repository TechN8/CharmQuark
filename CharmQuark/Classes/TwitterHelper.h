//
//  TwitterHelper.h
//  CharmQuark
//
//  Created by Nathan Babb on 8/20/12.
//  Copyright (c) 2012 Aether Theory, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterHelper : NSObject

+(TwitterHelper*) sharedInstance;

-(BOOL) isTwitterAvailable;

-(void) composeTweet: (NSString *)text;

@end
