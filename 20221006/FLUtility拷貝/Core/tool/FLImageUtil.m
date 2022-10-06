//
//  FLImageUtil.m
//  PhotoDirector
//
//  Created by Eric Chen on 2019/6/6.
//  Copyright © 2019 CyberLink. All rights reserved.
//

#import "FLImageUtil.h"
#import "FLTicTac.h"
#import "UIColor+Hex.h"

@implementation FLImageUtil
//CLImageUtility/CLImageUtility.h still have too much unrelated methods, we use FLImageUtil

// in /Resource/Images/SurrealArt/surreal_art_sample_source@1x.jpg
//    let s = "surreal_art_sample_source@kx.jpg".replaceAll("k", "(1|2|3)")
//    let image = UIImage.init(named: s)
//    k = 1, @1x    <UIImage: 0x283f5f020> size {900, 1200} orientation 0 scale 1.000000
//    k = 2, @2x    <UIImage: 0x2834cc380> size {450, 600} orientation 0 scale 2.000000
//    k = 3, @3x    <UIImage: 0x28330e5a0> size {300, 400} orientation 0 scale 3.000000

// TODO not suitable for those image from contentsOfFile, it will holds the CGImage
+ (UIImage*) thumbOf:(UIImage*)image width:(int)width height:(int)height {
    // perform uiimage.size / scale
    // if scale = 2, then image from 4k*4k will scale to 2k*2k
    // But its content really unchanged?

    double sw = image.size.width / width;
    double sh = image.size.height / height;
    double s = fmin(sw, sh);
    return [UIImage imageWithCGImage:image.CGImage scale:image.scale * s orientation:image.imageOrientation];
}

+ (UIImage*) scale: (UIImage*)image within: (double)side {
    CGSize z = {side, side};
    return [FLImageUtil scale:image toSize:z crop:true];
}

+ (UIImage*) scaleIfLarge:(UIImage*)image side:(double)side {
    UIImage *ans = image;
    if (minSide(image.size) > side) {
        ans = [FLImageUtil scale:image within:side];
    }
    return ans;
}

+ (UIImage*) scale: (UIImage*)image toSize: (CGSize)size crop: (bool)crop {
    CGSize mz = image.size;
    // Evaluate ratios and select proper one as <s>
    double wr = size.width / mz.width;
    double hr = size.height / mz.height;
    double fit = fmin(wr, hr);
    double cut = fmax(wr, hr);
    double s = crop ? cut : fit;

    int way = 0;
    // Time consuming on draw bitmap, needs 50 ms about for 4k*4k image
    // For thumb size we use + (UIImage*) thumbOf:(UIImage*)image width:(int)width height:(int)height
    // Evaluate output size as <newSize>
    CGSize newSize = scaleSize(mz, s);
    return [FLImageUtil fitXY:image toSize:newSize];
}

+ (UIImage*) fitXY: (UIImage*)image toSize: (CGSize)size {
    UIGraphicsBeginImageContext(size);
    //UIGraphicsBeginImageContextWithOptions(size, false, 1);
    CGContextRef c = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(c);
    //-- Begin draw
    CGRect z = CGRectMake(0, 0, size.width, size.height);
    [image drawInRect:z]; // ~= 95% time
    //-- End draw
    UIGraphicsPopContext();
    UIImage *ans = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ans;
}

+ (UIImage*) crop: (UIImage*)image byRect: (CGRect)rect {
    CGPoint p = negatePoint(rect.origin);
    CGSize s = rect.size;
    
    UIGraphicsBeginImageContext(s);
    CGContextRef c = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(c);
    //-- Begin draw
    [image drawAtPoint:p];
    //-- End draw
    UIGraphicsPopContext();
    UIImage *ans = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ans;
}

+ (UIImage*) transform: (UIImage*)image byMatrix: (CGAffineTransform)m {
    // Direct return image if m = I
    if (CGAffineTransformEqualToTransform(m, CGAffineTransformIdentity)) {
        return image;
    }
    
    // Using CIImage to perform transformation
    CIImage *cim = [CIImage imageWithCGImage:image.CGImage];
    cim = [cim imageByApplyingTransform:m]; // ~= 90% time
    UIImage *ans = [UIImage imageWithCIImage:cim];
    return ans;
}

+ (UIImage*) asImage:(UIView*)v {
    // Parameters
    CGSize f = v.frame.size;
    
    UIGraphicsBeginImageContext(f); // ~= 10% time
    [v.layer renderInContext:UIGraphicsGetCurrentContext()]; // ~= 90% time
    UIImage *saved = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return saved;
}

