//
//  OptionsScene.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/18/12.
//  Copyright (c) 2012 Aether Theory, LLC. All rights reserved.
//

#import "OptionsScene.h"

@implementation OptionsScene
- (id)init
{
    self = [super init];
    if (self) {
        optionsLayer = [OptionsLayer node];
        [self addChild:optionsLayer];
    }
    return self;
}
@end
