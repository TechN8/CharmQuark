//
//  Tutorial.m
//  CharmQuark
//
//  Created by Nathan Babb on 8/22/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "Tutorial.h"
#import "GameManager.h"

@implementation Tutorial

@synthesize nextScene;

+(CCScene *) sceneWithNextSceneId:(SceneTypes)theNextScene {
	CCScene *scene = [CCScene node];
	Tutorial *layer = [self node];
    layer.nextScene = theNextScene;
	[scene addChild: layer];
	return scene;
}

-(void) resetGame {
    [super resetGame];
    
    tutorialStep = 1;
    [self scheduleOnce:@selector(tutorial) delay:0.0];
}

-(void) tutorial {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    static CQLabelBMFont *instructions = nil;
    switch (tutorialStep) {
        case 1:
            // Swipe here to rotate.
            instructions = [CQLabelBMFont labelWithString:@"Swipe here\nto rotate." 
                                                  fntFile:@"score.fnt"];
            instructions.position = ccp(puzzleCenter.x, winSize.height * 0.75);
            instructions.alignment = kCCTextAlignmentCenter;
            instructions.color = kColorButton;
            [self addChild:instructions z:kZLog];
            thumbGuide.position = ccp(puzzleCenter.x + detector.contentSize.width * 0.35, puzzleCenter.y);
            thumbGuide.rotation = 90;
            id fadeIn = [CCFadeTo actionWithDuration:0.5 opacity:128];
            id fadeOut = [CCFadeTo actionWithDuration:0.5 opacity:64];
            id seq = [CCSequence actions:fadeIn, fadeOut, nil];
            [thumbGuide runAction: [CCRepeatForever actionWithAction:seq]];
            tutorialStep++;
            break;
        case 2:
            // Tap here to fire.
            [thumbGuide stopAllActions];
            thumbGuide.opacity = 0;
            instructions.string = @"Tap here\nto fire..";
            instructions.position = ccp(winSize.width * 0.20, winSize.height * 0.60);
            fireButton.position = ccp(winSize.width * 0.20, winSize.height * 0.25);
            fireButton.opacity = kOpacityThumbGuide;
            fadeIn = [CCFadeTo actionWithDuration:0.5 opacity:128];
            fadeOut = [CCFadeTo actionWithDuration:0.5 opacity:64];
            seq = [CCSequence actions:fadeIn, fadeOut, nil];
            [fireButton runAction: [CCRepeatForever actionWithAction:seq]];
            tutorialStep++;
            break;
        case 3:
            // Match N pieces to score.
            [fireButton stopAllActions];
            fireButton.opacity = 0;
            instructions.string = [NSString stringWithFormat:@"Match %d particles\nto score.",
                                   kMinMatchSize];
            instructions.position = ccp(puzzleCenter.x, winSize.height * 0.75);
            for (Particle *particle in particles) {
                fadeOut = [CCFadeTo actionWithDuration:0.5 opacity:128];
                fadeIn = [CCFadeTo actionWithDuration:0.5 opacity:255];
                seq = [CCSequence actions:fadeOut, fadeIn, nil];
                [particle runAction: [CCRepeatForever actionWithAction:seq]];
            }
            for (Particle *particle in inFlightParticles) {
                fadeOut = [CCFadeTo actionWithDuration:0.5 opacity:128];
                fadeIn = [CCFadeTo actionWithDuration:0.5 opacity:255];
                seq = [CCSequence actions:fadeOut, fadeIn, nil];
                [particle runAction: [CCRepeatForever actionWithAction:seq]];
            }
            tutorialStep++;
            break;
        case 4:
            // Stay inside the ring.
            for (Particle *particle in particles) {
                [particle stopAllActions];
                particle.opacity = 255;
            }
            for (Particle *particle in inFlightParticles) {
                [particle stopAllActions];
                particle.opacity = 255;
            }
            instructions.string = @"Keep particles\ninside the detector.";
            instructions.position = ccp(puzzleCenter.x, winSize.height * 0.75);
            fadeOut = [CCTintTo actionWithDuration:0.5 red:128 green:128 blue:128];
            fadeIn = [CCTintTo actionWithDuration:0.5 red:255 green:255 blue:255];
            seq = [CCSequence actions:fadeOut, fadeIn, nil];
            detector.visible = YES;
            [detector runAction: [CCRepeatForever actionWithAction:seq]];
            tutorialStep++;
            break;
        case 5:
            // Tap to play.
            [detector stopAllActions];
            detector.visible = NO;
            instructions.string = @"Tap to play.";
            instructions.position = ccp(winSize.width * 0.50, winSize.height * 0.25);
            tutorialStep++;
            break;
        case 6:
            // Reset game.
            [instructions removeFromParentAndCleanup:YES];
            GameManager *gm = [GameManager sharedGameManager];
            [gm setShouldShowTutorial:NO];
            [gm runSceneWithID:nextScene];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark CCTouchDelegateProtocol
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
        if (location.x > winSize.width * 0.9 
            && location.y > winSize.height * 0.9) {
            [self pause];
        } else if (location.x < winSize.width * 0.33) {
            // Touches on the left drop pieces on end.
            if (nil == launchTouch
                && (tutorialStep == 0 || tutorialStep == 3)) {
                launchTouch = touch;
                fireButton.position = location;
                fireButton.opacity = kOpacityThumbGuide;
            }
        } else if (location.x >= winSize.width * 0.33) {
            if (nil == rotationTouch
                && (tutorialStep == 0 || tutorialStep == 2)) {
                // Touches on the right are for rotation.  
                rotationTouch = touch;
                rotationTouchTime = touch.timestamp;
                
                // Save game angle from start of touches
                centerNodeAngleInit = centerNode.rotation;
                
                // Calculate initial vector from puzzle to touch.
                CGPoint ray = ccpSub(location, puzzleCenter);
                rotTouchPointInit = ray;
                rotTouchPointCur = ray;
                
                // Show thumb guide.
                thumbGuide.position = location;
                thumbGuide.rotation = CC_RADIANS_TO_DEGREES(atanf(ray.x / ray.y));
                thumbGuide.opacity = kOpacityThumbGuide;
            }        
        }
    }
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (touch == rotationTouch) {
            if (touch.timestamp - rotationTouchTime > 0.05 
                || fabsf(rotAngleV) < kRotationMinAngleV) { 
                rotAngleV = 0.0;
            } else {
                rotAngleV = clampf(rotAngleV, -1 * kRotationMaxAngleV, kRotationMaxAngleV);
            }
            
            // Forget this touch.
            rotationTouch = nil;
            thumbGuide.opacity = 0;
            
            if (tutorialStep == 2) {
                [self scheduleOnce:@selector(tutorial)
                             delay:0.0];
            }
        }
        if (touch == launchTouch) {
            [self launch];
            
            // Forget this touch.
            launchTouch = nil;
            fireButton.opacity = 0;
            
            if (tutorialStep == 3) {
                [self scheduleOnce:@selector(tutorial)
                             delay:0.0];
            }
        }
        
        // Step the tutorial.
        if (tutorialStep > 3 && !paused) {
            [self scheduleOnce:@selector(tutorial)
                         delay:0.0];
            return;
        }
    }
}

@end
