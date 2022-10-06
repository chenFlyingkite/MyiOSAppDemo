//
// Created by Eric Chen on 2020/12/22.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLDrawPen : NSObject
@property (nonatomic) bool enable;
@property (nonatomic) UIColor *color;
@property (nonatomic) double width;

- (instancetype) initWithColor:(UIColor*)c width:(double)w;
@end