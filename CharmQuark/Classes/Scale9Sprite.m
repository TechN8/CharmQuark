//
//  Scale9Sprite.m
//
//  Creates a 9-slice sprite.




#import "Scale9Sprite.h"

@implementation Scale9Sprite

@synthesize top, color, opacity;

@synthesize displayedColor, displayedOpacity, cascadeColorEnabled, cascadeOpacityEnabled;

enum positions {
pCentre = 0,
pTop,
pLeft,
pRight,
pBottom,
pTopRight,
pTopLeft,
pBottomRight,
pBottomLeft
};	

CGSize baseSize;
CGRect resizableRegion;


/*
 * Need to allow to init with ratios.
 */

-(void)setCenterRegion: (CGRect)centreRegion {
    CGSize imageSize = scale9Image.texture.contentSize;

    //Set up centre sprite
    centre = [[CCSprite alloc] initWithTexture:scale9Image.texture rect:centreRegion];
    [scale9Image addChild:centre z:0 tag:pCentre];
    
    rect_ = CGRectMake(0, 0, imageSize.width, imageSize.height);
    
    float l = rect_.origin.x;
    float t = rect_.origin.y;
    float h = rect_.size.height;
    float w = rect_.size.width;
    
    //top
    top = [[CCSprite alloc]
           initWithTexture:scale9Image.texture
           rect:CGRectMake(centreRegion.origin.x,
                           t,
                           centreRegion.size.width,
                           centreRegion.origin.y-t)
           ];
    
    [scale9Image addChild:top z:1 tag:pTop];
    
    
    
    //bottom
    bottom = [[CCSprite alloc]
              initWithTexture:scale9Image.texture
              rect:CGRectMake(centreRegion.origin.x,
                              centreRegion.origin.y + centreRegion.size.height,
                              centreRegion.size.width,
                              h - (centreRegion.origin.y - t + centreRegion.size.height))
              ];
    
    [scale9Image addChild:bottom z:1 tag:pBottom];
    
    //left
    left = [[CCSprite alloc]
            initWithTexture:scale9Image.texture
            rect:CGRectMake(l,
                            centreRegion.origin.y,
                            centreRegion.origin.x - l,
                            centreRegion.size.height)
            ];
    
    [scale9Image addChild:left z:1 tag:pLeft];
    
    //right
    right = [[CCSprite alloc]
             initWithTexture:scale9Image.texture
             rect:CGRectMake(centreRegion.origin.x + centreRegion.size.width,
                             centreRegion.origin.y,
                             w - (centreRegion.origin.x - l + centreRegion.size.width),
                             centreRegion.size.height)
             ];
    
    [scale9Image addChild:right z:1 tag:pRight];
    
    //top left
    topLeft = [[CCSprite alloc]
               initWithTexture:scale9Image.texture
               rect:CGRectMake(l,
                               t,
                               centreRegion.origin.x - l,
                               centreRegion.origin.y - t)
               ];
    
    [scale9Image addChild:topLeft z:2 tag:pTopLeft];
    
    
    //top right
    topRight = [[CCSprite alloc]
                initWithTexture:scale9Image.texture
                rect:CGRectMake(centreRegion.origin.x + centreRegion.size.width,
                                t,
                                w - (centreRegion.origin.x - l + centreRegion.size.width),
                                centreRegion.origin.y - t)
                ];
    
    [scale9Image addChild:topRight z:2 tag:pTopRight];
    
    //bottom left
    bottomLeft = [[CCSprite alloc]
                  initWithTexture:scale9Image.texture
                  rect:CGRectMake(l,
                                  centreRegion.origin.y + centreRegion.size.height,
                                  centreRegion.origin.x - l,
                                  h - (centreRegion.origin.y - t + centreRegion.size.height))
                  ];
    
    [scale9Image addChild:bottomLeft z:2 tag:pBottomLeft];
    
    //bottom right
    bottomRight = [[CCSprite alloc]
                   initWithTexture:scale9Image.texture
                   rect:CGRectMake(centreRegion.origin.x + centreRegion.size.width,
                                   centreRegion.origin.y + centreRegion.size.height,
                                   w - (centreRegion.origin.x - l + centreRegion.size.width),
                                   h - (centreRegion.origin.y - t + centreRegion.size.height))
                   ];
    
    [scale9Image addChild:bottomRight z:2 tag:pBottomRight];
    
    
    
    baseSize = imageSize;
    resizableRegion = centreRegion;
    [self setContentSize:imageSize];
}

