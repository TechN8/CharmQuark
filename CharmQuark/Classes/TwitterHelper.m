//
//  TwitterHelper.m
//  CharmQuark
//
//  Created by Nathan Babb on 8/20/12.
//  Copyright (c) 2012 Aether Theory, LLC. All rights reserved.
//

#import "TwitterHelper.h"
#import "Twitter/Twitter.h"
#import "cocos2d.h"

@implementation TwitterHelper

static TwitterHelper *sharedHelper = nil;

+ (TwitterHelper *) sharedInstance {
    @synchronized([TwitterHelper class]) 
    {
        if (!sharedHelper) {
            [[self alloc] init];
        }
        return sharedHelper;
    }
    return nil;
}

-(BOOL) isTwitterAvailable {
    Class twClass = NSClassFromString(@"TWTweetComposeViewController");
    if (twClass) { // Framework not available, older iOS
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            return YES;
        }
    }
    return NO;    
}

-(void) composeTweet: (NSString *)textToShare {
    if ([self isTwitterAvailable]) {
        SLComposeViewController* twc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twc addURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/charm-quark/id551441281?ls=1&mt=8"]];
        //        [twc addImage:[UIImage imageNamed:@"Some image.png"]]
        [twc setInitialText:textToShare];
        [[CCDirector sharedDirector] presentViewController:twc 
                                                  animated:YES 
                                                completion:^{
            // Optional
        }];
        [twc release];
    }
}

#pragma mark - NSObject

+(id) alloc {
@synchronized ([TwitterHelper class])
{
    NSAssert(sharedHelper == nil, @"Attempted to allocated a \
             second instance of the TwitterHelper singleton");
    sharedHelper = [super alloc];
    return sharedHelper;
}
return nil;  
}


@end
