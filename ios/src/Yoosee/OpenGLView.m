//
//  OpenGLView.m
//  iVideoCalls
//
//  Created by Kiwaro Nigas on 12-12-4.
//  Copyright (c) 2012年 xizue.com. All rights reserved.
//

#import "OpenGLView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "Constants.h"
#import "Utils.h"
#import "P2PClient.h"

#import "AppDelegate.h"
//////////////////////////////////////////////////////////

static float flPlayVideoWidth   = 16;
static float flPlayVideoHeight  = 16;
static float flPlayVideoLineSize  = 16;

#pragma mark - shaders

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

NSString *const vertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec2 texcoord;
 uniform mat4 modelViewProjectionMatrix;
 varying vec2 v_texcoord;
 
 void main()
 {
     gl_Position = modelViewProjectionMatrix * position;
     v_texcoord = texcoord.xy;
 }
 );

NSString *const rgbFragmentShaderString = SHADER_STRING
(
 varying highp vec2 v_texcoord;
 uniform sampler2D s_texture;
 
 void main()
 {
     gl_FragColor = texture2D(s_texture, v_texcoord);
 }
 );

NSString *const yuvFragmentShaderString = SHADER_STRING
(
 varying highp vec2 v_texcoord;
 uniform sampler2D s_texture_y;
 uniform sampler2D s_texture_u;
 uniform sampler2D s_texture_v;
 
 void main()
 {
     highp float y = texture2D(s_texture_y, v_texcoord).r;
     highp float u = texture2D(s_texture_u, v_texcoord).r - 0.5;
     highp float v = texture2D(s_texture_v, v_texcoord).r - 0.5;
     
     highp float r = y +             1.4075 * v;
     highp float g = y - 0.3455 * u - 0.7169 * v;
     highp float b = y + 1.779 * u;
     
     gl_FragColor = vec4(r,g,b,1.0);
 }
 );

static BOOL validateProgram(GLuint prog)
{
    GLint status;
    
    glValidateProgram(prog);
    
#ifdef DEBUG
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        //DLog(@"Program validate log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == GL_FALSE) {
        //DLog(@"Failed to validate program %d", prog);
        return NO;
    }
    
    return YES;
}

static GLuint compileShader(GLenum type, NSString *shaderString)
{
    GLint status;
    const GLchar *sources = (GLchar *)shaderString.UTF8String;
    
    GLuint shader = glCreateShader(type);
    if (shader == 0 || shader == GL_INVALID_ENUM) {
        DLog(@"Failed to create shader %d", type);
        return 0;
    }
    
    glShaderSource(shader, 1, &sources, NULL);
    glCompileShader(shader);
    
#ifdef DEBUG
    GLint logLength;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(shader, logLength, &logLength, log);
        //DLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE) {
        glDeleteShader(shader);
        DLog(@"Failed to compile shader:\n");
        return 0;
    }
    
    return shader;
}

static void mat4f_LoadOrtho(float left, float right, float bottom, float top, float near, float far, float* mout)
{
    float r_l = right - left;
    float t_b = top - bottom;
    float f_n = far - near;
    float tx = - (right + left) / (right - left);
    float ty = - (top + bottom) / (top - bottom);
    float tz = - (far + near) / (far - near);
    
    mout[0] = 2.0f / r_l;
    mout[1] = 0.0f;
    mout[2] = 0.0f;
    mout[3] = 0.0f;
    
    mout[4] = 0.0f;
    mout[5] = 2.0f / t_b;
    mout[6] = 0.0f;
    mout[7] = 0.0f;
    
    mout[8] = 0.0f;
    mout[9] = 0.0f;
    mout[10] = -2.0f / f_n;
    mout[11] = 0.0f;
    
    mout[12] = tx;
    mout[13] = ty;
    mout[14] = tz;
    mout[15] = 1.0f;
}

//////////////////////////////////////////////////////////

#pragma mark - frame renderers

@interface OpenGLRenderer_RGB : NSObject<OpenGLRenderer>
{
    GLint _uniformSampler;
    GLuint _texture;
}
@end

@implementation OpenGLRenderer_RGB

- (BOOL) isValid
{
    return (_texture != 0);
}
- (NSString *) fragmentShader
{
    return rgbFragmentShaderString;
}

- (void) resolveUniforms: (GLuint) program
{
    _uniformSampler = glGetUniformLocation(program, "s_texture");
}

- (void) setFrame: (GAVFrame *) frame
{
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    if (0 == _texture)
        glGenTextures(1, &_texture);
    
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_RGB,
                 320,
                 240,
                 0,
                 GL_RGB,
                 GL_UNSIGNED_BYTE,
                 frame->data[0]);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