-(id) initWithFile:(NSString*)file ratioX:(CGFloat)ratioX ratioY:(CGFloat)ratioY {
    
	if( (self=[super init]) ) {
        
        _anchorPoint = ccp(0.5f,0.5f);
        
		scale9Image = [[CCSpriteBatchNode alloc] initWithFile:file capacity:9];
        
        CGSize imageSize = scale9Image.texture.contentSize;
        
        // Center region
        CGRect centreRegion = CGRectMake(ratioX * imageSize.width,
                                         ratioY * imageSize.height,
                                         imageSize.width - 2 * ratioX * imageSize.width, 
                                         imageSize.height - 2 * ratioY * imageSize.height);

        [self setCenterRegion:centreRegion];
        
		[self addChild:scale9Image];
        
	}
	return self;
}	

-(id) initWithFile:(NSString*)file centreRegion:(CGRect)centreRegion {
    
	if( (self=[super init]) ) {
        
        _anchorPoint = ccp(0.5f,0.5f);
        
		scale9Image = [[CCSpriteBatchNode alloc] initWithFile:file capacity:9];
        
        [self setCenterRegion:centreRegion];
        
		[self addChild:scale9Image];
        
	}
	return self;
}	

-(void) dealloc
{
    
	[topLeft release];
	[top release];
	[topRight release];
	[left release];
	[centre release];
	[right release];
	[bottomLeft release];
	[bottom release];
	[bottomRight release];
	[scale9Image release];
	[super dealloc];
}	




-(void) setContentSize:(CGSize)size
{
    
    
	[super setContentSize:size];
    
    
	float sizableWidth = size.width - topLeft.contentSize.width - topRight.contentSize.width;
	float sizableHeight = size.height - topLeft.contentSize.height - bottomRight.contentSize.height;
	float horizontalScale = sizableWidth/centre.contentSize.width;
	float verticalScale = sizableHeight/centre.contentSize.height;
    
    
    
    
	centre.scaleX = horizontalScale;
	centre.scaleY = verticalScale;
    
    
	float rescaledWidth = centre.contentSize.width * horizontalScale;
	float rescaledHeight = centre.contentSize.height * verticalScale;
    
	//Position corners
    //[self setAnchorPoint:CGPointMake(0.5f,0.5f)];
    
    float despx = size.width*0.5f;
    float despy = size.height*0.5f;
    
    
    
    //Position corners
    [topLeft setPosition:CGPointMake(-rescaledWidth/2 - topLeft.contentSize.width/2 +despx, rescaledHeight/2 + topLeft.contentSize.height*0.5 + despy) ];
    
    
    
    [topRight setPosition:CGPointMake(rescaledWidth/2 + topRight.contentSize.width/2 +despx, rescaledHeight/2 + topRight.contentSize.height*0.5 + despy)];
    [bottomLeft setPosition:CGPointMake(-rescaledWidth/2 - bottomLeft.contentSize.width/2 + despx, -rescaledHeight/2 - bottomLeft.contentSize.height*0.5 + despy)];
    [bottomRight setPosition:CGPointMake(rescaledWidth/2 + bottomRight.contentSize.width/2 + despx, -rescaledHeight/2 + -bottomRight.contentSize.height*0.5 + despy)];
    top.scaleX = horizontalScale;
    [top setPosition:CGPointMake(0+despx,rescaledHeight/2 + topLeft.contentSize.height*0.5 + despy)];
    bottom.scaleX = horizontalScale;
    [bottom setPosition:CGPointMake(0+despx,-rescaledHeight/2 - bottomLeft.contentSize.height*0.5 + despy)];
    left.scaleY = verticalScale;
    [left setPosition:CGPointMake(-rescaledWidth/2 - topLeft.contentSize.width/2 +despx, 0 + despy)];
    right.scaleY = verticalScale;
    [right setPosition:CGPointMake(rescaledWidth/2 + topRight.contentSize.width/2 +despx, 0 + despy)];
    [centre setPosition:CGPointMake(despx, despy)];
    
}

-(void) setColor:(ccColor3B)aColor {
    color = aColor;
    topLeft.color = color;
	top.color = color;
	topRight.color = color;
	left.color = color;
	centre.color = color;
	right.color = color;
	bottomLeft.color = color;
	bottom.color = color;
	bottomRight.color = color;
}

-(void) setOpacity:(GLubyte)theOpacity {
    opacity = theOpacity;
    topLeft.opacity = opacity;
	top.opacity = opacity;
	topRight.opacity = opacity;
	left.opacity = opacity;
	centre.opacity = opacity;
	right.opacity = opacity;
	bottomLeft.opacity = opacity;
	bottom.opacity = opacity;
	bottomRight.opacity = opacity;
}

- (void)updateDisplayedColor:(ccColor3B)aColor {
    [self setColor: color];
}

- (void)updateDisplayedOpacity:(GLubyte)theOpacity {
    [self setOpacity:theOpacity];
}


-(void) draw {
	[scale9Image draw];
}	

@end
