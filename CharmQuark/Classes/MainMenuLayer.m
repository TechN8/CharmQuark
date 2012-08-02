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
#import "Scale9Sprite.h"

@interface MainMenuLayer()
-(void)displayMainMenu;
@end

@implementation MainMenuLayer

-(void)showOptions {
    CCLOG(@"Show the Options screen");
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
}

-(void)showCredits {
    CCLOG(@"Show credits screen.");
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
        [self addChild:leftParticle z:kZLeftParticle];
    } else {
        newParticle.position = rightParticleStart;
        rightParticle = newParticle;
        rightParticle.scale = kRightStartScale;
        [self flashTitle];
        [self addChild:rightParticle z:kZRightParticle];
//        PLAYSOUNDEFFECT(PARTICLE_EXPLODE, 1.0);
    }
    
    CCParticleSystemQuad *explosion = [particle explode];
    explosion.position = detector.position;
    [self addChild:explosion z:kZDetector];
    [detector animateAtAngle:explosion.rotation];
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
    //self.isTouchEnabled = YES;
    
    // Background window.  May want to remove later.
//    Scale9Sprite *backGround = [[[Scale9Sprite alloc] initWithFile:@"window.png" 
//                                                            ratioX:0.49 ratioY:0.49] autorelease];;
//    [backGround setContentSize:winSize];
//    [backGround setPosition:ccp(winSize.width / 2, winSize.height / 2)];
//    [self addChild:backGround];

    // Flashing & glowing title.
    CGPoint titlePos = ccp(winSize.width * 0.5, winSize.height * 0.85);
    CCSprite *titleGlow = [CCSprite spriteWithFile:@"title-glow.png"];
    titleGlow.color = ccc3(0, 128, 128);
    titleGlow.position = titlePos;
    [self addChild:titleGlow z:kZGlow];
    id fadeDown = [CCFadeTo actionWithDuration:1.5 opacity:200];
    id fadeUp = [CCFadeTo actionWithDuration:1.5 opacity:255];
    id seq = [CCSequence actions:fadeDown, fadeUp, nil];
    id loop = [CCRepeatForever actionWithAction:seq];
    [titleGlow runAction:loop];
    
    CCSprite *titleText = [CCSprite spriteWithFile:@"title-text.png"];
    titleText.position = titlePos;
    titleText.opacity = 200;
    [self addChild:titleText z:kZTitle];
    
    titleFlash = [CCSprite spriteWithFile:@"title-flash.png"];
    titleFlash.position = titlePos;
    titleFlash.color = ccc3(128, 255, 128);
    titleFlash.opacity = 0;
    [self addChild:titleFlash z:kZFlash];
    
    //Detector and Particles
    detector = [Detector node];
    detector.position = ccp(winSize.width / 2, winSize.height / 2);
    [self addChild:detector z:kZDetector];

    leftParticleStart = ccp(winSize.width * -0.1, winSize.height * 0);
    leftParticle = [Particle particleWithColor:kParticleBlue];
    leftParticle.scale = kLeftStartScale;
    leftParticle.position = leftParticleStart;
    [self addChild:leftParticle z:kZLeftParticle];
    
    rightParticleStart = ccp(winSize.width * 1.1, winSize.height * 1);
    rightParticle = [Particle particleWithColor:kParticleAntiBlue];
    rightParticle.scale = kRightStartScale;
    rightParticle.position = rightParticleStart;
    [self addChild:rightParticle z:kZRightParticle];
    
    [self schedule:@selector(animateBackground) interval:3.0];
    
    //TODO: Replace with CCMenuItemAtlasFont
    //Play
    CCLabelBMFont *survivalLabel = [CCLabelBMFont labelWithString:@"Accellerator" 
                                                          fntFile:@"score.fnt"];
    CCMenuItemFont *survivalItem = [CCMenuItemFont itemWithLabel:survivalLabel
                                                          target:self 
                                                        selector:@selector(playSurvival)];

    CCLabelBMFont *timeAttackLabel = [CCLabelBMFont labelWithString:@"Time Attack" 
                                                            fntFile:@"score.fnt"];
    CCMenuItemFont *timeAttackItem = [CCMenuItemFont itemWithLabel:timeAttackLabel
                                                            target:self 
                                                          selector:@selector(playTimeAttack)];
    
    CCLabelBMFont *momModeLabel = [CCLabelBMFont labelWithString:@"Meditation" 
                                                         fntFile:@"score.fnt"];
    CCMenuItemFont *momModeItem = [CCMenuItemFont itemWithLabel:momModeLabel
                                                         target:self 
                                                       selector:@selector(playMomMode)];

//    //Options
//    CCMenuItemFont *optionsItem = [CCMenuItemFont itemWithString:@"Options" target:self selector:@selector(showOptions)];
//    [optionsItem setFontName:@"Courier"];
//    [optionsItem setColor:ccWHITE];
//    
//    //High Scores
//    CCMenuItemFont *scoresItem = [CCMenuItemFont itemWithString:@"High Scores" target:self selector:@selector(showScores)];
//    [scoresItem setFontName:@"Courier"];
//    [scoresItem setColor:ccWHITE];
//    
//    //Credits
//    CCMenuItemFont *creditsItem = [CCMenuItemFont itemWithString:@"Credits" target:self selector:@selector(showCredits)];
//    [creditsItem setFontName:@"Courier"];
//    [creditsItem setColor:ccWHITE];
    
    mainMenu = [CCMenu menuWithItems:survivalItem, timeAttackItem, momModeItem, nil];
    mainMenu.position = ccp(winSize.width / 2, winSize.height * 0.4);
    [mainMenu alignItemsVerticallyWithPadding:0.03 * winSize.height];
    
    [self addChild:mainMenu z:kZMenu];

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