- (BOOL) prepareRender
{
    if (_texture == 0)
        return NO;
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glUniform1i(_uniformSampler, 0);
    
    return YES;
}

- (void) dealloc
{
    if (_texture) {
        glDeleteTextures(1, &_texture);
        _texture = 0;
    }
    [super dealloc];
}

@end

@interface OpenGLRenderer_YUV : NSObject<OpenGLRenderer> {
    
    GLint _uniformSamplers[3];
    GLuint _textures[3];
}
@end

@implementation OpenGLRenderer_YUV

- (BOOL) isValid
{
    return (_textures[0] != 0);
}

- (NSString *) fragmentShader
{
    return yuvFragmentShaderString;
}

- (void) resolveUniforms: (GLuint) program
{
    _uniformSamplers[0] = glGetUniformLocation(program, "s_texture_y");
    _uniformSamplers[1] = glGetUniformLocation(program, "s_texture_u");
    _uniformSamplers[2] = glGetUniformLocation(program, "s_texture_v");
}

- (void) setFrame: (GAVFrame *) yuvframe
{
    // const NSUInteger frameWidth =  yuvframe->linesize[0]; //shengming delete
    const NSUInteger frameHeight = yuvframe->height;  // yuvframe->linesize[1];   //shengming modify
    
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    if (0 == _textures[0])
        glGenTextures(3, _textures);
    
    const UInt8 *pixels[3] = { yuvframe->data[0], yuvframe->data[1], yuvframe->data[2] };
    const NSUInteger widths[3]  = { yuvframe->linesize[0], yuvframe->linesize[1], yuvframe->linesize[2] }; //shengming modify
    const NSUInteger heights[3] = { frameHeight, frameHeight / 2, frameHeight / 2 };
    
    /*
     BYTE yy[352*240];
     BYTE uu[352*240];
     BYTE vv[352*240];
     
     const UInt8 *pixels[3] = { yy, uu, vv };
     const NSUInteger widths[3]  = { 352, 352, 352 }; //shengming modify
     const NSUInteger heights[3] = { 240, 120, 120 };
     */
    
    for (int i = 0; i < 3; ++i) {
        
        glBindTexture(GL_TEXTURE_2D, _textures[i]);
        
        glTexImage2D(GL_TEXTURE_2D,
                     0,
                     GL_LUMINANCE,
                     widths[i],
                     heights[i],
                     0,
                     GL_LUMINANCE,
                     GL_UNSIGNED_BYTE,
                     pixels[i]);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }
}

- (BOOL) prepareRender
{
    if (_textures[0] == 0)
        return NO;
    
    for (int i = 0; i < 3; ++i) {
        glActiveTexture(GL_TEXTURE0 + i);
        glBindTexture(GL_TEXTURE_2D, _textures[i]);
        glUniform1i(_uniformSamplers[i], i);
    }
    
    return YES;
}

- (void) dealloc
{
    if (_textures[0])
        glDeleteTextures(3, _textures);
    [super dealloc];
}

@end
//////////////////////////////////////////////////////////

#pragma mark - gl view
GLfloat _vertices[8]= {-1.0f, -1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f};
static const GLfloat texCoords[8] = {0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f};

@implementation OpenGLView
@synthesize Initialized = _Initialized;

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

static GLfloat modelviewProj[16];


- (id)initWithCoder:(NSCoder*)coder {
    
    mat4f_LoadOrtho(-1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f, modelviewProj);//shengming
    
    if ((self = [super initWithCoder:coder])) {
        if (self) {
            DLog(@"Setup Open-GL renderer: YUV ...");
            _renderer = [[OpenGLRenderer_YUV alloc] init];
            DLog(@"OK");
            CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
            eaglLayer.opaque = YES;
            eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking,
                                            kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                            nil];
            
            _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
            
            if (!_context ||
                ![EAGLContext setCurrentContext:_context]) {
                DLog(@"failed to setup EAGLContext");
                self = nil;
                return nil;
            }
            
            glGenFramebuffers(1, &_framebuffer);
            glGenRenderbuffers(1, &_renderbuffer);
            glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
            [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
            glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
            glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
            
            GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
            if (status != GL_FRAMEBUFFER_COMPLETE) {
                
                DLog(@"failed to make complete framebuffer object %x", status);
                self = nil;
                return nil;
            }
            
            GLenum glError = glGetError();
            if (GL_NO_ERROR != glError) {
                
                DLog(@"failed to setup GL %x", glError);
                self = nil;
                return nil;
            }
            
            if (![self loadShaders]) {
                
                self = nil;
                return nil;
            }
            
            DLog(@"Open-GL setup finished");
        }
    }
    return self;
}


