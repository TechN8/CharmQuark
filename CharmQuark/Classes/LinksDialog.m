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

@implementation LinksDialog

-(void)facebook {
    CCLOG(@"Opening facebook page.");
    PLAYSOUNDEFFECT(CLICK, 1.0);
    
    [[GameManager sharedGameManager] openSiteWithLinkType:kLinkTypeFacebook];
}

-(void)twitter {
    CCLOG(@"Tweet something.");
    PLAYSOUNDEFFECT(CLICK, 1.0);
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
    CQLabelBMFont *wwwLabel = [CQLabelBMFont labelWithString:@"www.aethertheory.com"
                                                     fntFile:@"score.fnt"];
    wwwLabel.color = kColorButton;
    CCMenuItem *wwwItem = [CQMenuItemFont itemWithLabel:wwwLabel
                                                target:self 
                                              selector:@selector(www)];
    wwwItem.position = ccp(winSize.width * 0.5, winSize.height * 0.60);
    [menu addChild:wwwItem];
    
    // Facebook link.
    CQLabelBMFont *fbLabel = [CQLabelBMFont labelWithString:@"facebook.com/AetherTheoryLLC"
                                                     fntFile:@"score.fnt"];
    fbLabel.color = kColorButton;
    CCMenuItem *fbItem = [CQMenuItemFont itemWithLabel:fbLabel
                                                 target:self 
                                               selector:@selector(facebook)];
    fbItem.position = ccp(winSize.width * 0.5, winSize.height * 0.50);
    [menu addChild:fbItem];
    
    // Twitter link.
    CQLabelBMFont *twitterLabel = [CQLabelBMFont labelWithString:@"Twitter..."
                                                     fntFile:@"score.fnt"];
    twitterLabel.color = kColorButton;
    CCMenuItem *twitterItem = [CQMenuItemFont itemWithLabel:twitterLabel
                                                 target:self 
                                               selector:@selector(twitter)];
    twitterItem.position = ccp(winSize.width * 0.5, winSize.height * 0.40);
    [menu addChild:twitterItem];
    
    
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
