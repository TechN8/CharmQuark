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
    
    CCLabelTTF *title = [CCLabelTTF labelWithString:@"Game Over" fontName:@"American Typewriter" fontSize:40.0f];
    title.color = ccRED;
    title.position = ccp(winSize.width * 0.5, winSize.height * 0.7);
    [self addChild:title z:100];
    
    // Score / High Score
    CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score %d", score] 
                                           fontName:@"American Typewriter" 
                                           fontSize:20.0f];
    scoreLabel.position = ccp(winSize.width * 0.5, winSize.height * 0.6);
    scoreLabel.color = ccGREEN;
    [self addChild:scoreLabel z:100];
    
    NSString *highScoreString = nil;
    if (newHighScore) {
        highScoreString = @"New High Score!";
    } else {
        highScoreString = [NSString stringWithFormat:@"High Score %d", highScore];
    }
    CCLabelTTF *highScoreLabel = [CCLabelTTF labelWithString:highScoreString                                 
                                                    fontName:@"American Typewriter" 
                                                    fontSize:20.0f];
    highScoreLabel.position = ccp(winSize.width * 0.5, winSize.height * 0.55);
    highScoreLabel.color = ccGREEN;
    [self addChild:highScoreLabel z:100];
    
    //TODO: Replace with CCMenuItemAtlasFont
    //New Game
    CCMenuItemFont *newGameItem = [CCMenuItemFont itemWithString:@"New Game" 
                                                          target:self 
                                                        selector:@selector(newGame)];
    [newGameItem setFontName:@"American Typewriter"];
    [newGameItem setColor:ccWHITE];

    //Quit
    CCMenuItemFont *quitItem = [CCMenuItemFont itemWithString:@"Quit"
                                                       target:self 
                                                     selector:@selector(quitGame)];
    [quitItem setFontName:@"American Typewriter"];
    [quitItem setColor:ccWHITE];
    
    CCMenu *menu = [CCMenu menuWithItems:newGameItem, quitItem, nil];
    [menu alignItemsVerticallyWithPadding:10];
    menu.position = ccp(winSize.width * 0.5, winSize.height * 0.38f);
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