- (id)init
{
    
    mat4f_LoadOrtho(-1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f, modelviewProj);//shengming
    if (self = [super init]) {
        DLog(@"Setup Open-GL renderer: YUV ...");
        _renderer = [[OpenGLRenderer_YUV alloc] init];
        DLog(@"OK");
        //        [self setFrame:[[UIScreen mainScreen] bounds]];
        [self setFrame:CGRectMake(0, 0, 480, 300)];
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
        
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!_context ||
            ![EAGLContext setCurrentContext:_context]) {
            DLog(@"failed to setup EAGLContext");
            self = nil;
            return nil;
        }
        
        glGenFramebuffers(1, &_framebuffer);
        glGenRenderbuffers(1, &_renderbuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
        
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (status != GL_FRAMEBUFFER_COMPLETE) {
            
            DLog(@"failed to make complete framebuffer object %x", status);
            self = nil;
            return nil;
        }
        
        GLenum glError = glGetError();
        if (GL_NO_ERROR != glError) {
            
            DLog(@"failed to setup GL %x", glError);
            self = nil;
            return nil;
        }
        
        if (![self loadShaders]) {
            
            self = nil;
            return nil;
        }
        
        DLog(@"Open-GL setup finished");
    }
    return self;
}

- (void)dealloc
{
    
    if(self.captureFinishScreen){
        AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
        /*
         * isGoBack = YES表示应用进入后台，因为进入后台不能执行glToUIImage（OpenGL）
         * 所以，从监控画面按Home键或锁屏键回到后台时，不截图（头像图片）
         */
        if (!del.isGoBack) {
            UIImage *image = [[UIImage alloc] initWithCGImage:[self glToUIImage].CGImage];
            
            NSData *imgData = [NSData dataWithData:UIImagePNGRepresentation(image)];
            [Utils saveHeaderFileWithId:[[P2PClient sharedClient] callId] data:imgData];
            [image release];
        }
    }
    
    self.captureFinishScreen = NO;
    
    _renderer = nil;
    
    if (_framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
    
    
    if (_renderbuffer) {
        glDeleteRenderbuffers(1, &_renderbuffer);
        _renderbuffer = 0;
    }
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
    
    
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    _context = nil;
    [super dealloc];
}

- (BOOL)isvalid
{
    if (_renderer) {
        return YES;
    }
    return NO;
}

- (void)layoutSubviews
{
    DLog(@"Setup play framebuffer...");
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        
        DLog(@"failed to make complete framebuffer object %x", status);
        
    } else {
        DLog(@"OK");
        DLog(@"Width: %d Height: %d", _backingWidth, _backingHeight);
    }
    
    flPlayVideoWidth   = 16; ///shengming add  ,reset w h
    flPlayVideoHeight  = 16;
    flPlayVideoLineSize  = 16;
    // [self updateVertices]; //shengming
    if (!_Initialized)
        [self render:nil];
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentMode:contentMode];
    //[self updateVertices]; //shengming
    if (_renderer.isValid)
        if (!_Initialized)
            [self render:nil];
}

- (BOOL)loadShaders
{
    BOOL result = NO;
    GLuint vertShader = 0, fragShader = 0;
    DLog(@"Setup GL programm...");
    _program = glCreateProgram();
    
    vertShader = compileShader(GL_VERTEX_SHADER, vertexShaderString);
    if (!vertShader)
        goto exit;
    
    fragShader = compileShader(GL_FRAGMENT_SHADER, _renderer.fragmentShader);
    if (!fragShader)
        goto exit;
    
    glAttachShader(_program, vertShader);
    glAttachShader(_program, fragShader);
    glBindAttribLocation(_program, ATTRIBUTE_VERTEX, "position");
    glBindAttribLocation(_program, ATTRIBUTE_TEXCOORD, "texcoord");
    
    glLinkProgram(_program);
    
    GLint status;
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        DLog(@"Failed to link program %d", _program);
        goto exit;
    }
    
    result = validateProgram(_program);
    
    _uniformMatrix = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    [_renderer resolveUniforms:_program];
    
exit:
    
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    if (result) {
        
        DLog(@"OK");
        
    } else {
        
        glDeleteProgram(_program);
        _program = 0;
    }
    
    return result;
}

