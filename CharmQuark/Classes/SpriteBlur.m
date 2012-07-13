//
//  SpriteBlur.m
//  CharmQuark
//
//  Created by Nathan Babb on 7/12/12.
//  Copyright 2012 Aether Theory, LLC. All rights reserved.
//

#import "SpriteBlur.h"

@implementation SpriteBlur
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	if( (self=[super initWithTexture:texture rect:rect]) ) {
        
		CGSize s = [texture_ contentSizeInPixels];
        
		blur_ = ccp(1/s.width, 1/s.height);
		sub_[0] = sub_[1] = sub_[2] = sub_[3] = 0;
        
		GLchar * fragSource = (GLchar*) [[NSString stringWithContentsOfFile:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"example_Blur.fsh"] encoding:NSUTF8StringEncoding error:nil] UTF8String];
		shaderProgram_ = [[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureColor_vert fragmentShaderByteArray:fragSource];
        
        
		CHECK_GL_ERROR_DEBUG();
        
		[shaderProgram_ addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
		[shaderProgram_ addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
		[shaderProgram_ addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
        
		CHECK_GL_ERROR_DEBUG();
        
		[shaderProgram_ link];
        
		CHECK_GL_ERROR_DEBUG();
        
		[shaderProgram_ updateUniforms];
        
		CHECK_GL_ERROR_DEBUG();
        
		subLocation = glGetUniformLocation( shaderProgram_->program_, "substract");
		blurLocation = glGetUniformLocation( shaderProgram_->program_, "blurSize");
        
		CHECK_GL_ERROR_DEBUG();
	}
    
	return self;
}

-(void) draw
{
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex );
	ccGLBlendFunc( blendFunc_.src, blendFunc_.dst );
    
	[shaderProgram_ use];
	[shaderProgram_ setUniformForModelViewProjectionMatrix];
	[shaderProgram_ setUniformLocation:blurLocation withF1:blur_.x f2:blur_.y];
	[shaderProgram_ setUniformLocation:subLocation with4fv:sub_ count:1];
    
	ccGLBindTexture2D(  [texture_ name] );
    
	//
	// Attributes
	//
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
	
	CC_INCREMENT_GL_DRAWS(1);
}

-(void) setBlurSize:(CGFloat)f
{
	CGSize s = [texture_ contentSizeInPixels];
    
	blur_ = ccp(1/s.width, 1/s.height);
	blur_ = ccpMult(blur_,f);
}

@end

