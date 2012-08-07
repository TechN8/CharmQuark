//
//  Particle.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/20/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "Particle.h"
#import "cocos2d.h"
#import "RemoveFromParentAction.h"

@interface Particle() 
+ (CCParticleSystemQuad *)newExplosion;
- (void) addMatchingParticlesToSet:(NSMutableSet*)particleSet 
                       requireLive:(BOOL)requireLive;
@end

@implementation Particle

@synthesize particleColor;
@synthesize streak;
@synthesize body;
@synthesize matchingParticles;
@synthesize timeSinceLastCollision;
@synthesize isInFlight;

+ (id) particleWithColor:(ParticleColors)color 
{
    return [[[self alloc] initWithParticleColor:color] autorelease];
}

+(CCParticleSystemQuad *)newExplosion {
    CGSize s = [[CCDirector sharedDirector] winSize];
    CGFloat speed = s.width * 2;

    CCParticleSystemQuad *emitter = [CCParticleSystemQuad node];
    emitter.totalParticles = 10;
    //CCSprite *spr = [CCSprite spriteWithSpriteFrameName:@"track.png"];
    CCSpriteFrame *spf = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"white-small.png"];
    [emitter setTexture:spf.texture withRect:spf.rect];
    //[emitter setTexture:spr.texture withRect:spr.textureRect];
    //[emitter setTexture:self.texture withRect:self.textureRect];
    emitter.duration = 0.1f;
    emitter.emitterMode = kCCParticleModeGravity;
    emitter.gravity = ccp(0,0);
    // Gravity Mode: speed of particles
    
    emitter.speed = speed;
    emitter.speedVar = speed / 4;
    // Gravity Mode: radial
    emitter.radialAccel = 0;
    emitter.radialAccelVar = 0;
    // Gravity Mode: tagential
    emitter.tangentialAccel = 0;
    emitter.tangentialAccelVar = 1500;
    //Angle is OpenGL like and goes CCW.
    emitter.angle = (float)rand()/((float)RAND_MAX/360);
    emitter.angleVar = 20;
    emitter.emissionRate = emitter.totalParticles / emitter.duration;
    emitter.life = 0.4f;
    emitter.lifeVar = .2f;
    emitter.positionType = kCCPositionTypeRelative;
    emitter.posVar = CGPointZero;
    // size, in pixels
    emitter.startSize = spf.rect.size.height * 2;
    emitter.startSizeVar = 4;
    emitter.endSize = spf.rect.size.height;
    emitter.blendAdditive = YES;
    emitter.emissionRate = emitter.totalParticles/emitter.duration;
    
    //emitter.startColor = ccc4FFromccc3B(self.color);
    emitter.startColor = ccc4f(1.0, 1.0, 1.0, 1.0);
    emitter.startColorVar = ccc4f(0.0f, 0.0f, 0.0f, 0.0f);
    emitter.endColor = ccc4f(0.0f, 0.0f, 0.0f, 0.0f);  //ccc4f(1.0, 1.0, 1.0, 1.0);
    emitter.endColorVar = ccc4f(0.0f, 0.0f, 0.0f, 1.0f);
    
    emitter.autoRemoveOnFinish=YES;
    return emitter;
}

- (BOOL) isLive {
    return touchingCount > 1;
}

- (void) touchParticle:(Particle*)particle {
    touchingCount++;
    isInFlight = NO;
    
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

- (void) addMatchingParticlesToSet:(NSMutableSet*)particleSet 
                          minMatch:(NSInteger) minMatch 
                       requireLive:(BOOL)requireLive {
    [self addMatchingParticlesToSet:particleSet requireLive:requireLive];
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

- (void) setParticleColor:(ParticleColors)newColor {
    particleColor = newColor;
    switch (particleColor) {
        case kParticleRed:
            self.color = kCC3ParticleRed;
            break;
        case kParticleGreen:
            self.color = kCC3ParticleGreen;
            break;
        case kParticleBlue:
            self.color = kCC3ParticleBlue;
            break;
        case kParticleAntiRed:
            self.color = kCC3ParticleAntiRed;
            break;
        case kParticleAntiGreen:
            self.color = kCC3ParticleAntiGreen;
            break;
        case kParticleAntiBlue:
            self.color = kCC3ParticleAntiBlue;
            break;
        case kParticleWhite:
        default:
            break;
    }
}

- (id) initWithParticleColor:(ParticleColors)color 
{
    self = [super initWithSpriteFrameName:@"white.png"];
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
    
    //id tint = [CCTintTo actionWithDuration:0.1 red:255 green:255 blue:255];
    self.color = ccWHITE;
    self.scale = 1.5;
    id scale = [CCScaleTo actionWithDuration:0.1 scale:0.1];
    id remove = [RemoveFromParentAction action];
    id seq = [CCSequence actions:scale, remove, nil];
    [self runAction:scale];
    [self runAction:seq];
    
    CCParticleSystemQuad *emitter = [Particle newExplosion];
    emitter.position = self.position;
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
