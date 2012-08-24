//
//  MainMenuLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/18/12.
//  Copyright (c) 2012 Aether Theory, LLC. All rights reserved.
//

#import "MainMenuLayer.h"
#import "Constants.h"
#import "GameManager.h"
#import "GameOverLayer.h"
#import "CreditsDialog.h"
#import "OptionsDialog.h"
#import "HighScoreDialog.h"
#import "GCHelper.h"
#import "CQMenuItemFont.h"

// Z Values for UI Elements.
enum {
    kZRightParticle = 0,
    kZBackground,
    kZDetector,
    kZGlow,
    kZTitle,
    kZFlash,
    kZMenu = 100,
    kZLeftParticle,
    kZPopups,
};

@interface MainMenuLayer()
-(void)displayMainMenu;
@end

@implementation MainMenuLayer

-(void)showOptions {
    CCLOG(@"Showing options");
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // Throw up modal layer.
    OptionsDialog *options = [OptionsDialog node];
    CGPoint oldPos = options.position;
    options.position = ccp(0, 2 * winSize.height);
    [self addChild:options z:kZPopups];
    [options runAction:[CCMoveTo actionWithDuration:kPopupSpeed
                                           position:oldPos]];
}

-(void)playSurvival {
    CCLOG(@"Playing Accelerator.");
    [[GameManager sharedGameManager] runSceneWithID:kGameSceneSurvival];
}

-(void)playTimeAttack {
    CCLOG(@"Playing Time Attack.");
    [[GameManager sharedGameManager] runSceneWithID:kGameSceneTimeAttack];
}

-(void)playMomMode {
    CCLOG(@"Playing Meditation.");
    [[GameManager sharedGameManager] runSceneWithID:kGameSceneMomMode];
}

-(void)showScores {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CCLOG(@"Show local scores.");
    HighScoreDialog *scores = [HighScoreDialog node];
    CGPoint oldPos = scores.position;
    scores.position = ccp(0, 2 * winSize.height);
    [self addChild:scores z:kZPopups];
    [scores runAction:[CCMoveTo actionWithDuration:kPopupSpeed
                                          position:oldPos]];
}

-(void)showCredits {
    CCLOG(@"Showing credits.");
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // Throw up modal layer.
    CreditsDialog *credits = [CreditsDialog node];
    CGPoint oldPos = credits.position;
    credits.position = ccp(0, 2 * winSize.height);
    [self addChild:credits z:kZPopups];
    [credits runAction:[CCMoveTo actionWithDuration:kPopupSpeed
                                           position:oldPos]];
}

-(void)facebook {
    CCLOG(@"Opening facebook page.");
    [[GameManager sharedGameManager] openSiteWithLinkType:kLinkTypeFacebook];
}

-(void)twitter {
    CCLOG(@"Tweet something.");
}

-(void)flashTitle {
    titleFlash.opacity = 255;
    id fadeOut = [CCFadeOut actionWithDuration:0.7];
    [titleFlash runAction:fadeOut];
}

-(void)explode:(Particle *)particle {
    ParticleColors color = rand() % 6;
    Particle *newParticle = [Particle particleWithColor:color];
    if (particle == leftParticle) {
        newParticle.position = leftParticleStart;
        leftParticle = newParticle;
        leftParticle.scale = kLeftStartScale;
        [batchNode addChild:leftParticle z:kZLeftParticle];
    } else {
        newParticle.position = rightParticleStart;
        rightParticle = newParticle;
        rightParticle.scale = kRightStartScale;
        [self flashTitle];
        [batchNode addChild:rightParticle z:kZRightParticle];
//        PLAYSOUNDEFFECT(PARTICLE_EXPLODE, 1.0);
    }
    
    CCParticleSystemQuad *explosion = [particle explode];
    explosion.position = detector.position;
    [particleBatch addChild:explosion z:kZDetector];
    [detector animateAtAngle:-1 * explosion.angle graphColor:ccGREEN];
}

-(void)animateBackground {
    leftParticle.position = leftParticleStart;
    id move = [CCMoveTo actionWithDuration:0.5 position:detector.position];
    id scale = [CCScaleTo actionWithDuration:0.5 scale:1.0];
    id explode = [CCCallFuncN actionWithTarget:self selector:@selector(explode:)];
    id seq = [CCSequence actions:move, explode, nil];
    [leftParticle runAction:seq];
    [leftParticle runAction:scale];
    
    rightParticle.position = rightParticleStart;
    move = [CCMoveTo actionWithDuration:0.5 position:detector.position];
    scale = [CCScaleTo actionWithDuration:0.5 scale:1.0];
    explode = [CCCallFuncN actionWithTarget:self selector:@selector(explode:)];
    seq = [CCSequence actions:move, explode, nil];
    [rightParticle runAction:seq];
    [rightParticle runAction:scale];
}

