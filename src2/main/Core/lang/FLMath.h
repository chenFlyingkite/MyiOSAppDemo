//
// Created by Eric Chen on 2021/2/2.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FLMath : NSObject

/**
 * @return inBound3(k, 0, a.count)
 */
bool inBound(long k, NSArray *a);

/**
 * Returns
 * <br/>true if v is in [min, max),
 * <br/>false if v is in (-Inf, min) or [max, +Inf)
 */
bool inBound3(long v, long min, long max);
bool inBound3F(double v, double min, double max);

/**
 * double version of makeInBound(v, min, max)
 */
double makeInBoundF(double v, double min, double max);

/**
 * Return min(max(min, v), max)
 * same as clamp() in C++
 */
long makeInBound(long v, long min, long max);

// return min of (a, b)
long minl(long a, long b);
// return max of (a, b)
long maxl(long a, long b);

// return x + (y - x) * a;
double mix(double x, double y, double a);

#pragma mark - Radian (0 ~ 2*pi) <-> Drgree (0 ~ 360)
/** @return r * 180.0 / M_PI */
double radToDeg(double r);
/** @return d / 180.0 * M_PI */
double degToRad(double d);

@end