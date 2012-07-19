//
//  Particle.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/20/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "Particle.h"
#import "cocos2d.h"

@interface Particle() 
- (void) addMatchingParticlesToSet:(NSMutableSet*)particleSet 
                       requireLive:(BOOL)requireLive;
@end

@implementation Particle

@synthesize particleColor;
@synthesize streak;
@synthesize body;
@synthesize matchingParticles;
@synthesize timeSinceLastCollision;

- (BOOL) isLive {
    return touchingCount > 1;
}

- (void) touchParticle:(Particle*)particle {
    touchingCount++;
    
    if (particleColor == particle.particleColor) {
        // Put particles in eachothers node arrays.
        [matchingParticles addObject:particle];
    }
}

- (void) separateFromParticle:(Particle*)particle {
    touchingCount--;

    if (particleColor == particle.particleColor) {
        [matchingParticles removeObject:particle];
    }
}

- (void) addMatchingParticlesToSet:(NSMutableSet*)particleSet minMatch:(NSInteger) minMatch {
    [self addMatchingParticlesToSet:particleSet requireLive:YES];
    if (particleSet.count >= minMatch) {
        // Do again and add stragglers.
        [particleSet removeAllObjects];
        [self addMatchingParticlesToSet:particleSet requireLive:NO];
    }
}

- (void) addMatchingParticlesToSet:(NSMutableSet*)particleSet 
                       requireLive:(BOOL)requireLive {
    if (!requireLive || [self isLive]) {
        [particleSet addObject:self];
        for (Particle *particle in matchingParticles) {
            if (![particleSet containsObject:particle]) {
                [particle addMatchingParticlesToSet:particleSet requireLive:requireLive];
            }
        }
    }
}

+ (id) particleWithColor:(ParticleColors)color 
{
    return [[[self alloc] initWithParticleColor:color] autorelease];
}

- (id) initWithParticleColor:(ParticleColors)color 
{
    switch (color) {
        case kParticleRed:
            self = [super initWithSpriteFrameName:@"red.png"];
            break;
        case kParticleGreen:
            self = [super initWithSpriteFrameName:@"green.png"];
            break;
        case kParticleBlue:
            self = [super initWithSpriteFrameName:@"blue.png"];
            break;
        case kParticleAntiRed:
            self = [super initWithSpriteFrameName:@"antired.png"];
            break;
        case kParticleAntiGreen:
            self = [super initWithSpriteFrameName:@"antigreen.png"];
            break;
        case kParticleAntiBlue:
            self = [super initWithSpriteFrameName:@"antiblue.png"];
            break;
        case kParticleWhite:
        default:
            self = [super initWithSpriteFrameName:@"white.png"];
            break;
    }
    if (self) {
        self.particleColor = color;
        self.streak = nil;
        self.matchingParticles = [NSMutableSet setWithCapacity:6];
        self.body = NULL;
        touchingCount = 0;
        
        // Add motion streak.
        // CCMotionStreak can't be parented to batch node....  Sad.
//        CCTexture2D *texture = nil; 
//        self.streak = [CCMotionStreak streakWithFade:0.5 minSeg:3 width:2 color:ccWHITE texture: texture];
//        [self addChild:streak];
    }
    return self;
}

- (CCParticleSystemQuad *)explode {
    CCParticleSystemQuad *emitter = [[CCParticleSystemQuad alloc] initWithTotalParticles:20];
    //emitter.displayFrame = [self displayFrame];
    [emitter setTexture:self.texture withRect:self.textureRect];
    //[emitter setTexture:self.texture];
    emitter.duration = 0.1f;
    emitter.emitterMode = kCCParticleModeGravity;
    emitter.gravity = ccp(0,0);
    // Gravity Mode: speed of particles
    emitter.speed = 800;
    emitter.speedVar = 200;
    // Gravity Mode: radial
    emitter.radialAccel = 0;
    emitter.radialAccelVar = 0;
    // Gravity Mode: tagential
    emitter.tangentialAccel = 0;
    emitter.tangentialAccelVar = 0;
    emitter.angle = fmodf((float)rand(), (float)RAND_MAX/360);
    emitter.angleVar = 10;
    emitter.emissionRate = 10.0f;
    emitter.life = 0.5f;
    emitter.lifeVar = 0.2f;
    emitter.positionType = kCCPositionTypeRelative;
    emitter.position = self.position;
    emitter.posVar = CGPointZero;
    // size, in pixels
    emitter.startSize = self.contentSize.height * 0.5;
    emitter.startSizeVar = self.contentSize.height * 0.1;
    emitter.endSize = kCCParticleStartSizeEqualToEndSize;
    emitter.blendAdditive = NO;
    emitter.emissionRate = emitter.totalParticles/emitter.duration;
    
    emitter.startColor = ccc4f(1.0f, 1.0f, 1.0f, 1.0f);
    emitter.startColorVar = ccc4f(0.1f, 0.1f, 0.1f, 0.0f);
    emitter.endColor = ccc4f(0.5f, 0.5f, 0.5f, 0.0f);
    emitter.endColorVar = ccc4f(0.1f, 0.1f, 0.1f, 0.0f);
    
    emitter.autoRemoveOnFinish=YES;
//    CCNode *parent = self.parent;
//    if ([parent isKindOfClass:[CCSpriteBatchNode class]]) {
//        parent = [parent parent];
//    }
    return emitter;
}

#pragma mark -
#pragma mark CCNode

-(void)draw {
    [super draw];
    //    glPushMatrix();
    //	glTranslatef(position_.x, position_.y, 0);
    //	glEnable(GL_POINT_SMOOTH);
    //	glEnable(GL_BLEND);
    //	glBlendFunc(GL_SRC_ALPHA,
    //				GL_ONE_MINUS_SRC_ALPHA);
    //	glVertexPointer(2, GL_FLOAT, 0, pointVertex);
    //	glEnableClientState(GL_VERTEX_ARRAY);
    //	glColor4f(particleColors[3 * color],
    //			  particleColors[3 * color + 1],
    //			  particleColors[3 * color + 2],
    //			  1.0f / BLUR_COUNT);
    //	glPointSize(PARTICLE_SIZE);
    //	for (int i = 0; i < BLUR_COUNT; i++) {
    //		glPushMatrix();
    //		glRotatef(random() % 360, 0, 0, 1);
    //		glTranslatef(0, random() % VIBRATE_RADIUS, 0);
    //		glDrawArrays(GL_POINTS, 0, 4);
    //		glPopMatrix();
    //	}
    //	glPopMatrix();
}

#pragma mark -
#pragma mark NSObject

- (id)init
{
    return [self initWithParticleColor:kParticleRed];
}

- (void)dealloc
{
    [streak release];
    [matchingParticles release];
    [super dealloc];
}

@end
