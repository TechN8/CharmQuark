//
//  CQMenuItemFont.m
//  CharmQuark
//
//  Created by Nathan Babb on 8/21/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "CQMenuItemFont.h"
#import "Constants.h"

@implementation CQMenuItemFont

-(void) selected
{
	if(_isEnabled) {
        _isSelected = YES;
        originalColor = self.color;
        self.color = kColorButtonSelected;
	}
}

-(void) unselected
{
	if(_isEnabled) {
        _isSelected = NO;
        self.color = originalColor;
	}
}


@end
