//
//  FLUtil_GPU.m
//  PhotoDirector
//
//  Created by Eric Chen on 2019/7/15.
//  Copyright © 2019 CyberLink. All rights reserved.
//

#import "FLUtil_GPU.h"
#import "GPUEffect.h"
#import "GPUImagePicture.h"
#import "GPUImageSepiaFilter.h"
#import "GPUImageEffectHandler.h"

@implementation FLUtil_GPU

void printTargets(GPUImageOutput *o) {
    NSArray<id<GPUImageInput>> *a = o.targets;
    qw("-- Targets of GIO -- %s", ssString(o));
    long n = a.count;
    qw(" %ld targets", n);
    for (int i = 0; i < n; i++) {
        qw(" #%d : %s", i, ssString(a[i]));
    }
    qq("----");
}

void testAdd() {
    NSMutableArray<NSString*>* a = [NSMutableArray new];
    [a addObject:@"0"]; // (0)
    [a addObject:@"1"]; // (0, 1)
    [a insertObject:@"2" atIndex:1]; // (0, 2, 1)
}



#pragma mark - Apply Effect to Image

- (UIImage*) applySepia: (UIImage*)input { // about 50 ms in iPad
    NSLog(@"MIRR + Sep src = %@", input);
    FLTicTac *c = [[FLTicTac alloc] init];
    [c tic];
    [c tic];
    GPUImageSepiaFilter *s = [[GPUImageSepiaFilter alloc] init];
    [c tac:@"MIRR + Sep = %@", s];
    [c tic];
    UIImage *t = [s imageByFilteringImage:input];
    [c tac:@"MIRR + Sep imageByFilteringImage %@ = %@", NSStringFromCGSize(t.size), t];
    [c tac:@"MIRR + Sep done %@", t];
    return t;
}

- (UIImage*) applySepia2: (UIImage*)input {
    NSLog(@"MIRR + Sep2 src = %@", input);
    FLTicTac *c = [[FLTicTac alloc] init];
    [c tic];
    [c tic];
    GPUImagePicture *img = [[GPUImagePicture alloc] initWithImage:input];
    [c tac:@"MIRR + Sep2 GIP = %@", img];
    [c tic];
    GPUImageSepiaFilter *sepia = [[GPUImageSepiaFilter alloc] init];
    [c tac:@"MIRR + Sep2 sepia = %@", sepia];
    [c tic];
    [img addTarget:sepia];
    [c tac:@"MIRR + Sep2 + target"];
    [c tic];
    [sepia useNextFrameForImageCapture];
    [c tac:@"MIRR + Sep2 -> use next frame for img capture"];
    [c tic];
    [img processImage];
    [c tac:@"MIRR + Sep2 # processImage"];
    [c tic];
    UIImage *output = [sepia imageFromCurrentFramebuffer];
    [c tac:@"MIRR + Sep2 <- frame buffer = %@", output];
    [c tac:@"MIRR + Sep2 Done"];
    return output;
}

- (UIImage*) applyImage:(UIImage*)image fx:(GPUEffect*)fx {
        //    if (fx.filename == nil || fx == noFx) {
        //        return image; // No apply
        //    }
    
    GPUImagePicture *img = [[GPUImagePicture alloc] initWithImage:image]; // Takes about 30ms
    
    NSDictionary* params = fx.parameters;
    [GPUImageEffectHandler updateThumbnailEffect:params];
    
    GPUImageFilterChain *chain;
    chain = [GPUImageEffectHandler createFilterChainWithParams:params];
    
        // APPEND_FILTER_CHAIN in GPUImageEffectHandler.h
    GPUImageFilterChain *c = chain;
    GPUImageOutput *o = img;
    if ([c isNotEmpty]) {
        [o addTarget:[c head] atTextureLocation:0];
        o = [c tail];
        [o removeAllTargets];
        [c processAllImages];
    }
    
    [o useNextFrameForImageCapture];
    [img processImage];
    UIImage *output = [o imageFromCurrentFramebuffer]; // Takes about 40ms
    return output;
}