- (void)updateVertices
{
#if 0
    const BOOL fit      = (self.contentMode == UIViewContentModeScaleAspectFit);
    
    const float dH      = (float)_backingHeight / flPlayVideoHeight;
    const float dW      = (float)_backingWidth	/ flPlayVideoWidth;
    const float dd      = fit ? MIN(dH, dW): MAX(dH, dW);
    const float h       = (flPlayVideoHeight * dd / (float)_backingHeight);
    const float w       = (flPlayVideoWidth  * dd / (float)_backingWidth );
    float w,h;
    
    
    
    _vertices[0] = - w;
    _vertices[1] = - h;
    _vertices[2] =   w;
    _vertices[3] = - h;
    _vertices[4] = - w;
    _vertices[5] =   h;
    _vertices[6] =   w;
    _vertices[7] =   h;
    
#else
    if(flPlayVideoLineSize > flPlayVideoWidth && flPlayVideoWidth > 0 && flPlayVideoWidth > (flPlayVideoLineSize/2) )
    {
        _vertices[0] = - 1;
        _vertices[1] = - 1;
        
        _vertices[2] =   (flPlayVideoLineSize/2) /  (flPlayVideoWidth - (flPlayVideoLineSize/2));
        _vertices[3] = - 1;
        
        _vertices[4] = - 1;
        _vertices[5] =   1;
        
        _vertices[6] =   (flPlayVideoLineSize/2) /  (flPlayVideoWidth - (flPlayVideoLineSize/2));
        _vertices[7] =   1;
    }
    else
    {
        _vertices[0] = - 1;
        _vertices[1] = - 1;
        _vertices[2] =   1;
        _vertices[3] = - 1;
        _vertices[4] = - 1;
        _vertices[5] =   1;
        _vertices[6] =   1;
        _vertices[7] =   1;
    }
    
#endif
}


- (void)render:(GAVFrame *)frame
{
    [EAGLContext setCurrentContext:_context];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);//shengming del
    glViewport(0, 0, _backingWidth, _backingHeight);
    //glClearColor(0.0f, 0.0f, 0.0f, 1.0f);//shengming del ///no need , waste 2mS
    //glClear(GL_COLOR_BUFFER_BIT);//shengming del
    glUseProgram(_program);
    
    if (frame && frame->data[0]) {
        [_renderer setFrame:frame];
    } else {
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        glUseProgram(_program);
        return ;    }
    if ([_renderer prepareRender])
    {
        GLfloat modelviewProj[16];//shengming del
        mat4f_LoadOrtho(-1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f, modelviewProj);//shengming del
        
        if((frame->height != flPlayVideoHeight || frame->linesize[0] != flPlayVideoLineSize || frame->width != flPlayVideoWidth  )
           && frame->height != 0 && frame->width != 0 && flPlayVideoLineSize != 0
           ) ///shengming
        {
            
            flPlayVideoHeight = frame->height;
            flPlayVideoLineSize = frame->linesize[0];
            flPlayVideoWidth = frame->width ;
            DLog(@"%f--%f",flPlayVideoWidth,flPlayVideoHeight);
            [self updateVertices];
            
            glUniformMatrix4fv(_uniformMatrix, 1, GL_FALSE, modelviewProj);
            glVertexAttribPointer(ATTRIBUTE_VERTEX, 2, GL_FLOAT, 0, 0, _vertices);
            glEnableVertexAttribArray(ATTRIBUTE_VERTEX);
            glVertexAttribPointer(ATTRIBUTE_TEXCOORD, 2, GL_FLOAT, 0, 0, texCoords);
            glEnableVertexAttribArray(ATTRIBUTE_TEXCOORD);
        }
        
        
#if 0
        if (!validateProgram(_program))
        {
            DLog(@"Failed to validate program");
            return;
        }
#endif
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer); //shengming del
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    if(self.isScreenShotting){
        if (self.delegate && [self.delegate respondsToSelector:@selector(onScreenShotted:)]) {
            [self.delegate onScreenShotted:[self glToUIImage]];
        }
    }
    
    
    self.isScreenShotting = NO;
}

- (UIImage *)glToUIImage
{
    //NSInteger width = (NSInteger)self.frame.size.width;
    NSInteger height = (NSInteger)self.frame.size.height;
    NSInteger width =  (NSInteger)self.frame.size.width;
    
    if (flPlayVideoHeight !=0) {
        width = height*flPlayVideoWidth / flPlayVideoHeight;
    }
    
    NSInteger myDataLength = width * height * 4;
    
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    for(int y = 0; y < height; y++)
    {
        for(int x = 0; x <width * 4; x++)
        {
            //            buffer2[(height - 1 - y) * height * 4 + x] = buffer[y * 4 * height + x];
            buffer2[(height - 1 - y) * width * 4 + x] = buffer[y * 4 * width + x];
        }
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
    
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    //    int bytesPerRow = 4 * height;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // then make the uiimage from that
    UIImage *retImg = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    free(buffer);
    //free(buffer2);
    return retImg;
}

@end
