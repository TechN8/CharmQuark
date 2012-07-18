//
//  GameOverLayer.h
//  CharmQuark
//
//  Created by Nathan Babb on 7/11/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ModalMenuLayer.h"
#import "Constants.h"

@interface GameOverLayer : ModalMenuLayer {
    NSInteger score;
    NSInteger highScore;
    BOOL newHighScore;
}

-(void)setScore:(NSInteger)score;

@end