+ (UIImage*) applySampleCode: (UIImage*)input {
    bool useSepia = false;
    qw("Apply GPUImage on %s", ssString(input));
    FLTicTac *c = [[FLTicTac alloc] init];
    [c tic];
    [c tic];
    // Prepare input : Change UIImage(input) to GIP (img)
    GPUImagePicture *img = [[GPUImagePicture alloc] initWithImage:input];
    [c tac:@"GIP OK = %@", img];
    [c tic];
    // s = sepia, m = img
    //    +---+     +---+     +---+     +---+
    //    | m |     | s |     | q |     | p |
    //    +---+     +---+     +---+     +---+
    GPUImageSepiaFilter *s = [[GPUImageSepiaFilter alloc] init];
    GPUImageCropFilter *q = [GPUImageCropFilter new];
    q.cropRegion = CGRectMake(0, 0, 0.5, 1); // Left half
    GPUImageCropFilter *p = [GPUImageCropFilter new];
    p.cropRegion = CGRectMake(0.5, 0, 0.5, 1); // Right half
    [c tac:@"GIFs OK, sepia = %@, q.Left = %@, p.Right = %@", s, q, p];
    [c tic];
    // E.g. We want to crop the rect of (0.25 0.5, 0.25, 1) of m
    // => m apply following order
    // 1. crop m left-half by filter q as q(m)
    // 2. crop q(m) right-half by filter p as p(q(m))
    // Or written as function : Let f(m) = p(q(m)), where f = p.q (Function composite)
    // Here we define the order to be : m --(q)--> x --(p)--> y
    // , where x = q(m), y = p(x) = p(q(m))
    //    +---+          +---+          +---+
    //    | m | --(q)--> | x | --(p)--> | y |
    //    +---+          +---+          +---+
    // Hence we perform links on p, q by calling
    // GPUImageOutput#addTarget( y: id<GPUImageInput>) )
    // [x addTarget:y];   => perform link of y(x),  x --(y)--> y(x)
    // So we need to perform two actions, Link q and link p
    // Regardless linking order
    if (useSepia) {
        [img addTarget:s];
    } else {
        [img addTarget:q];
        [q addTarget:p];
    }
    [c tac:@"img add targets"];
    [c tic];
    // Taking output of o
    // o = p or q, one of chained functions
    // useNextFrameForImageCapture & imageFromCurrentFramebuffer should call from same object
    GPUImageOutput *o;
    if (useSepia) {
        o = s;
    } else {
        o = q; // Take image of crop by q
        o = p; // Take image of w = 0.25~0.5
    }
    [img processImage];
    [o useNextFrameForImageCapture];
    [c tac:@"use next frame for img capture"];
    [c tic];
    //[img processImage];
    [c tac:@"GIP # processImage"];
    [c tic];
    UIImage *output;
        //output = [sepia imageFromCurrentFramebuffer];
    output = [o imageFromCurrentFramebuffer];
    [c tac:@"Take image from frame buffer = %@", output];
    [c tac:@"GIP Done"];
    return output;
}

@end

@implementation GPUImageFilterChain (Log)

- (void) print {
    long n = self.filters.count;
    qw(" %ld filters", n);
    for (int i = 0; i < n; i++) {
        GPUImageFilter *fi = self.filters[i];
        qw("  #%d : %s", i, ssString(fi));
    }
}

@end

#pragma mark - GPU Image Filter Params


@implementation GPUImageMaskAlphaBlendFilterParam (Log)

- (void) print {
    GPUImageMaskAlphaBlendFilterParam *p = self;
    qw("\n-- Mask Alpha Blend Param --  %s", ssString(p));
    qw(" isAdd = %s,  enable Edge = %s, op = %s", ox(p.isAdd), ox(p.enableEdgeDetect), [self nameOf:p.op]);
    qw("  mix  = %lf,  r = %lf,  (x, y) = (%lf, %lf)", p.mix, p.r, p.x, p.y);
    qq("--");
}

// See GPUImageMaskAlphaBlendFilter.h
- (const char*) nameOf:(MaskOperation)t {
    switch (t) {
        case Normal:    return "Normal";
        case Invert:    return "Invert";
        case Undo:      return "Undo";
        case Apply:     return "Apply";
        case HideLast:  return "HideLast";
        case CleanMask: return "CleanMask";
        default:        return "?";
    }
}

@end

@implementation GPUImageLensFlareFilterParam (Log)

- (void) print {
    GPUImageLensFlareFilterParam *p = self;
    qq("\n-- lensFlareParam --");
    qw(" img   = %s", ssString(p.image));
    qw(" type  = %s,    strength = %lf", [self nameOf:p.blendingType], p.strength);
    qw(" scale = %lf,    deg = %lf,    center = (%lf, %lf)", p.scale, p.rotationDegree, p.centerX, p.centerY);
    qq("--");
}

// See GPUImageLensFlareFilter.h
- (const char*) nameOf:(LensFlareBlendTypes)t {
    switch (t) {
        case LENS_FLARE_NORMAL:    return "Normal";
        case LENS_FLARE_SCREEN:    return "Screen";
        case LENS_FLARE_MULTIPLY:  return "Multiply";
        case LENS_FLARE_HARDLIGHT: return "Hardlight";
        case LENS_FLARE_OVERLAY:   return "Overlay";
        case LENS_FLARE_SOFTLIGHT: return "Softlight";
        default:                   return "?";
    }
}

@end
