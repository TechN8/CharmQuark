//
//  Particle.m
//  CharmQuark
//
//  Created by Nathan Babb on 6/20/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "Particle.h"
#import "cocos2d.h"

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

- (void) addMatchingParticlesToSet:(NSMutableSet*)particleSet addTime:(ccTime)time {
    if ([self isLive]) {
        [particleSet addObject:self];
        for (Particle *particle in matchingParticles) {
            if (![particleSet containsObject:particle]) {
                [particle addMatchingParticlesToSet:particleSet addTime:time];
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
        case kParticleWhite:
            self = [super initWithSpriteFrameName:@"White.png"];
            break;
        case kParticleRed:
            self = [super initWithSpriteFrameName:@"Red.png"];
            break;
        case kParticleOrange:
            self = [super initWithSpriteFrameName:@"Orange.png"];
            break;
        case kParticleYellow:
            self = [super initWithSpriteFrameName:@"Yellow.png"];
            break;
        case kParticleGreen:
            self = [super initWithSpriteFrameName:@"Green.png"];
            break;
        case kParticleBlue:
            self = [super initWithSpriteFrameName:@"Blue.png"];
            break;
        case kParticleIndigo:
            self = [super initWithSpriteFrameName:@"Indigo.png"];
            break;
        case kParticleViolet:
            self = [super initWithSpriteFrameName:@"Violet.png"];
            break;
        case kParticleBlack:
            self = [super initWithSpriteFrameName:@"Black.png"];
            break;
        default:
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

#pragma mark -
#pragma mark CCNode

//-(void)draw {
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
//}

-(void)draw {
	CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, @"CCSprite - draw");
    
	NSAssert(!batchNode_, @"If CCSprite is being rendered by CCSpriteBatchNode, CCSprite#draw SHOULD NOT be called");
    
	CC_NODE_DRAW_SETUP();
    
	ccGLBlendFunc( blendFunc_.src, blendFunc_.dst );
    
	ccGLBindTexture2D( [texture_ name] );
    
	//
	// Attributes
	//
    
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );
    
#define kQuadSize sizeof(quad_.bl)
	long offset = (long)&quad_;
    
	// vertex
	NSInteger diff = offsetof( ccV3F_C4B_T2F, vertices);
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*) (offset + diff));
    
	// texCoods
	diff = offsetof( ccV3F_C4B_T2F, texCoords);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));
    
	// color
	diff = offsetof( ccV3F_C4B_T2F, colors);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));
    
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
	CHECK_GL_ERROR_DEBUG();
    
    
#if CC_SPRITE_DEBUG_DRAW == 1
	// draw bounding box
	CGPoint vertices[4]={
		ccp(quad_.tl.vertices.x,quad_.tl.vertices.y),
		ccp(quad_.bl.vertices.x,quad_.bl.vertices.y),
		ccp(quad_.br.vertices.x,quad_.br.vertices.y),
		ccp(quad_.tr.vertices.x,quad_.tr.vertices.y),
	};
	ccDrawPoly(vertices, 4, YES);
#elif CC_SPRITE_DEBUG_DRAW == 2
	// draw texture box
	CGSize s = self.textureRect.size;
	CGPoint offsetPix = self.offsetPosition;
	CGPoint vertices[4] = {
		ccp(offsetPix.x,offsetPix.y), ccp(offsetPix.x+s.width,offsetPix.y),
		ccp(offsetPix.x+s.width,offsetPix.y+s.height), ccp(offsetPix.x,offsetPix.y+s.height)
	};
	ccDrawPoly(vertices, 4, YES);
#endif // CC_SPRITE_DEBUG_DRAW
    
	CC_INCREMENT_GL_DRAWS(1);
    
	CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, @"CCSprite - draw");
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
