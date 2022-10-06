#import "FLGPUImageSimple2DFilter.h"
#import "FLUtil.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wimplicit-int-conversion"

@interface FLGPUImageSimple2DFilter() {}

@property (nonatomic) float stickerWidth;
@property (nonatomic) float stickerHeight;

@end

@implementation FLGPUImageSimple2DFilter {
    bool log;
    FLTicTac *clock;
}

// Shader codes : put image as a sticker on desktop with given places

+ (NSString*) glslVertex {
    NSArray<NSString*>* code = @[
        @"attribute vec4 position;",
        @"attribute vec4 inputTextureCoordinate;",
        @"varying vec2 textureCoordinate;",

        @"void main() {",
        @"  gl_Position = position;",
        @"  textureCoordinate = inputTextureCoordinate.xy;",
        @"}",
    ];
    return [FLStringKit join:code pre:@"" delim:@"\n" post:@""];
}

+ (NSString*) glslFragment {
    NSArray<NSString*>* code = @[
        @"precision highp float;",
        @"varying vec2 textureCoordinate;",
        @"uniform sampler2D inputImageTexture;",

        // Parameters
        @"uniform float alpha;",
        @"uniform float scale;",
        @"uniform float centerX;",
        @"uniform float centerY;",
        @"uniform float sinDegree;",
        @"uniform float cosDegree;",
        @"uniform float stickerWidth;",
        @"uniform float stickerHeight;",
        @"uniform float desktopWidth;",
        @"uniform float desktopHeight;",
        @"uniform int flip;",
        @"uniform vec4 backColor;",

        // Utility methods
        @"int isIn(float v, float min, float max) { return (min <= v && v <= max) ? 1 : 0; }",
        @"int isIn0101(vec2 p) {  int inX = isIn(p.x, 0.0, 1.0);  int inY = isIn(p.y, 0.0, 1.0);  return inX * inY;  }",

        // Main
        @"void main() {",
//     vec4 desktop = texture2D(inputImageTexture, textureCoordinate);
//     vec4 sticker = texture2D(inputImageTexture2, textureCoordinate2);
        @"  vec4 desktop = backColor;",
        @"  vec4 sticker = texture2D(inputImageTexture, textureCoordinate);",

        @"  if (scale <= 0.0 || stickerWidth <= 0.0 || stickerHeight <= 0.0) {",
        @"    gl_FragColor = desktop;",
        @"    return;",
        @"  }",
        // DW = desktopWidth  , mW = stickerWidth  , cx = centerX of sticker
        // DH = desktopHeight , mH = stickerHeight , cy = centerY of sticker
        // (x, y) = (0 ~ 1) in Sticker
        // Let imageCoord be the screen ( so imageCoord.x = [0, DW], imageCoord.y = [0, DH])
        // gl_FragCoord.x = imageCoord.x / DW
        // gl_FragCoord.y = imageCoord.y / DH
        // we have
        // imageCoord.x = [fx] = [cx * DW] + [cos(d), -sin(d)] * s * [mW] * ([x] - [1/2])
        // imageCoord.y   [fy]   [cy * DH]   [sin(d),  cos(d)]       [mH]   ([y]   [1/2])
        // gl_FragCoord.x = x/DW = cx + s * mW / DW * (x - 1/2)
        // gl_FragCoord.y = y/DH = cy + s * mH / DH * (y - 1/2)
        //
        // for fx = cx * DW + s * mW * (x - 1/2)  (fx = [0, DW])
        // for fy = cy * DH + s * mW * (y - 1/2)  (fy = [0, DH])
        // => x = [1/2] + 1/s * [ cos(d), sin(d)] * ([fx] - [cx * mW * DW])
        // => y = [1/2]         [-sin(d), cos(d)]   ([fy] - [cy * mH * DH])
        @"  float imageWidth = scale * stickerWidth;",
        @"  float imageHeight = scale * stickerHeight;",

        // f.xy = fragment's x, y, range = 0~ DW/DH
        @"  float fx = textureCoordinate.x;",
        @"  float fy = textureCoordinate.y;",

        // this lines did not draw
        //fx = gl_FragCoord.x;
        //fy = gl_FragCoord.y;

        @"  float xInDesktop = (fx - centerX) * desktopWidth;",
        @"  float yInDesktop = (fy - centerY) * desktopHeight;",

        // rotate degree back as xInSticker
        @"  vec2 inSticker;",
        @"  inSticker.x = (+cosDegree * xInDesktop + sinDegree * yInDesktop) / imageWidth + 0.5;",
        @"  inSticker.y = (-sinDegree * xInDesktop + cosDegree * yInDesktop) / imageHeight + 0.5;",
        // flip coordinate
        @"  if (flip == 1 || flip == 3) {",
        @"    inSticker.x = 1.0 - inSticker.x;",
        @"  }",
        @"  if (flip == 2 || flip == 3) {",
        @"    inSticker.y = 1.0 - inSticker.y;",
        @"  }",

        @"  vec4 ans;",
        @"  if (isIn0101(inSticker) > 0) {",
        @"    vec4 sticker = texture2D(inputImageTexture, inSticker);",
        @"    ans = sticker;",
        //@"    ans = vec4(sticker.rgb, 0.5);",
        @"  } else {",
        @"    ans = desktop;",
        @"  }",
        @"  gl_FragColor = ans;",
        @"}",
    ];
    return [FLStringKit join:code pre:@"" delim:@"\n" post:@""];
}

