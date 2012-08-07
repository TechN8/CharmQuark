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

@interface MainMenuLayer()
-(void)displayMainMenu;
@end

@implementation MainMenuLayer

-(void)showOptions {
    CCLOG(@"Show the Options screen");
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
    CCLOG(@"Play the game.");
    [[GameManager sharedGameManager] runSceneWithID:kGameSceneSurvival];
}

-(void)playTimeAttack {
    CCLOG(@"Play the game.");
    [[GameManager sharedGameManager] runSceneWithID:kGameSceneTimeAttack];
}

-(void)playMomMode {
    CCLOG(@"Hi Mom.");
    [[GameManager sharedGameManager] runSceneWithID:kGameSceneMomMode];
}

-(void)showScores {
    CCLOG(@"Show high scores.");
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // Throw up modal layer.
    HighScoreDialog *scores = [HighScoreDialog node];
    CGPoint oldPos = scores.position;
    scores.position = ccp(0, 2 * winSize.height);
    [self addChild:scores z:kZPopups];
    [scores runAction:[CCMoveTo actionWithDuration:kPopupSpeed
                                          position:oldPos]];
}

-(void)showCredits {
    CCLOG(@"Show credits screen.");
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // Throw up modal layer.
    CreditsDialog *credits = [CreditsDialog node];
    CGPoint oldPos = credits.position;
    credits.position = ccp(0, 2 * winSize.height);
    [self addChild:credits z:kZPopups];
    [credits runAction:[CCMoveTo actionWithDuration:kPopupSpeed
                                           position:oldPos]];
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
    [detector animateAtAngle:-1 * explosion.angle];
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
    
    //Detector and Particles
    detector = [Detector node];
    detector.position = ccp(winSize.width / 2, winSize.height / 2);
    [batchNode addChild:detector z:kZDetector];

    leftParticleStart = ccp(winSize.width / 2 - winSize.height * 0.6,
                            winSize.height * -0.1);
    leftParticle = [Particle particleWithColor:kParticleBlue];
    leftParticle.scale = kLeftStartScale;
    leftParticle.position = leftParticleStart;
    [batchNode addChild:leftParticle z:kZLeftParticle];
    
    rightParticleStart = ccp(winSize.width / 2 + winSize.height * 0.6,
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
    CCMenuItemFont *item;
    
    label = [CCLabelBMFont labelWithString:@"Time Attack" 
                                   fntFile:@"score.fnt"];
    item = [CCMenuItemFont itemWithLabel:label
                                  target:self 
                                selector:@selector(playTimeAttack)];
    item.position = ccp(-0.25 * winSize.width, 0);
    [menu addChild:item];

    label = [CCLabelBMFont labelWithString:@"Accelerator" 
                                   fntFile:@"score.fnt"];
    item = [CCMenuItemFont itemWithLabel:label
                                  target:self 
                                selector:@selector(playSurvival)];
    item.position = ccp(-0.25 * winSize.width, -0.1 * winSize.height);
    [menu addChild:item];
    
    label = [CCLabelBMFont labelWithString:@"Meditation" 
                                   fntFile:@"score.fnt"];
    item = [CCMenuItemFont itemWithLabel:label
                                  target:self 
                                selector:@selector(playMomMode)];
    item.position = ccp(-0.25 * winSize.width, -0.2 * winSize.height);
    [menu addChild:item];
    
    label = [CCLabelBMFont labelWithString:@"Options" 
                                   fntFile:@"score.fnt"];
    item = [CCMenuItemFont itemWithLabel:label
                                  target:self 
                                selector:@selector(showOptions)];
    item.position = ccp(0.25 * winSize.width, 0);
    [menu addChild:item];
    
    label = [CCLabelBMFont labelWithString:@"High Scores" 
                                   fntFile:@"score.fnt"];
    item = [CCMenuItemFont itemWithLabel:label
                                  target:self 
                                selector:@selector(showScores)];
    item.position = ccp(0.25 * winSize.width, -0.1 * winSize.height);
    [menu addChild:item];
    
    label = [CCLabelBMFont labelWithString:@"Credits" 
                                   fntFile:@"score.fnt"];
    item = [CCMenuItemFont itemWithLabel:label
                                  target:self 
                                selector:@selector(showCredits)];
    item.position = ccp(0.25 * winSize.width, -0.2 * winSize.height);
    [menu addChild:item];

    
//    [menu alignItemsInRows:[NSNumber numberWithUnsignedInt:3],
//     [NSNumber numberWithUnsignedInt:3],
//     nil];
//    [menu alignItemsVerticallyWithPadding:0.03 * winSize.height];
//    [menu alignItemsHorizontallyWithPadding:50];

    // TODO Override menu positioning...
    
    [self addChild:menu z:kZMenu];

//    // Animate in menu.
//    [mainMenu setPosition:ccp(winSize.width * 0.5, - 1 * winSize.height)];
//    id moveAction = 
//    [CCMoveTo actionWithDuration:1.2f 
//                        position:ccp(winSize.width * 0.5, winSize.height * 0.5)];
//    id moveEffect = [CCEaseIn actionWithAction:moveAction rate:1.0f];
//    [mainMenu runAction:moveEffect];
    
    [[GameManager sharedGameManager] stopBackgroundTrack];
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
