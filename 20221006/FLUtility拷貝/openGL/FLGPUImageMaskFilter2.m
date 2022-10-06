//
// Created by Eric Chen on 2021/4/23.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

#import "FLGPUImageMaskFilter2.h"
#import "FLStringKit.h"
#import "FLGPUMath.h"

#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wimplicit-int-conversion"
@implementation FLGPUImageMaskFilter2 {

}

#pragma mark - Initialization and teardown

+ (NSString*) glslVertex {
    NSArray<NSString*>* code = @[
            //#version 300 es // fails
            @"attribute vec4 position;",
            // 1st input
            @"attribute vec4 inputTextureCoordinate;",
            @"varying vec2 textureCoordinate;",
            // 2nd input
            @"attribute vec4 inputTextureCoordinate2;",
            @"varying vec2 textureCoordinate2;",
            // 3rd input
            @"attribute vec4 inputTextureCoordinate3;",
            @"varying vec2 textureCoordinate3;",

            @"void main() {",
            @"  gl_Position = position;",
            @"  textureCoordinate = inputTextureCoordinate.xy;",
            @"  textureCoordinate2 = inputTextureCoordinate2.xy;",
            @"  textureCoordinate3 = inputTextureCoordinate3.xy;",
            @"}",
    ];
    return [FLStringKit join:code pre:@"" delim:@"\n" post:@""];
}

+ (NSString*) glslFragment {
    NSArray<NSString*>* code = @[
            @"precision highp float;",
            // 1st input
            @"varying vec2 textureCoordinate;",
            @"uniform sampler2D inputImageTexture;",
            // 2nd input
            @"varying vec2 textureCoordinate2;",
            @"uniform sampler2D inputImageTexture2;",
            // 3rd input
            @"varying vec2 textureCoordinate3;",
            @"uniform sampler2D inputImageTexture3;",
            // Parameters
            @"uniform int invertMask;",
            @"uniform vec4 minEmptyColor;",
            @"uniform vec4 maxEmptyColor;",
            @"uniform float minEmptyAlpha;", // ERROR: 0:19: '*' does not operate on 'int' and 'float'
            @"uniform float maxEmptyAlpha;",
            // util methods
            @"bool isIn(float v, float min, float max) { return min <= v && v <= max; }",
            @"bool isInV4(vec4 v, vec4 min, vec4 max) { return all(lessThanEqual(min, v)) && all(lessThanEqual(v, max)); }",
            // private methods
            @"bool isEmptyColor(vec4 c) {",
            @"  bool inA = isIn(c.a * 255.0, minEmptyAlpha * 255.0, maxEmptyAlpha * 255.0);",
            @"  bool inARGB = isInV4(c, minEmptyColor, maxEmptyColor);",
            @"  bool isEmpty = inA || inARGB;",
            @"  return isEmpty;",
            @"}",
            // Main
            @"void main() {",
            @"  vec4 c1 = texture2D(inputImageTexture, textureCoordinate);",
            @"  vec4 c2 = texture2D(inputImageTexture2, textureCoordinate2);",
            @"  vec4 mask = texture2D(inputImageTexture3, textureCoordinate3);",
            @"  vec4 color = vec4(1.0);",
            @"  bool isEmpty = isEmptyColor(mask);",
            @"  if (invertMask != 0) {",
            @"      isEmpty = !isEmpty;"
            @"  }",
            @"  if (isEmpty) {",
            @"      color = c1;",
            @"  } else {",
            @"      color = c2;",
            @"  }",
            @"  gl_FragColor = color;",// * mask?
            @"}",
    ];
    return [FLStringKit join:code pre:@"" delim:@"\n" post:@""];
}

- (instancetype)init {
    NSString *vertex = [FLGPUImageMaskFilter2 glslVertex];
    NSString *fragment = [FLGPUImageMaskFilter2 glslFragment];
//    qwe("vertex   = \n%s", ssString(vertex));
//    qwe("fragment = \n%s", ssString(fragment));
    self = [super initWithVertexShaderFromString:vertex fragmentShaderFromString:fragment];
    [self defaultParam];
    return self;
}

- (void) defaultParam {
    self.minEmptyColor = 0xFF000000;
    self.maxEmptyColor = 0xFF808080;
    self.minEmptyAlpha = 0;
    self.maxEmptyAlpha = 5;
    self.invertMask = false;
}

- (void) setupParameters {
    GPUVector4 v;
    // empty color
    v = [FLGPUMath toArgb:self.minEmptyColor];
    [self setFloatVec4:v forUniform:@"minEmptyColor"];
    v = [FLGPUMath toArgb:self.maxEmptyColor];
    [self setFloatVec4:v forUniform:@"maxEmptyColor"];

    GLfloat f;
    // empty alpha
    f = (GLfloat) (self.minEmptyAlpha / 255.0);
    [self setFloat:f forUniformName:@"minEmptyAlpha"];
    f = (GLfloat) (self.maxEmptyAlpha / 255.0);
    [self setFloat:f forUniformName:@"maxEmptyAlpha"];

    GLint inv = self.invertMask ? 1 : 0;
    [self setInteger:inv forUniformName:@"invertMask"];
}

#pragma mark - Managing rendering

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    [self setupParameters];
    [super renderToTextureWithVertices:vertices textureCoordinates:textureCoordinates];
}

@end
#pragma clang diagnostic pop
