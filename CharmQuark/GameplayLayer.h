//
//  GameplayLayer.h
//  CharmQuark
//
//  Created by Nathan Babb on 6/19/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "chipmunk.h"

@class Particle;

@interface GameplayLayer : CCLayerColor {
    // Chipmunk
    cpSpace *space;
    
    // Viewport
    CCLayerColor *viewLayer;
    CCSpriteBatchNode *sceneSpriteBatchNode;
    
	// Touch handling
	CGFloat initialTouchAngle;
	CGFloat currentTouchAngle;
	CGFloat initialRotation;
    BOOL touchesMoved;
    
    // Game Objects
    Particle *nextParticle;
    CCLabelAtlas *scoreLabel;
    NSMutableSet *scoredParticles;
    long score;
}

@property (assign) cpSpace *space;
@property (retain) NSMutableSet *scoredParticles;
@property (assign) long score;
@property (retain) CCLabelAtlas *scoreLabel;

@end
