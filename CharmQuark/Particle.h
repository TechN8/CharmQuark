//
//  Particle.h
//  CharmQuark
//
//  Created by Nathan Babb on 6/20/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "GameObject.h"
#import "cocos2d.h"
#import "chipmunk.h"

typedef enum {
    kParticleUpQuark = 1,
    kParticleDownQuark,
    kParticleTopQuark,
    kParticleBottomQuark,
    kParticleCharmQuark,
    kParticleStrangeQuark,
} ParticleTypes;

@interface Particle : GameObject {
    
}

@end
