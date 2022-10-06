//
//  FLImageUtil.m
//  PhotoDirector
//
//  Created by Eric Chen on 2019/6/6.
//  Copyright © 2019 CyberLink. All rights reserved.
//

#import "FLImageUtil.h"
#import "FLTicTac.h"

@implementation FLImageUtil
//CLImageUtility/CLImageUtility.h still have too much unrelated methods, we use FLImageUtil

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
    CGContextRef c = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(c);
    //-- Begin draw
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)]; // ~= 95% time
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
    CGRect r = {CGPointZero, z};
    
    UIGraphicsBeginImageContext(z);
    //UIGraphicsBeginImageContextWithOptions(z, false, 0);
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
