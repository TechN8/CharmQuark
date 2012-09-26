//
//  IntroLayer.m
//  Test
//
//  Created by Nathan Babb on 7/10/12.
//  Copyright Aether Theory, LLC 2012. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "GameManager.h"


#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) makeTransition:(ccTime)dt
{
    [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
}

-(id)init {
    self = [super init];
    
    if (self) {
        // ask director for the window size
        CGSize size = [[CCDirector sharedDirector] winSize];
        CGSize pizelSize = [[CCDirector sharedDirector] winSizeInPixels];
        
        CCSprite *background;
        
        if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
            if (size.width == 568) {
                // iPhone 5
                background = [CCSprite spriteWithFile:@"Default-568h@2x.png"];
            } else if (size.width < pizelSize.width) {
                background = [CCSprite spriteWithFile:@"Default@2x.png"];
            } else {
                background = [CCSprite spriteWithFile:@"Default.png"];
            }
            background.rotation = -90;
        } else {
            if (size.width < pizelSize.width) {
                background = [CCSprite spriteWithFile:@"Default-Landscape@2x.png"];
            } else {
                background = [CCSprite spriteWithFile:@"Default-Landscape.png"];
            }
        }
        background.position = ccp(size.width/2, size.height/2);
        
        // add the background as a child to this Layer
        [self addChild: background];
        
        // show the copyright statement.
        NSString *copyright = @"Game and Software © 2012 Aether Theory LLC";
        //    CQLabelBMFont *label = [CQLabelBMFont labelWithString:copyright
        //                                                           fntFile:@"score.fnt"];
        CCLabelTTF *label = [CCLabelTTF labelWithString:copyright
                                               fontName:@"American Typewriter"
                                               fontSize:12.0];
        label.anchorPoint = ccp(0.5, 0.0);
        label.position = ccp(size.width / 2,
                             10);
        label.opacity = 0;
        [label runAction:[CCFadeIn actionWithDuration:0.5]];
        [self addChild:label];
        
        // In one second transition to the new scene
        [self scheduleOnce:@selector(makeTransition:) delay:2.0];
    }
    return self;
}

@end
