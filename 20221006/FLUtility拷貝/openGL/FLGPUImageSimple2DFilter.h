#import "GPUImageFilter.h"

/**
 * It is very similar with GPUImageTransformFilter
 * Place image into a place (of background color) with scale, center (X, Y), degree and alpha
 * This filter makes image as normal rotated rectangle (has no skew or other shapes of quadrilateral)
 * , so we call it is simplest 2D transform.
 *
 * So given image (500x700) as sticker (1st input), we place it in our desktop
 * assume (desktopWidth, desktopHeight) = (1000, 1400),
 * sticker(centerX, centerY) = (0.25, 0.25) makes image at left-top corner
 * sticker(centerX, centerY) = (1.0, 0.5), scale = 2, makes image at right-half part
 * scale = 1 is image's same size
 * scale = desktopWidth / image.width makes it will be same width as desktop
 * centerX/Y = 0 => left/top of desktop
 * centerX/Y = 1 => right/bottom of desktop
 */
@interface FLGPUImageSimple2DFilter : GPUImageFilter { }

@property (nonatomic) float stickerAlpha;
@property (nonatomic) float stickerCenterX;
@property (nonatomic) float stickerCenterY;
@property (nonatomic) float stickerDegree;
@property (nonatomic) float stickerScale;
@property (nonatomic) float desktopWidth;
@property (nonatomic) float desktopHeight;
// Desktop color = backgroundColor, Sticker is placed at desktop with sticker's property
@property (nonatomic) long backgroundColor;

// FLFlip_NO_FLIP = 0, // No flip
// FLFlip_FLIP_X  = 1, // bd-flip / pq-flip
// FLFlip_FLIP_Y  = 2, // bp-flip / dq-flip
// FLFlip_FLIP_XY = 3, // bq-flip / pd-flip
@property (nonatomic) int stickerFlip;

@end
