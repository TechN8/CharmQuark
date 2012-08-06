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
    CCSequence *seq = [CCSequence actions:[CCMoveTo actionWithDuration:kPopupSpeed position:offScreen], 
                       [RemoveFromParentAction action],
                       nil];
    [self runAction:seq];
}

-(void)colorizeLabel:(CCLabelBMFont *)label {
    NSString *text = label.string;
    BOOL bold = YES;
    unichar last = 0;
    unichar lastlast = 0;
    for (int i = 0; i < text.length; i++) {
        unichar c = [text characterAtIndex:i];
        if ('\n' == c) {
            bold = last == c && lastlast == c ? YES : NO;
        } else if (bold) {
            CCSprite *sprite = (CCSprite *)[label getChildByTag:i];
            sprite.color = kScoreColor;
        }
        lastlast = last;
        last = c;
    }
    
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
    
    // This is the label with the credits in.
    NSString *fileName = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"cretits.txt"];
    NSString *credits = [NSString stringWithContentsOfFile:fileName
                                                  encoding:NSUTF8StringEncoding 
                                                     error:nil];
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:credits
                                                  fntFile:@"score.fnt"];
//    [label setWidth:windowSprite.contentSize.width - 10];
    [label setAnchorPoint:ccp(0.5, 1.0)];
    [label setAlignment:kCCTextAlignmentCenter];
    [self colorizeLabel:label];
    scrollHeight += label.contentSize.height;
    [scroller addChild:label];

    // This is the Cocos2D logo
    CCSprite *cocosLogo = [CCSprite spriteWithFile:@"cocos2d-landscape.png"];
    cocosLogo.anchorPoint = ccp(0.5, 1.0);
    cocosLogo.position = ccp(0, -1 * scrollHeight);
    scrollHeight += cocosLogo.contentSize.height;
    [scroller addChild:cocosLogo];
  
    CCLabelBMFont *copyright = [CCLabelBMFont labelWithString:@"\nGame and Software © 2012"
                                                      fntFile:@"score.fnt"];
    copyright.anchorPoint = ccp(0.5, 1.0);
    copyright.position = ccp(0, -1 * scrollHeight);
    copyright.color = kScoreColor;
    scrollHeight += copyright.contentSize.height;
    [scroller addChild:copyright];
    
    // Add scroller to clipping node.
    [clip addChild:scroller];
    
    // Roll the credits.
    CGPoint startPos = ccp(clip.contentSize.width / 2,
                           0);
    CGPoint endPos = ccp(clip.contentSize.width / 2,
                         clip.contentSize.height + scrollHeight);
    id moveTo = [CCMoveTo actionWithDuration:kCreditsScrollTime position:endPos];
//    id close = [CCCallFunc actionWithTarget:self selector:@selector(resumeParent)];
    scroller.position = startPos;
    [scroller runAction:[CCSequence actions:moveTo, nil]];

    // This is our logo.
    CCSprite *aetherTheoryLogo = [CCSprite spriteWithFile:@"aethertheory-logo.png"];
    aetherTheoryLogo.anchorPoint = ccp(0.5, 0.5);
    aetherTheoryLogo.position = ccp(clip.contentSize.width / 2,
                                    -1 * scrollHeight - aetherTheoryLogo.contentSize.height / 2);
    [clip addChild:aetherTheoryLogo];
    
    moveTo = [CCMoveTo actionWithDuration:kCreditsScrollTime 
                                 position:ccp(clip.contentSize.width / 2,
                                              clip.contentSize.height / 2)];
    [aetherTheoryLogo runAction:moveTo];
}

#pragma mark - CCTargetedTouchDelegate

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self resumeParent];
}

@end
