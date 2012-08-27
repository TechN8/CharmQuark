//
//  GameOverLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 7/11/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "GameOverLayer.h"
#import "GameManager.h"
#import "TwitterHelper.h"
#import "CQMenuItemFont.h"
#import "CQLabelBMFont.h"

@implementation GameOverLayer

-(void)setScore:(NSInteger)theScore {
    GameManager *gm = [GameManager sharedGameManager];

    // Load high score.
    highScore = [gm getHighScoreForSceneWithID:gm.curLevel];
    score = theScore;

    // Set new high score.
    if (score > highScore) {
        highScore = score;
        newHighScore = YES;
        [gm setHighScore:score forSceneWithID:gm.curLevel];
    }
}

-(void) quitGame {
    PLAYSOUNDEFFECT(CLICK, 1.0);
    [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
}

-(void) restart {
    PLAYSOUNDEFFECT(CLICK, 1.0);
    GameManager *gm = [GameManager sharedGameManager];
    [gm runSceneWithID:[gm curLevel]];
}

-(void) tweet {
    PLAYSOUNDEFFECT(CLICK, 1.0);
    NSString *tweet 
    = [NSString stringWithFormat:@"I just scored %d points in #CharmQuark!", score];
    [[TwitterHelper sharedInstance] composeTweet:tweet];
}

#pragma mark - ModalMenuLayer

-(void) initUI {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CQLabelBMFont *title = [CQLabelBMFont labelWithString:@"Game Over" fntFile:@"score.fnt"];
    title.color = kColorDialogTitle;
    title.position = kDialogTitlePos;
    title.scale = kDialogTitleScale;
    [self addChild:title z:100];
    
    CGFloat scoreAdjust = 0;
    
    CCMenu *menu = [CCMenu node];
    menu.position = ccp(0,0);
    menu.anchorPoint = ccp(0,0);
    [self addChild:menu z:100];
    
    if ([[TwitterHelper sharedInstance] isTwitterAvailable]) {
        //Tweet this!
        CQLabelBMFont *tweetLabel = [CQLabelBMFont labelWithString:@"Tweet Score" 
                                                           fntFile:@"score.fnt"];
        tweetLabel.color = kColorButton;
        CQMenuItemFont *tweetItem = [CQMenuItemFont itemWithLabel:tweetLabel
                                                           target:self 
                                                         selector:@selector(tweet)];
        //Twitter Bird.
        CCSprite *twitterBird = [CCSprite spriteWithSpriteFrameName:@"twitter-bird.png"];
        twitterBird.anchorPoint = ccp(1.0, 0.5);
        twitterBird.position = ccp(-1 * twitterBird.contentSize.width / 2,
                                   tweetLabel.contentSize.height / 2);
        [tweetItem addChild:twitterBird];
        
        tweetItem.position = ccp(winSize.width * 0.5 + twitterBird.contentSize.width / 2,
                                 winSize.height * 0.35);
        [menu addChild:tweetItem];
        
        scoreAdjust = 0.05;
    }
    
    // Score / High Score
    CQLabelBMFont *scoreLabel = [CQLabelBMFont labelWithString:@"Score"
                                                       fntFile:@"score.fnt"];
    scoreLabel.anchorPoint = ccp(0.0, 0.5);
    scoreLabel.position = ccp(winSize.width * 0.20, winSize.height * (0.55 + scoreAdjust));
    scoreLabel.color = kColorUI;
    [self addChild:scoreLabel z:100];
    scoreLabel = [CQLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", score]
                                        fntFile:@"score.fnt"];
    scoreLabel.anchorPoint = ccp(1.0, 0.5);
    scoreLabel.position = ccp(winSize.width * 0.80, winSize.height * (0.55 + scoreAdjust));
    scoreLabel.color = kColorScore;
    [self addChild:scoreLabel z:100];
    
    if (newHighScore) {
        CQLabelBMFont *highScoreLabel = [CQLabelBMFont labelWithString:@"New High Score!"
                                                               fntFile:@"score.fnt"];
        highScoreLabel.color = kColorScore;
        highScoreLabel.position = ccp(winSize.width * 0.5, winSize.height * (0.45 + scoreAdjust));
        [self addChild:highScoreLabel z:100];
    } else {
        CQLabelBMFont *highScoreLabel = [CQLabelBMFont labelWithString:@"High Score"
                                                               fntFile:@"score.fnt"];
        highScoreLabel.color = kColorUI;
        highScoreLabel.anchorPoint = ccp(0.0, 0.5);
        highScoreLabel.position = ccp(winSize.width * 0.20, winSize.height * (0.45 + scoreAdjust));
        [self addChild:highScoreLabel z:100];
        highScoreLabel = [CQLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", highScore]
                                            fntFile:@"score.fnt"];
        highScoreLabel.color = kColorUI;
        highScoreLabel.anchorPoint = ccp(1.0, 0.5);
        highScoreLabel.position = ccp(winSize.width * 0.80, winSize.height * (0.45 + scoreAdjust));
        [self addChild:highScoreLabel z:100];
    }
    
    // Restart
    CQLabelBMFont *restartLabel = [CQLabelBMFont labelWithString:@"New Game" fntFile:@"score.fnt"];
    CQMenuItemFont *restartItem = [CQMenuItemFont itemWithLabel:restartLabel 
                                                         target:self 
                                                       selector:@selector(restart)];
    restartItem.color = kColorButton;
    restartItem.position = ccp(winSize.width * 0.33, winSize.height * 0.25f);
    [menu addChild:restartItem];    
    
    //Quit
    CQLabelBMFont *quitLabel = [CQLabelBMFont labelWithString:@"Quit" fntFile:@"score.fnt"];
    CQMenuItemFont *quitItem = [CQMenuItemFont itemWithLabel:quitLabel
                                                      target:self 
                                                    selector:@selector(quitGame)];
    quitItem.color = kColorButton;
    quitItem.position = ccp(winSize.width * 0.66, winSize.height * 0.25f);
    [menu addChild:quitItem];
}

-(id)init {
    self = [super init];
    if (self) {
        newHighScore = NO;
        score = 0;
        highScore = 0;
    }
    return self;
}

@end
