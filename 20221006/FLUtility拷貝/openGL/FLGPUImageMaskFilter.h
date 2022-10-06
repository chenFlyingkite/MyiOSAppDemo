//
// Created by Eric Chen on 2021/3/25.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageTwoInputFilter.h"

/**
 * Cut Input[0] where mask is white on wanted part, fill in background with backgroundColor
 *
 * So let A = Red (size= 500x300), B = 0xFFFFFFFF,
 * mask = centered circle with 0xFFFFFFFF of radius = 0.3 * height, outside is transparent
 * or in formula: color = 0xFFFFFFFF if (x-250)^2 + (y-150)^2 <= 100^2, otherwise 0x00000000
 * This filter gives you Flag of Japan. :)
 *
 * More formally,
 * Let image A = Input[0], B = backgroundColor, Mask = Input[1]
 *
 * for (i, j) = (0.0, 0.0) ~ (1.0, 1.0) in Mask {
 *   color c = Mask.colorAt(i, j)
 *   // color selection on A or B is by mask value
 *   if ( c is treat as empty by parameters) {
 *     gl_FragColor = B.colorAt(i, j)
 *   } else {
 *     gl_FragColor = A.colorAt(i, j)
 *   }
 * }
 */
@interface FLGPUImageMaskFilter : GPUImageTwoInputFilter

// Fills background color if color is treat as empty
@property (nonatomic, assign) long backgroundColor;
// Color c = (r, g, b, a) is treat as empty if
// c is in [minEmpty, maxEmpty] or alpha in [minAlpha, maxAlpha]
// min <= c <= max
// using min = 0x00000000, max = 0x00FFFFFF says all the color of alpha = 0 are treat as empty
// Empty color min value
@property (nonatomic, assign) long minEmptyColor;
// Empty color max value
@property (nonatomic, assign) long maxEmptyColor;
@property (nonatomic, assign) int minEmptyAlpha;
@property (nonatomic, assign) int maxEmptyAlpha;
@property (nonatomic, assign) bool invertMask;

@end