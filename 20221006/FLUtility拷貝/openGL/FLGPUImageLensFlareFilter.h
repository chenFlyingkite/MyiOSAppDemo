#import "GPUImageTwoInputFilter.h"

@interface FLGPUImageLensFlareFilter : GPUImageTwoInputFilter {
    // parameters
    GLfloat mAlpha;
    GLfloat mCenterX;
    GLfloat mCenterY;
    GLfloat mDegree;
    GLfloat mScale;
    GLfloat mDesktopWidth;
    GLfloat mDesktopHeight;
    GLfloat mStickerWidth;
    GLfloat mStickerHeight;
    int mStickerFlip;
}


/*
typedef enum {
    LENS_FLARE_NORMAL,
    LENS_FLARE_SCREEN,
    LENS_FLARE_MULTIPLY,
    LENS_FLARE_HARDLIGHT,
    LENS_FLARE_OVERLAY,
    LENS_FLARE_SOFTLIGHT,
    LENS_FLARE_LIGHTEN,
    LENS_FLARE_DARKEN,
    LENS_FLARE_DIFFERENCE,
    LENS_FLARE_HUE,
    LENS_FLARE_COLOR,
    LENS_FLARE_LUMINOSITY,
    LENS_FLARE_SATURATION,
    LENS_FLARE_VIVIDLIGHT,
    LENS_FLARE_SUBTRACT,
    LENS_FLARE_PINLIGHT,
    LENS_FLARE_LINEARLIGHT,
    LENS_FLARE_LINEARDODGE,
    LENS_FLARE_LINEARBURN,
    LENS_FLARE_LIGHTERCOLOR,
    LENS_FLARE_HARDMIX,
    LENS_FLARE_EXCLUSION,
    LENS_FLARE_DIVIDE,
    LENS_FLARE_DARKERCOLOR,
    LENS_FLARE_COLORDODGE,
    LENS_FLARE_COLORBURN
} LensFlareBlendTypes;
*/

@property (nonatomic) float stickerAlpha;
@property (nonatomic) float stickerCenterX;
@property (nonatomic) float stickerCenterY;
@property (nonatomic) float stickerDegree;
@property (nonatomic) float stickerScale;

// FLFlip_NO_FLIP = 0, // No flip
// FLFlip_FLIP_X  = 1, // bd-flip / pq-flip
// FLFlip_FLIP_Y  = 2, // bp-flip / dq-flip
// FLFlip_FLIP_XY = 3, // bq-flip / pd-flip
@property (nonatomic) int stickerFlip;

- (CGSize) getStickerSize;

@end