#pragma mark -
#pragma mark Initialization and teardown

- (instancetype) init {
    clock = [FLTicTac new];
    log = false;

    NSString *vertex = [FLGPUImageSimple2DFilter glslVertex];
    NSString *fragment = [FLGPUImageSimple2DFilter glslFragment];
    self = [super initWithVertexShaderFromString:vertex fragmentShaderFromString:fragment];

    [self setDefaultValues];
    return self;
}

- (void) setDefaultValues {
    self.desktopWidth = 0;
    self.desktopHeight = 0;

    self.stickerFlip = 0;
    self.stickerAlpha = 1;
    self.stickerScale = 1;
    self.stickerWidth = 0;
    self.stickerHeight = 0;
    self.stickerDegree = 0;
    self.stickerCenterX = 0.5;
    self.stickerCenterY = 0.5;
    self.backgroundColor = 0; // transparent
}

#pragma mark -
#pragma mark Managing rendering

- (CGSize)outputFrameSize {
    return CGSizeMake(_desktopWidth, _desktopHeight);
}

- (void)setupFilterForSize:(CGSize)filterFrameSize {
    [super setupFilterForSize:filterFrameSize];
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    if (log) {
        qwe("setInputSize #%ld = %s", textureIndex, ssCGSize(newSize));
    }
    // Use output size as frame buffer size to prevent blurry image when image is very wide or very long (like w / h > 3)
    // also prevent image blinking when moving position (stickerCenterX, stickerCenterY)
    //
    // These are especially visible when image is long and has light dots on dark background
    // Test image is in /Resource/Images/SurrealArt/surreal_art_sample_source@1x.jpg
    //
    // See GPUImageFilter#inputTextureSize, GPUImageFilter#renderToTextureWithVertices(::),
    // and code : outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    CGSize processSize = CGSizeMake(_desktopWidth, _desktopHeight);
    [super setInputSize:processSize atIndex:textureIndex];

    // setup sizes of sticker and desktop
    if (textureIndex == 0) {
        CGSize z = newSize;
        self.stickerWidth = z.width;
        self.stickerHeight = z.height;
        if (self.desktopWidth <= 0) {
            self.desktopWidth = z.width;
        }
        if (self.desktopHeight <= 0) {
            self.desktopHeight = z.height;
        }
    }
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    [self setParameters];
    if (log) {
        [self logAll];
        [clock tic];
    }
    [super renderToTextureWithVertices:vertices textureCoordinates:textureCoordinates];
    if (log) {
        [clock tac:@"now render ok ,%s", ssString([FLStringKit now])];
        qwe("render done %s", "");
    }
}

#pragma mark -
#pragma mark Parameters

- (void) setParameters {
    [self flip:self.stickerFlip];
    [self alpha:self.stickerAlpha];
    [self scale:self.stickerScale];
    [self degree:self.stickerDegree];
    [self centerX:self.stickerCenterX];
    [self centerY:self.stickerCenterY];
    [self backColor:self.backgroundColor];
    [self stickerWidth:self.stickerWidth height:self.stickerHeight];
    [self desktopWidth:self.desktopWidth height:self.desktopHeight];
}

- (void)backColor:(long)argb {
    int a = (argb >> 24) & 0xFF;
    int r = (argb >> 16) & 0xFF;
    int g = (argb >>  8) & 0xFF;
    int b = (argb >>  0) & 0xFF;
    GPUVector4 v = (GPUVector4) {r / 255.0, g / 255.0, b / 255.0, a / 255.0};
    [self setFloatVec4:v forUniform:@"backColor"];
}

- (void) logAll {
    qw("a =  %.2f,   deg = %.2f,   (cx, cy) = (%.3f, %.3f),   s = %.2f",
            _stickerAlpha , _stickerDegree, _stickerCenterX, _stickerCenterY, _stickerScale);
    qw("desktop = (%7.2f, %7.2f), sticker = (%7.2f, %7.2f)", _desktopWidth, _desktopHeight, _stickerWidth, _stickerHeight);
}

- (void)alpha:(float)alpha {
    [self setFloat:alpha forUniformName:@"alpha"];
}

- (void) centerX:(float)cx {
    [self setFloat:cx forUniformName:@"centerX"];
}

- (void) centerY:(float)cy {
    [self setFloat:cy forUniformName:@"centerY"];
}

- (void) scale:(float)scale {
    [self setFloat:scale forUniformName:@"scale"];
}

- (void) degree:(float)degree {
    double rad = degToRad(degree);
    float sind = (float) sin(rad);
    float cosd = (float) cos(rad);
    [self setFloat:sind forUniformName:@"sinDegree"];
    [self setFloat:cosd forUniformName:@"cosDegree"];
}

- (void) flip:(int)flip {
    [self setInteger:flip forUniformName:@"flip"];
}

- (void) stickerWidth:(float)width height:(float)height {
    [self setFloat:width  forUniformName:@"stickerWidth"];
    [self setFloat:height forUniformName:@"stickerHeight"];
}

- (void) desktopWidth:(float)width height:(float)height {
    [self setFloat:width  forUniformName:@"desktopWidth"];
    [self setFloat:height forUniformName:@"desktopHeight"];
}
 
@end

#pragma clang diagnostic pop
