//
//  Tutorial.h
//  CharmQuark
//
//  Created by Nathan Babb on 8/22/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameplayLayer.h"
#import "Constants.h"

@interface Tutorial : GameplayLayer {
    NSInteger tutorialStep;
    SceneTypes nextScene;
}

@property (assign) SceneTypes nextScene;

+(CCScene *) sceneWithNextSceneId:(SceneTypes)theNextScene;

@end
