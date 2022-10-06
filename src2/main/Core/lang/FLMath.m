//
// Created by Eric Chen on 2021/2/2.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

#import "FLMath.h"


@implementation FLMath {

}

#pragma mark - Array Index Bounds

bool inBound(long k, NSArray *a) {
    return inBound3(k, 0, a.count);
}

bool inBound3(long v, long min, long max) {
    return min <= v && v < max;
}

bool inBound3F(double v, double min, double max) {
    return min <= v && v < max;
}

long makeInBound(long v, long min, long max) {
    return minl(maxl(min, v), max);
}

double makeInBoundF(double v, double min, double max) {
    return fmin(fmax(min, v), max);
}

long minl(long a, long b) {
    return (a < b) ? a : b;
}

long maxl(long a, long b) {
    return (a > b) ? a : b;
}
// return x + (y - x) * a;
double mix(double x, double y, double a) {
    return x + (y - x) * a;
}

@end