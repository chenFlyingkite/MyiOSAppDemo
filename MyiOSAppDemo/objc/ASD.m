//
// Created by Eric Chen on 2021/3/7.
//

#import <MyiOSAppDemo-Swift.h>
#import "ASD.h"

@class LauncherViewController;


@implementation ASD {

}

- (instancetype)init {
    self = [super init];
    //FLError
    int x = [LauncherViewController gvc];
    int y = LauncherViewController.vc;
    // System can only see NSLog, never for printf, fprintf...
    NSLog(@"Hello %@ %d", @"Eric Chen", y);
    printf("printf Hello %s, %d\n", "world", y);
    fprintf(stdin, "fprintf.stdin Hello %s, %d\n", "world", x);
    fprintf(stderr, "fprintf.stderr Hello %s, %d\n", "world", x);

    
    return self;
}
@end

/**

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    self.frameCount++;
    NSLog(@"image = %d, output = %@, buf = 0x%x, con = %@", self.frameCount, output, sampleBuffer, connection);
    //if (![self acceptVideoFrame]) return;
    if (!self.queue) {
        self.queue = [NSMutableArray new];
    }
    UIImage* src;
    src = [UIImage imageNamed:@"icon_fail2" inBundle:self.nibBundle compatibleWithTraitCollection:nil];
    src = [UIImage imageNamed:@"error2" inBundle:self.nibBundle compatibleWithTraitCollection:nil];

    CIImage *ciImage;
    CIImage *img;
    //ciImage = [self createCIImageFromSampleBuffer:sampleBuffer];

    img = [CIImage imageWithCGImage:src.CGImage];
    //img = [self fromBuf:sampleBuffer]; // x
    //img = [self fromBuf2:sampleBuffer]; // x
    img = [self fromBuf3:sampleBuffer]; // x
    //[self add:img into:self.queue];
    ciImage = img;
    // In KYC demo, it always use rear camera with portrait orientation.
    ciImage = [ciImage imageByApplyingOrientation:kCGImagePropertyOrientationRight];

    if (ciImage) {
        [self onVideoFrameArrived:ciImage];
    }
}

// Possible int values for kCGImagePropertyTIFFOrientation
typedef CF_CLOSED_ENUM(uint32_t, CGImagePropertyOrientation) {
    kCGImagePropertyOrientationUp = 1,        // 0th row at top,    0th column on left   - default orientation
    kCGImagePropertyOrientationUpMirrored,    // 0th row at top,    0th column on right  - horizontal flip
    kCGImagePropertyOrientationDown,          // 0th row at bottom, 0th column on right  - 180 deg rotation
    kCGImagePropertyOrientationDownMirrored,  // 0th row at bottom, 0th column on left   - vertical flip
    kCGImagePropertyOrientationLeftMirrored,  // 0th row on left,   0th column at top
    kCGImagePropertyOrientationRight,         // 0th row on right,  0th column at top    - 90 deg CW
    kCGImagePropertyOrientationRightMirrored, // 0th row on right,  0th column on bottom
    kCGImagePropertyOrientationLeft           // 0th row on left,   0th column at bottom - 90 deg CCW
};

- (void) add:(NSObject*) it into:(NSMutableArray *)a {
    if (a) {
        [a addObject:it];
        while (a.count > 20) {
            [a removeObjectAtIndex:0];
        }
        NSLog(@"+q = %@", [self as:a]);
    }
}

 // Failed since it keeps the buffer
- (CIImage*) fromBuf:(CMSampleBufferRef)buf {
    CVImageBufferRef ref = CMSampleBufferGetImageBuffer(buf);

    CIImage *img = [CIImage imageWithCVPixelBuffer:ref];
    return img;
}


 // success
// http://furnacedigital.blogspot.com/2012/11/avcapturevideodataoutput.html
- (CIImage*) fromBuf3:(CMSampleBufferRef)buf {
    CVImageBufferRef ref = CMSampleBufferGetImageBuffer(buf);
    CVPixelBufferLockBaseAddress(ref, 0);
    uint8_t *base;
    base = CVPixelBufferGetBaseAddress(ref);
    size_t w = CVPixelBufferGetWidth(ref);
    size_t h = CVPixelBufferGetHeight(ref);
    size_t br = CVPixelBufferGetBytesPerRow(ref);
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx;
    ctx = CGBitmapContextCreate(base, w, h, 8, br, cs, kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(cs);
    CGImageRef cg;
    UIImage *m;
    cg = CGBitmapContextCreateImage(ctx);
    m = [UIImage imageWithCGImage:cg];
    CGImageRelease(cg);
    CGContextRelease(ctx);
    CVPixelBufferUnlockBaseAddress(ref, 0);
    CIImage *img = [CIImage imageWithCGImage:m.CGImage];
    return img;
}

- (CVPixelBufferRef) copySBR:(CVPixelBufferRef)buf {
    size_t w = CVPixelBufferGetWidth(buf);
    size_t h = CVPixelBufferGetHeight(buf);
    OSType p = CVPixelBufferGetPixelFormatType(buf);
    CFDictionaryRef r = CVBufferGetAttachments(buf, kCVAttachmentMode_ShouldPropagate);
    //CVBufferGetAttachments(buf, kCVAttachmentMode_ShouldPropagate);
    CVPixelBufferRef cp;
    cp = (CVPixelBufferRef) CVPixelBufferCreate(kCFAllocatorDefault, w, h, p, r, &cp);
    //CVPixelBufferRef cp = CVPixelBufferCreate(nil, w, h, p, r, &cp);
    CVPixelBufferLockBaseAddress(buf, kCVPixelBufferLock_ReadOnly);
    CVPixelBufferLockBaseAddress(cp, 0);
    size_t pn = CVPixelBufferGetPlaneCount(buf);
    NSLog(@"pn = %ld", pn);
    for (size_t i = 0; i < pn; i++) {
        void* dst = CVPixelBufferGetBaseAddressOfPlane(cp, i);
        void* src = CVPixelBufferGetBaseAddressOfPlane(buf, i);
        size_t hi = CVPixelBufferGetHeightOfPlane(buf, i);
        size_t br = CVPixelBufferGetBytesPerRowOfPlane(buf, i);
        NSLog(@"#%ld : %ldx%ld", i, hi, br);
        memcpy(dst, src, hi * br);
    }
//    void* dst = CVPixelBufferGetBaseAddress(cp);
//    void* src = CVPixelBufferGetBaseAddress(buf);
//    size_t size = CVPixelBufferGetDataSize(buf);
//    memcpy(dst, src, size);
    CVPixelBufferUnlockBaseAddress(cp, 0);
    CVPixelBufferUnlockBaseAddress(buf, kCVPixelBufferLock_ReadOnly);
    return cp;
}

 // Failed since it keeps the buffer
- (CIImage*) fromBuf2:(CMSampleBufferRef)buf {
    CVImageBufferRef ref;
    ref = CMSampleBufferGetImageBuffer(buf);
    CVImageBufferRef ref2;
    ref2 = [self copySBR:ref];

    CIImage *img = [CIImage imageWithCVPixelBuffer:ref2];
    return img;
}

*/
