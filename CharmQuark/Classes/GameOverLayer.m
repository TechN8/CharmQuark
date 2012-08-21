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
    [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
}

-(void) newGame {
    GameManager *gm = [GameManager sharedGameManager];
    [gm runSceneWithID:[gm curLevel]];
}

-(void) tweet {
    NSString *tweet 
    = [NSString stringWithFormat:@"I just scored %d points in #CharmQuark!", score];
    [[TwitterHelper sharedInstance] composeTweet:tweet];
}

#pragma mark - ModalMenuLayer

-(void) initUI {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CCLabelBMFont *title = [CCLabelBMFont labelWithString:@"Game Over" fntFile:@"score.fnt"];
    title.color = kColorDialogTitle;
    title.position = kDialogTitlePos;
    title.scale = 1.3;
    [self addChild:title z:100];
    
    CGFloat scoreAdjust = 0;
    
    if ([[TwitterHelper sharedInstance] isTwitterAvailable]) {
        //Tweet this!
        CCLabelBMFont *tweetLabel = [CCLabelBMFont labelWithString:@"Tweet Score" 
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
        
        CCMenu *menu1= [CCMenu menuWithItems:tweetItem, nil];
        tweetItem.position = ccp(tweetItem.position.x + twitterBird.contentSize.width / 2,
                                 tweetItem.position.y);
        
        menu1.position = ccp(winSize.width * 0.5, winSize.height * 0.35);
        [self addChild:menu1 z:100];
        
        scoreAdjust = 0.05;
    }
    
    // Score / High Score
    CCLabelBMFont *scoreLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Score %d", score]
                                                       fntFile:@"score.fnt"];
    scoreLabel.position = ccp(winSize.width * 0.5, winSize.height * (0.55 + scoreAdjust));
    scoreLabel.color = kColorScore;
    [self addChild:scoreLabel z:100];
    
    CCLabelBMFont *highScoreLabel = [CCLabelBMFont labelWithString:@"High Score"
                                                           fntFile:@"score.fnt"];
    if (newHighScore) {
        highScoreLabel.string = @"New High Score!";
        highScoreLabel.color = kColorScore;
    } else {
        highScoreLabel.string = [NSString stringWithFormat:@"High Score %d", highScore];
        highScoreLabel.color = kColorUI;
    }
    highScoreLabel.position = ccp(winSize.width * 0.5, winSize.height * (0.45 + scoreAdjust));
    [self addChild:highScoreLabel z:100];
    
    //New Game
    CCLabelBMFont *newGameLabel = [CCLabelBMFont labelWithString:@"New Game"
                                                         fntFile:@"score.fnt"];
    newGameLabel.color = kColorButton;
    CQMenuItemFont *newGameItem = [CQMenuItemFont itemWithLabel:newGameLabel
                                                          target:self 
                                                        selector:@selector(newGame)];

    //Quit
    CCLabelBMFont *quitLabel = [CCLabelBMFont labelWithString:@"Quit"
                                                      fntFile:@"score.fnt"];
    quitLabel.color = kColorButton;
    CQMenuItemFont *quitItem = [CQMenuItemFont itemWithLabel:quitLabel
                                                      target:self 
                                                    selector:@selector(quitGame)];
    
    CCMenu *menu2 = [CCMenu menuWithItems:newGameItem, quitItem, nil];
    [menu2 alignItemsHorizontallyWithPadding:0.15 * winSize.width];
    menu2.position = ccp(winSize.width * 0.5, winSize.height * 0.25);
    [self addChild:menu2 z:100];
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
