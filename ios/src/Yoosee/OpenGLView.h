//
//  OpenGLView.h
//  iVideoCalls
//
//  Created by Kiwaro Nigas on 12-12-4.
//  Copyright (c) 2012年 xizue.com. All rights reserved.
//

#import "P2PCInterface.h"
#define g_w 352
#define g_h 240

enum {
	ATTRIBUTE_VERTEX,
   	ATTRIBUTE_TEXCOORD,
};

@protocol OpenGLRenderer
- (BOOL) isValid;
- (NSString *) fragmentShader;
- (void) resolveUniforms: (GLuint) program;
- (void) setFrame:(GAVFrame *)yuvFrame;
- (BOOL) prepareRender;
@end

@protocol OpenGLViewDelegate <NSObject>
-(void)onScreenShotted:(UIImage*)image;
@end

@interface OpenGLView : UIView
{
    EAGLContext     *_context;
    GLuint          _framebuffer;
    GLuint          _renderbuffer;
    GLint           _backingWidth;
    GLint           _backingHeight;
    GLuint          _program;
    GLint           _uniformMatrix;
    
    id<OpenGLRenderer> _renderer;
}
@property (nonatomic) BOOL Initialized;
@property (nonatomic) BOOL isScreenShotting;
@property (nonatomic) BOOL captureFinishScreen;
@property (assign) id<OpenGLViewDelegate> delegate;
- (BOOL)isvalid;
- (void)render:(GAVFrame *)frame;
- (UIImage *)glToUIImage;

@end