+ (UIImage*) ofSolid:(UIColor*)color width:(int)w height:(int)h {
    CGSize z = CGSizeMake(w, h);
    return [FLImageUtil ofSolid:color size:z];
}

+ (UIImage*) ofSolid:(UIColor*)color size:(CGSize)z {
    CGRect r = {CGPointZero, z};

    UIGraphicsBeginImageContext(z);
    //UIGraphicsBeginImageContextWithOptions(z, false, 1);
    CGContextRef c = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(c);
    //-- Begin draw
    [color setFill];
    UIRectFill(r);
    //-- End draw
    UIGraphicsPopContext();
    UIImage *ans = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ans;
}

// failed to find it in iPhone.....
+ (void)save:(UIImage*)imgPng into:(NSString*)s {
    NSData* d = UIImagePNGRepresentation(imgPng);
    UIImage *png = [UIImage imageWithData:d];
    UIImageWriteToSavedPhotosAlbum(png, nil, nil, nil);
}

+ (void) save2:(UIImage*)img into:(NSString*)s {
    NSSearchPathDirectory p = NSPicturesDirectory;
    //p = NSDocumentDirectory;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(p, NSUserDomainMask, true);
    NSString* file = [paths[0] addF:@"/%s", ssString(s)];
    // save image
    [UIImagePNGRepresentation(img) writeToFile:file atomically:true];
}

// Untested..

/*
 FIXME WHY MASK = 4500 ... when 1500 mask to be 4500?

clair.Salient : [1] : create effect Salient from SalientObjSeg.cla in /private/var/containers/Bundle/Application/3316179F-B3E9-4CB0-96C7-0C9BE16BCEDB/photodirector.app/SalientObjSeg.cla
[Clair] failed to open /private/var/containers/Bundle/Application/3316179F-B3E9-4CB0-96C7-0C9BE16BCEDB/photodirector.app/SalientObjSeg.json
clair.Salient : [22] : initEffect ok = true
clair.Salient : [114] : apply Effect
clair.Salient : [0] : get apply <UIImage:0x28105eeb0 anonymous {1500, 1500}>
clair.Salient : [0] : masking Optional(<CGImage 0x133ec8ed0> (DP)
<<CGColorSpace 0x280610ea0> (kCGColorSpaceICCBased; kCGColorSpaceModelRGB; sRGB IEC61966-2.1)>
width = 4500, height = 4500, bpc = 8, bpp = 32, row bytes = 18016
kCGImageAlphaPremultipliedFirst | kCGImageByteOrder32Little  | kCGImagePixelFormatPacked
is mask? No, has masking color? No, has soft mask? Yes, has matte? No, should interpolate? Yes),
as <UIImage:0x28105ec70 anonymous {4500, 4500}>
clair.Salient : [1] : release
clair.Salient :[140] : take Salient
 */
//let target = result.cgImage?.masking(detect.cgImage!)
+ (UIImage*) ofSolid2:(UIColor*)color size:(CGSize)z {
    CGRect r = {CGPointZero, z};

    int cint = [color colorInt];
    CGFloat a = 1.0 * ((cint & 0xFF000000) >> 24) / 255.0;
    UIColor *noa = [color makeAlpha:0xFF];
    //UIGraphicsBeginImageContext(z);
    UIGraphicsBeginImageContextWithOptions(z, false, 0); // has alpha, but can not into GPUImage
    CGContextRef c = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(c);
    //-- Begin draw
    CGContextSetAlpha(c, a);
    [noa setFill];
    //[color setFill];
    UIRectFill(r);
    //-- End draw
    UIGraphicsPopContext();
    UIImage *ans = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ans;
}

// Deprecated
+ (UIImage*) from:(NSURL*)url {
    NSData *d = [NSData dataWithContentsOfURL:url];
    return [UIImage imageWithData:d];
    
//    ALAssetsLibrary *a = [ALAssetsLibrary new];
//
//    [assetslibrary assetForURL:imageURL resultBlock:^(ALAsset *asset) {
//        self.exifInfo = [asset.defaultRepresentation.metadata mutableCopy];
//
//            // Write thumbnail image for next launching APP usage
//        NSData *data = UIImageJPEGRepresentation([UIImage imageWithCGImage:(asset.defaultRepresentation.fullScreenImage)], 0);
//        [data writeToFile:[LastImageConfiguration sharedInstance].lastEditedImageThumbnailPath atomically:YES];
}
@end
