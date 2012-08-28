//
//  LinksDialog.m
//  CharmQuark
//
//  Created by Nathan Babb on 8/27/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "LinksDialog.h"
#import "Constants.h"
#import "RemoveFromParentAction.h"
#import "GameManager.h"
#import "CQMenuItemFont.h"
#import "CQLabelBMFont.h"
#import "TwitterHelper.h"

@implementation LinksDialog

-(void)facebook {
    PLAYSOUNDEFFECT(CLICK, 1.0);
    [[GameManager sharedGameManager] openSiteWithLinkType:kLinkTypeFacebook];
}

-(void)twitter {
    PLAYSOUNDEFFECT(CLICK, 1.0);
    [[GameManager sharedGameManager] openSiteWithLinkType:kLinkTypeTwitter];
}

-(void)www {
    PLAYSOUNDEFFECT(CLICK, 1.0);
    [[GameManager sharedGameManager] openSiteWithLinkType:kLinkTypeMainSite];
}

-(void)initUI {
    [super addCloseArrow];
    
    // Add title.
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CQLabelBMFont *title = [CQLabelBMFont labelWithString:@"Aether Theory LLC"
                                                  fntFile:@"score.fnt"];
    title.color = kColorDialogTitle;
    title.position = kDialogTitlePos;
    title.scale = kDialogTitleScale;
    [self addChild:title z:100];
    
    
    // Add menu
    CCMenu *menu = [CCMenu node];
    menu.anchorPoint = ccp(0,0);
    menu.position = ccp(0,0);
    [self addChild:menu z:100];
    
    // Web site link.
    CCSprite *atSpriteNormal = [CCSprite spriteWithSpriteFrameName:@"at-icon.png"];
    CCMenuItemSprite *atSprite = [CCMenuItemSprite itemWithNormalSprite:atSpriteNormal
                                                         selectedSprite:nil
                                                                 target:self
                                                               selector:@selector(www)];
//    atSpriteNormal.color = ccc3(0x78, 0x2a, 0);
    CQLabelBMFont *wwwLabel = [CQLabelBMFont labelWithString:@"www.aethertheory.com"
                                                     fntFile:@"score.fnt"];
    wwwLabel.color = kColorButton;
    CCMenuItem *wwwItem = [CQMenuItemFont itemWithLabel:wwwLabel
                                                 target:self 
                                               selector:@selector(www)];
    wwwItem.position = ccp(winSize.width * 0.5 + atSprite.contentSize.width,
                           winSize.height * 0.54);
    [menu addChild:wwwItem];
    
    atSprite.anchorPoint = ccp(0, 0.5);
    atSprite.position = ccp(winSize.width * 0.17,
                            wwwItem.position.y);
    [menu addChild:atSprite];
    
    // Facebook link.
    CCSprite *fbSpriteNormal = [CCSprite spriteWithSpriteFrameName:@"facebook-icon.png"];
    CCMenuItemSprite *fbSprite = [CCMenuItemSprite itemWithNormalSprite:fbSpriteNormal
                                                         selectedSprite:nil
                                                                 target:self
                                                               selector:@selector(facebook)];
    CQLabelBMFont *fbLabel = [CQLabelBMFont labelWithString:@"Like us on Facebook."
                                                    fntFile:@"score.fnt"];
    fbLabel.color = kColorButton;
    CCMenuItem *fbItem = [CQMenuItemFont itemWithLabel:fbLabel
                                                target:self 
                                              selector:@selector(facebook)];
    fbItem.position = ccp(winSize.width * 0.5 + fbSprite.contentSize.width,
                          winSize.height * 0.42);
    [menu addChild:fbItem];
    
    fbSprite.anchorPoint = ccp(0, 0.5);
    fbSprite.position = ccp(winSize.width * 0.17, fbItem.position.y);
    [menu addChild:fbSprite];
    
    // Twitter link.
    CCSprite *twitterSpriteNormal = [CCSprite spriteWithSpriteFrameName:@"twitter-icon.png"];
    CCMenuItemSprite *twitterSprite = [CCMenuItemSprite itemWithNormalSprite:twitterSpriteNormal
                                                              selectedSprite:nil
                                                                      target:self
                                                                    selector:@selector(twitter)];
    CQLabelBMFont *twitterLabel = [CQLabelBMFont labelWithString:@"Follow us on Twitter."
                                                         fntFile:@"score.fnt"];
    twitterLabel.color = kColorButton;
    CCMenuItem *twitterItem = [CQMenuItemFont itemWithLabel:twitterLabel
                                                     target:self 
                                                   selector:@selector(twitter)];
    twitterItem.position = ccp(winSize.width * 0.5 + twitterSprite.contentSize.width,
                               winSize.height * 0.30);
    [menu addChild:twitterItem];
    
    twitterSprite.anchorPoint = ccp(0, 0.5);
    twitterSprite.position = ccp(winSize.width * 0.17, twitterItem.position.y);

    [menu addChild:twitterSprite];
    
}

- (void) resumeParent {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGPoint offScreen = ccp(0, 2 * winSize.height);
    CCSequence *seq = [CCSequence actions:[CCMoveTo actionWithDuration:kPopupSpeed position:offScreen], 
                       [RemoveFromParentAction action],
                       nil];
    [self runAction:seq];
}

#pragma mark - CCTargetedTouchDelegate

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if ([self isButtonTouch:touch]) {
        PLAYSOUNDEFFECT(CLICK, 1.0);
        [self resumeParent];
    }
}

@end
