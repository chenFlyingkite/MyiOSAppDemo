//
// Created by Eric Chen on 2021/4/23.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageThreeInputFilter.h"

 // todo filter need to test for colors and alpha
 // todo take care, mask[2] is from cgimage.masking()image premultiply?
@interface FLGPUImageMaskFilter2 : GPUImageThreeInputFilter

// Color c = (r, g, b, a) is treat as empty if
//   c is in [minEmpty, maxEmpty] or a is in [minAlpha, maxAlpha]
// where x in [l, r] = l_i <= x_i <= r_i for all i

// Empty color min value
@property (nonatomic, assign) long minEmptyColor;
// Empty color max value
@property (nonatomic, assign) long maxEmptyColor;
@property (nonatomic, assign) int minEmptyAlpha;
@property (nonatomic, assign) int maxEmptyAlpha;
// true  : c = 1 - mask color
// false : c = mask color
@property (nonatomic, assign) bool invertMask;
@end