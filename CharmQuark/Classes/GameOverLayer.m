//
//  GameOverLayer.m
//  CharmQuark
//
//  Created by Nathan Babb on 7/11/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "GameOverLayer.h"
#import "GameManager.h"

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

- (void) quitGame {
    [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
}

- (void) newGame {
    GameManager *gm = [GameManager sharedGameManager];
    [gm runSceneWithID:[gm curLevel]];
}

#pragma mark - ModalMenuLayer

-(void)initUI {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CCLabelBMFont *title = [CCLabelBMFont labelWithString:@"Game Over" fntFile:@"score.fnt"];
    title.color = kColorDialogTitle;
    title.position = kDialogTitlePos;
    title.scale = 1.3;
    [self addChild:title z:100];
    
    // Score / High Score
    CCLabelBMFont *scoreLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Score %d", score]
                                                       fntFile:@"score.fnt"];
    scoreLabel.position = ccp(winSize.width * 0.5, winSize.height * 0.55);
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
    highScoreLabel.position = ccp(winSize.width * 0.5, winSize.height * 0.45);
    [self addChild:highScoreLabel z:100];
    
    //New Game
    CCLabelBMFont *newGameLabel = [CCLabelBMFont labelWithString:@"New Game"
                                                         fntFile:@"score.fnt"];
    newGameLabel.color = kColorButton;
    CCMenuItemFont *newGameItem = [CCMenuItemFont itemWithLabel:newGameLabel
                                                          target:self 
                                                        selector:@selector(newGame)];

    //Quit
    CCLabelBMFont *quitLabel = [CCLabelBMFont labelWithString:@"Quit"
                                                      fntFile:@"score.fnt"];
    quitLabel.color = kColorButton;
    CCMenuItemFont *quitItem = [CCMenuItemFont itemWithLabel:quitLabel
                                                      target:self 
                                                    selector:@selector(quitGame)];
    
    CCMenu *menu = [CCMenu menuWithItems:newGameItem, quitItem, nil];
    [menu alignItemsHorizontallyWithPadding:0.15 * winSize.width];
    menu.position = ccp(winSize.width * 0.5, winSize.height * 0.25);
    [self addChild:menu z:100];
    [menu runAction:[CCFadeIn actionWithDuration:1.0]];
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