-(void)displayMainMenu {
    CGSize winSize = [CCDirector sharedDirector].winSize; 

    // Batch nodes for the performances...
    batchNode = [CCSpriteBatchNode batchNodeWithFile:@"scene1Atlas.png" capacity:50];
    [self addChild:batchNode z:kZDetector];
    particleBatch = [CCParticleBatchNode batchNodeWithFile:@"scene1Atlas.png" capacity:2];
    [self addChild:particleBatch z:kZLeftParticle];
    
    CCSpriteBatchNode *titleBatch = [CCSpriteBatchNode batchNodeWithFile:@"titleAtlas.png" capacity:3];
    [self addChild:titleBatch z:kZTitle];
    
    // Flashing & glowing title.
    CGPoint titlePos = ccp(winSize.width * 0.5, winSize.height * 0.80);
    CCSprite *titleGlow = [CCSprite spriteWithSpriteFrameName:@"title-glow.png"];
    titleGlow.color = ccc3(0, 128, 128);
    titleGlow.position = titlePos;
    [titleBatch addChild:titleGlow z:kZGlow];
    id fadeDown = [CCFadeTo actionWithDuration:1.5 opacity:200];
    id fadeUp = [CCFadeTo actionWithDuration:1.5 opacity:255];
    id seq = [CCSequence actions:fadeDown, fadeUp, nil];
    id loop = [CCRepeatForever actionWithAction:seq];
    [titleGlow runAction:loop];
    
    CCSprite *titleText = [CCSprite spriteWithSpriteFrameName:@"title-text.png"];
    titleText.position = titlePos;
    [titleBatch addChild:titleText z:kZTitle];
    
    titleFlash = [CCSprite spriteWithSpriteFrameName:@"title-flash.png"];
    titleFlash.position = titlePos;
    titleFlash.color = ccc3(128, 255, 128);
    titleFlash.opacity = 0;
    [titleBatch addChild:titleFlash z:kZFlash];
    
    //Detector
    detector = [Detector node];
    detector.position = ccp(winSize.width / 2, winSize.height / 2);
    
    // Add the background tiles.
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:winSize.width
                                                           height:winSize.height];
    [rt begin];
    CCSprite *bg = [CCSprite spriteWithFile:@"background.png"
                                       rect:CGRectMake(0, 0, winSize.width, winSize.height)];
    ccTexParams params = {GL_LINEAR,GL_NEAREST,GL_REPEAT,GL_REPEAT};
    [bg.texture setTexParameters:&params];
    bg.position = ccp(winSize.width / 2, winSize.height / 2);
    bg.color = ccc3(0, 40, 60);
    [bg visit];
    [bg cleanup];

    bg = [CCSprite spriteWithFile:@"bg-gradient.png"];
    bg.scaleX = winSize.width / bg.contentSize.width;
    bg.scaleY = winSize.height / bg.contentSize.height;
    bg.position = ccp(winSize.width / 2, winSize.height / 2);
    [bg visit];
    [bg cleanup];
    
    [detector visit];
    detector.visible = NO;
    [batchNode addChild:detector z:kZDetector];
    
    [rt end];
    rt.position = ccp(winSize.width / 2, winSize.height / 2);
    [self addChild:rt z:kZBackground];    
    
    // Particles
    leftParticleStart = ccp(winSize.width / 2 - winSize.height * 0.4,
                            winSize.height * -0.1);
    leftParticle = [Particle particleWithColor:kParticleBlue];
    leftParticle.scale = kLeftStartScale;
    leftParticle.position = leftParticleStart;
    [batchNode addChild:leftParticle z:kZLeftParticle];
    
    rightParticleStart = ccp(winSize.width / 2 + winSize.height * 0.4,
                             winSize.height * 1.1);
    rightParticle = [Particle particleWithColor:kParticleAntiBlue];
    rightParticle.scale = kRightStartScale;
    rightParticle.position = rightParticleStart;
    [batchNode addChild:rightParticle z:kZRightParticle];
    
    [self schedule:@selector(animateBackground) interval:3.0];
    
    //Menu
    menu = [CCMenu node];
    menu.position = ccp(winSize.width * 0.5,
                        winSize.height * 0.4);

    CCLabelBMFont *label;
    CQMenuItemFont *item;
    
    // Time Attack
    label = [CCLabelBMFont labelWithString:@"Time Attack" 
                                   fntFile:@"score.fnt"];
    label.color = kColorButton;
    label.scale = 1.0;
    item = [CQMenuItemFont itemWithLabel:label
                                  target:self 
                                selector:@selector(playTimeAttack)];
    item.position = ccp(-0.25 * winSize.width, 0.025 * winSize.height);
    [menu addChild:item];

    // Accelerator
    label = [CCLabelBMFont labelWithString:@"Accelerator" 
                                   fntFile:@"score.fnt"];
    label.color = kColorButton;
    label.scale = 1.0;
    item = [CQMenuItemFont itemWithLabel:label
                                  target:self 
                                selector:@selector(playSurvival)];
    item.position = ccp(-0.25 * winSize.width, -0.1 * winSize.height);
    [menu addChild:item];
    
    // Meditation
    label = [CCLabelBMFont labelWithString:@"Meditation" 
                                   fntFile:@"score.fnt"];
    label.scale = 1.0;
    label.color = kColorButton;
    item = [CQMenuItemFont itemWithLabel:label
                                  target:self 
                                selector:@selector(playMomMode)];
    item.position = ccp(-0.25 * winSize.width, -0.225 * winSize.height);
    [menu addChild:item];

    // Options
    label = [CCLabelBMFont labelWithString:@"Options" 
                                   fntFile:@"score.fnt"];
    label.color = kColorButton;
    label.scale = 1.0;
    item = [CQMenuItemFont itemWithLabel:label
                                  target:self 
                                selector:@selector(showOptions)];
    item.position = ccp(0.25 * winSize.width, 0.025 * winSize.height);
    [menu addChild:item];

    // Records
    label = [CCLabelBMFont labelWithString:@"Records" 
                                   fntFile:@"score.fnt"];
    label.color = kColorButton;
    label.scale = 1.0;
    item = [CQMenuItemFont itemWithLabel:label
                                  target:self 
                                selector:@selector(showScores)];
    item.position = ccp(0.25 * winSize.width, -0.1 * winSize.height);
    [menu addChild:item];

    // Credits
    label = [CCLabelBMFont labelWithString:@"Credits" 
                                   fntFile:@"score.fnt"];
    label.color = kColorButton;
    label.scale = 1.0;
    item = [CQMenuItemFont itemWithLabel:label
                                  target:self 
                                selector:@selector(showCredits)];
    item.position = ccp(0.25 * winSize.width, -0.225 * winSize.height);
    [menu addChild:item];
    [self addChild:menu z:kZMenu];

    /*
    // Facebook.
    CCSprite *facebookSprite = [CCSprite spriteWithSpriteFrameName:@"facebook.png"];
    CCMenuItemSprite* facebookItem = [CCMenuItemSprite 
                                      itemWithNormalSprite:facebookSprite 
                                      selectedSprite:nil 
                                      target:self
                                      selector:@selector(facebook)];
    facebookItem.anchorPoint = ccp(0.5, 0);
    
    // Twitter.
    CCSprite *twitterSprite = [CCSprite spriteWithSpriteFrameName:@"twitter.png"];
    CCMenuItemSprite* twitterItem = [CCMenuItemSprite 
                                      itemWithNormalSprite:twitterSprite 
                                      selectedSprite:nil 
                                      target:self
                                      selector:@selector(twitter)];
    twitterItem.anchorPoint = ccp(0.5, 0);
    
    CCMenu *menu2 = [CCMenu menuWithItems:facebookItem, twitterItem, nil];
    [menu2 alignItemsHorizontallyWithPadding:winSize.width * 0.05];
    menu2.position = ccp(winSize.width * 0.5, winSize.height * 0.02);
    [self addChild:menu2 z:kZMenu];
     */
    
    // Show version.
    NSString *vers =[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    NSString *mvers =[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    NSString *versionString = [NSString stringWithFormat:@"v%@ (%@)", mvers, vers];
    CCLabelTTF *versionLabel = [CCLabelTTF labelWithString:versionString 
                                                 fontName:@"American Typewriter"
                                                 fontSize:12.0];
    versionLabel.opacity = 128;
    versionLabel.color = kColorUI;
    versionLabel.anchorPoint = ccp(1.0, 0.0);
    versionLabel.position = ccp(winSize.width, 0);
    [self addChild:versionLabel];
}

-(void)onEnter {
    [super onEnter];

    [self displayMainMenu];
}

-(id)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
