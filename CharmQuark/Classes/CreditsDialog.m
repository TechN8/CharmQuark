//
//  CreditsDialog.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/18/12.
//  Copyright (c) 2012 Aether Theory, LLC. All rights reserved.
//

#import "CreditsDialog.h"
#import "RemoveFromParentAction.h"
#import "GameManager.h"
#import "Constants.h"
#import "ClipNode.h"

@implementation CreditsDialog

- (void) resumeParent {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGPoint offScreen = ccp(0, 2 * winSize.height);
    CCSequence *seq = [CCSequence actions:[CCMoveTo actionWithDuration:0.5f position:offScreen], 
                       [RemoveFromParentAction action],
                       nil];
    [self runAction:seq];
}

#pragma mark - ModalMenuLayer

-(void)initUI {
    // Clipping node.  
    ClipNode *clip = [ClipNode node];
    CGSize innerWinSize = windowSprite.contentSize;
    innerWinSize.height -= windowSprite.top.contentSize.height;
    clip.contentSize = innerWinSize;
    clip.anchorPoint = ccp(0.5, 0.5);
    clip.position = ccp(windowSprite.position.x,
                        windowSprite.position.y - windowSprite.top.contentSize.height * 0.195);
    [self addChild:clip];
    
    // This node will be used for the scrolling.
    CGFloat scrollHeight = 0;
    CCNode *scroller = [CCNode node];
    
    NSString *credits = @"These are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\nThese are the credits.\n";
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:credits
                                                  fntFile:@"score.fnt"];
    [scroller addChild:label];
    scrollHeight += label.contentSize.height;

    [clip addChild:scroller];
    
    // Roll the credits.
    CGPoint startPos = ccp(clip.contentSize.width / 2,
                           -0.5 * scrollHeight);
    CGPoint endPos = ccp(clip.contentSize.width / 2,
                         clip.contentSize.height + scrollHeight / 2);
    id moveTo = [CCMoveTo actionWithDuration:60.0 position:endPos];
    id close = [CCCallFunc actionWithTarget:self selector:@selector(resumeParent)];
    scroller.position = startPos;
    [scroller runAction:[CCSequence actions:moveTo, close, nil]];
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self resumeParent];
}

@end
