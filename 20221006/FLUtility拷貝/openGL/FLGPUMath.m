//
// Created by Eric Chen on 2021/4/24.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

#import "FLGPUMath.h"


@implementation FLGPUMath {

}

+ (GPUVector4) toArgb:(long)argb {
    double a = ((argb >> 24) & 0xFF) / 255.0;
    double r = ((argb >> 16) & 0xFF) / 255.0;
    double g = ((argb >>  8) & 0xFF) / 255.0;
    double b = ((argb >>  0) & 0xFF) / 255.0;
    GPUVector4 v = (GPUVector4) {(GLfloat) r, (GLfloat) g, (GLfloat) b, (GLfloat) a};
    return v;
}
@end