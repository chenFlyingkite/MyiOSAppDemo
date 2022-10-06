//
// Created by Eric Chen on 2020/12/30.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Animation Parameter
/**
 * Helper class for [UIView animateWithDuration:/and More/];
 */
@interface FLAnimate : NSObject
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, copy) void(^animate)(void);
@property (nonatomic, copy) void(^completion)(BOOL);
@end