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
    static CQLabelBMFont *levelLabel = nil;
    static CQLabelBMFont *timerLabel = nil;
    
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
            thumbGuide.visible = YES;
            [thumbGuide runAction: [CCRepeatForever actionWithAction:seq]];
            tutorialStep++;
            break;
        case 2:
            // Tap here to fire.
            [thumbGuide stopAllActions];
            thumbGuide.opacity = kOpacityThumbGuide;
            thumbGuide.visible = NO;
            instructions.string = @"Tap here\nto fire.";
            instructions.position = ccp(winSize.width * 0.20, winSize.height * 0.60);
            fireButton.position = ccp(winSize.width * 0.20, winSize.height * 0.25);
            fireButton.visible = YES;
            fadeIn = [CCFadeTo actionWithDuration:0.5 opacity:128];
            fadeOut = [CCFadeTo actionWithDuration:0.5 opacity:64];
            seq = [CCSequence actions:fadeIn, fadeOut, nil];
            [fireButton runAction: [CCRepeatForever actionWithAction:seq]];
            tutorialStep++;
            break;
        case 3:
            // Match N pieces to score.
            [fireButton stopAllActions];
            fireButton.opacity = kOpacityThumbGuide;
            fireButton.visible = NO;
            instructions.string = [NSString stringWithFormat:@"Match %d particles\nto score.",
                                   kMinMatchSize];
            instructions.position = ccp(puzzleCenter.x, winSize.height * 0.75);
            for (Particle *particle in particles) {
                fadeOut = [CCTintTo actionWithDuration:0.5
                                                   red:particle.color.r / 2
                                                 green:particle.color.g / 2 
                                                  blue:particle.color.b / 2];
                fadeIn = [CCTintTo actionWithDuration:0.5
                                                  red:particle.color.r
                                                green:particle.color.g
                                                 blue:particle.color.b];
                seq = [CCSequence actions:fadeOut, fadeIn, nil];
                [particle runAction: [CCRepeatForever actionWithAction:seq]];
            }
            for (Particle *particle in inFlightParticles) {
                fadeOut = [CCTintTo actionWithDuration:0.5
                                                   red:particle.color.r / 2
                                                 green:particle.color.g / 2 
                                                  blue:particle.color.b / 2];
                fadeIn = [CCTintTo actionWithDuration:0.5
                                                  red:particle.color.r
                                                green:particle.color.g
                                                 blue:particle.color.b];
                seq = [CCSequence actions:fadeOut, fadeIn, nil];
                [particle runAction: [CCRepeatForever actionWithAction:seq]];
            }
            tutorialStep++;
            break;
        case 4:
            // Bonus
            instructions.string = @"Larger matches score\nbonus points.";
            instructions.position = ccp(puzzleCenter.x, winSize.height * 0.75);
            tutorialStep++;
            break;
        case 5:
            // Combos.
            instructions.string = @"Score extra points for\ncombos.";
            instructions.position = ccp(puzzleCenter.x, winSize.height * 0.75);
            tutorialStep++;
            break;
        case 6:
            // Stay inside the ring.
            for (Particle *particle in particles) {
                [particle stopAllActions];
                particle.particleColor = particle.particleColor;
            }
            for (Particle *particle in inFlightParticles) {
                [particle stopAllActions];
                particle.particleColor = particle.particleColor;
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
        case 7:
            [detector stopAllActions];
            detector.visible = NO;

            // Levels and time.
            timerLabel= [CQLabelBMFont labelWithString:@"2:00.00" fntFile:@"score.fnt"];
            timerLabel.position = ccp(winSize.width * 0.5f, winSize.height * 0.95f);
            timerLabel.color = kColorUI;
            fadeOut = [CCFadeTo actionWithDuration:0.5 opacity:0];
            fadeIn = [CCFadeTo actionWithDuration:0.5 opacity:255];
            id delay = [CCDelayTime actionWithDuration:1.0];
            seq = [CCSequence actions:fadeIn, fadeOut, delay, nil];
            id loop = [CCRepeatForever actionWithAction:seq];
            [timerLabel runAction:loop];
            [self addChild:timerLabel z:kZUIElements];
            
            levelLabel = [CQLabelBMFont labelWithString:@"Level 10"
                                                               fntFile:@"score.fnt"];
            levelLabel.position = ccp(winSize.width * 0.5f, winSize.height * 0.95f);
            levelLabel.color = kColorUI;
            levelLabel.opacity = 0;
            fadeOut = [CCFadeTo actionWithDuration:0.5 opacity:0];
            fadeIn = [CCFadeTo actionWithDuration:0.5 opacity:255];
            delay = [CCDelayTime actionWithDuration:1.0];
            seq = [CCSequence actions:delay, fadeIn, fadeOut, nil];
            loop = [CCRepeatForever actionWithAction:seq];
            [levelLabel runAction:loop];
            [self addChild:levelLabel z:kZUIElements];
            
            instructions.string = [NSString stringWithFormat:@"Every %dth match\nincreases level or\nadds time.",
                                   kMatchesPerLevel];
            instructions.position = ccp(winSize.width * 0.5, winSize.height * 0.75);
            tutorialStep++;
            break;
        case 8:
            [timerLabel removeFromParentAndCleanup:YES];
            [levelLabel removeFromParentAndCleanup:YES];
            
            // Tap to play.
            instructions.string = @"Tap to play.";
            instructions.position = ccp(winSize.width * 0.50, winSize.height * 0.25);
            tutorialStep++;
            break;
        case 9:
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
                fireButton.visible = YES;
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
                thumbGuide.visible = YES;
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
            thumbGuide.visible = NO;
            
            if (tutorialStep == 2) {
                [self scheduleOnce:@selector(tutorial)
                             delay:0.0];
            }
        }
        if (touch == launchTouch) {
            [self launch];
            
            // Forget this touch.
            launchTouch = nil;
            fireButton.visible = NO;
            
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
