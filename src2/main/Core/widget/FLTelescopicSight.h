//
// Created by Eric Chen on 2019-10-23.
// Copyright (c) 2019 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLUtil.h"

@interface FLPoint : NSObject
@property (nonatomic) double x;
@property (nonatomic) double y;
+ (FLPoint *) of:(double) x y:(double)y;
+ (FLPoint *) of:(CGPoint)p;
@end

@protocol FLTelescopicSightListener<NSObject>
- (void) onNewAim:(long)newAim oldAim:(long)oldAim;
@end

//--
@interface FLTelescopicSight : NSObject

/// The listener want to listen for aim changed by calling aimAt:
@property (nonatomic, weak) id<FLTelescopicSightListener> onAimListener;
/// The aim we have focus at after called aimAt:, valid range = -1, 0, ..., n-1 (n = point array size)
@property (nonatomic) long aim;
/// False = aimAt: returns directly and no respond to FLTelescopicSightListener
/// True = aimAt: response to FLTelescopicSightListener
@property (nonatomic) bool enable;

- (void) reset;
/// Set point[index] = p
- (void) setPoint:(FLPoint *)p at:(long)index;
- (long) aimAt:(FLPoint *)p;

@end