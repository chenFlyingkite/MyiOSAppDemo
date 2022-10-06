//
//  UIColor+Hex.h
//  PhotoDirector
//
//  Created by Eric Chen on 2019/6/3.
//  Copyright © 2019 CyberLink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Hex)

/**
 * Return the color defined by argb in strings, available syntax are as follows :
 * #rgb #argb #rrggbb #aarrggbb, as Regex is {
 *   d = ([0-9]|[a-f]|[A-F])
 *   hexColor = [#](d3|d4|d6|d8)
 * }
 */
+ (UIColor*) colorWithHex: (NSString*)argb;

/**
 * Return the color defined by argb in integers, each value of alpha, red, green and blue should be in [0, 255]
 */
+ (UIColor*) colorArgb: (int)a r:(int)r g:(int)g b:(int)b;

/**
 * Return the color defined by argb in integer of 0xaarrggbb,
 * Red = 0xFFFF0000, Green = 0xFF00FF00, Blue = 0xFF0000FF
 */
+ (UIColor*) colorWithInt: (long)argb;

/**
 * Return "#aarrggbb" of color
 */
- (NSString *)hex;

/**
 * Return int format of 0xaarrggbb of color, like red = 0xFFFF0000
 */
- (int) colorInt;

@end

NS_ASSUME_NONNULL_END
