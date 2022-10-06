//
//  FLImageUtil.h
//  PhotoDirector
//
//  Created by Eric Chen on 2019/6/6.
//  Copyright © 2019 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLCGUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface FLImageUtil : NSObject

/**
 * Create thumb for image, by UIImage.init(CGImage, scale, orientation)
 */
//+ (UIImage*) thumbOf:(UIImage*)image width:(int)width height:(int)height;

/*!
 * Easy method for
 * [FLImageUtil scale:image toSize:{side, side} crop:true]
 */
+ (UIImage*) scale: (UIImage*)image within: (double)side;

/*!
 * Easy method for scale the image to side if image's minSide > side
 */
+ (UIImage*) scaleIfLarge:(UIImage*)image side:(double)side;

/*!
 * crop : true = image size larger so that image will be cropped
 */
+ (UIImage*) scale: (UIImage*)image toSize:(CGSize)size crop:(bool)crop;

+ (UIImage*) fitXY: (UIImage*)image toSize:(CGSize)size;

+ (UIImage*) crop:(UIImage*) image byRect:(CGRect)rect;

+ (UIImage*) transform: (UIImage*)image byMatrix: (CGAffineTransform)m;

+ (UIImage*) asImage:(UIView*)v;

+ (UIImage*) ofSolid:(UIColor*)color width:(int)w height:(int)h;
+ (UIImage*) ofSolid:(UIColor*)color size:(CGSize)z;
+ (void)save:(UIImage*)imgPng into:(NSString*)s;

// Deprecated
+ (UIImage*) from:(NSURL*)url;

@end

NS_ASSUME_NONNULL_END
