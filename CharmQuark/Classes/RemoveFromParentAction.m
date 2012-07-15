//
//  RemoveFromParentAction.m
//  CharmQuark
//
//  Created by Nathan Babb on 7/15/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "RemoveFromParentAction.h"

@implementation RemoveFromParentAction

+(id)action {
	return [[[self alloc] init] autorelease];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[[aTarget parent] removeChild:aTarget cleanup:YES];
}

@end