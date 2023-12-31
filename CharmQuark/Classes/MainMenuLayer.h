//
//  MainMenuLayer.h
//  CharmQuark
//
//  Created by Nathan Babb on 6/18/12.
//  Copyright (c) 2012 Aether Theory, LLC. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "Particle.h"
#import "Detector.h"

#define kLeftStartScale     2
#define kRightStartScale    0

@interface MainMenuLayer : CCLayer {
    CCSprite *titleFlash;
    Particle *leftParticle;
    Particle *rightParticle;
    Detector *detector;
    CGPoint leftParticleStart;
    CGPoint rightParticleStart;
    CCSpriteBatchNode *batchNode;
    CCParticleBatchNode *particleBatch;
}

@end
