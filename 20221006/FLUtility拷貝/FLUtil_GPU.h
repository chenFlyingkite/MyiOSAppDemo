//
//  FLUtil_GPU.h
//  PhotoDirector
//
//  Created by Eric Chen on 2019/7/15.
//  Copyright © 2019 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageEffectParam.h"
#import "GPUImageEffectHandler.h"
#import "GPUImageLensFlareFilter.h"
#import "GPUImageMaskAlphaBlendFilter.h"
#import "FLUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface FLUtil_GPU : NSObject

void printTargets(GPUImageOutput *o);

+ (UIImage*) applySampleCode: (UIImage*)input;

@end

@interface GPUImageFilterChain (Log)

- (void) print;

@end

#pragma mark - GPU Image Filter Params

@interface GPUImageMaskAlphaBlendFilterParam (Log)
- (void) print;
//- (const char*) nameOf:(MaskOperation)t;
- (const char*) nameOf:(MaskOperation)t;
@end

@interface GPUImageLensFlareFilterParam (Log)
- (void) print;
@end

NS_ASSUME_NONNULL_END
