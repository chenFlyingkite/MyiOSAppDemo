//
// Created by Eric Chen on 2020/12/30.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import "FLCGUtil.h"


@implementation FLCGUtil {

}

#pragma mark - Methods C/C++ like

double minSide(CGSize z) {
    return fmin(z.width, z.height);
}

double maxSide(CGSize z) {
    return fmax(z.width, z.height);
}

CGRect rectIn(CGSize r, double w, double h, bool fit) {
    // Let us put the kit in provided box as rect = r
    double rw = r.width;
    double rh = r.height;
    if (w == 0 || h == 0 || rw == 0 || rh == 0) return CGRectZero; // since empty

    // Start measure
    double boxR = 1.0 * rw / rh;
    double kitR = 1.0 * w / h;
    double x = 0, y = 0, kw = rw, kh = rh;

    if (boxR > kitR) { // box is wider, height meet
        if (fit) { // make kit small to put in box
            kw = rh * kitR;
            x = (rw - kw) / 2;
        } else { // make kit large to contain box
            kh = rw / kitR;
            y = (rh - kh) / 2;
        }
    } else if (boxR < kitR) { // box is narrower, width meet
        if (fit) { // make kit small to put in box
            kh = rw / kitR;
            y = (rh - kh) / 2;
        } else {  // make kit large to contain box
            kw = rh * kitR;
            x = (rw - kw) / 2;
        }
    } // else same ratio

    return CGRectMake(x, y, kw, kh);
}

CGRect rectCenterCropIn(CGSize r, double w, double h) {
    return rectIn(r, w, h, false);
}

CGRect rectFitCenterIn(CGSize r, double w, double h) {
    return rectIn(r, w, h, true);
}

CGPoint rectCenter(CGRect r) {
    double x = r.origin.x;
    double y = r.origin.y;
    double w = r.size.width;
    double h = r.size.height;
    return CGPointMake(x + w / 2, y + h / 2);
}

NSArray<NSString*>* rectCorners(CGRect r) {
    double x = r.origin.x;
    double y = r.origin.y;
    double w = r.size.width;
    double h = r.size.height;
    NSMutableArray<NSString*>* a = [NSMutableArray new];
    const int N = 4;
    CGPoint m[N] = {
            CGPointMake(x+0, y+0), CGPointMake(x+w, y+0),
            CGPointMake(x+0, y+h), CGPointMake(x+w, y+h),
    };
    for (int i = 0; i < N; i++) {
        [a addObject:NSStringFromCGPoint(m[i])];
    }
    return a;
}

#pragma mark - CGPoint / Rect / Size's basic operation

CGPoint offsetPoint(CGPoint p, CGPoint dp) {
    return offsetPoint2(p, dp.x, dp.y);
}

CGPoint offsetPoint2(CGPoint p, CGFloat x, CGFloat y) {
    return CGPointMake(p.x + x, p.y + y);
}

CGRect offsetRect(CGRect r, CGPoint p) {
    return CGRectOffset(r, p.x, p.y);
}

CGPoint negatePoint(CGPoint p) {
    return CGPointMake(-p.x, -p.y);
}

bool isEmptySize(CGSize s) {
    return s.width == 0 || s.height == 0;
}

bool isNonPositiveSize(CGSize s) {
    return s.width <= 0 || s.height <= 0;
}

bool isPositiveSize(CGSize s) {
    return s.width > 0 && s.height > 0;
}

double whRatio(CGSize s) {
    return 1.0 * s.width / s.height;
}

CGSize negateSize(CGSize s) {
    return CGSizeMake(-s.width, -s.height);
}

CGSize scaleSize(CGSize s, double r) {
    return CGSizeMake(s.width * r, s.height * r);
}

CGSize extendSize(CGSize s, CGPoint p) {
    return extendSize2(s, p.x, p.y);
}

CGSize extendSize2(CGSize s, double x, double y) {
    return CGSizeMake(s.width + x, s.height + y);
}

CGPoint scalePoint(CGPoint p, double r) {
    return CGPointMake(p.x * r, p.y * r);
}

CGPoint transformPoint(CGPoint p, CGAffineTransform m) {
    // Representation
    // [ x ] = [ a  c ]  *  [ p.x ]  +  [ tx ]
    // [ y ]   [ b  d ]     [ p.y ]     [ ty ]
    // Augmented Matrix
    // [ x ]   [ a  c  ty ]   [ p.x ]
    // [ y ] = [ b  d  tx ] * [ p.y ]
    // [ 1 ]   [ 0  0  1  ]   [  1  ]
    double x = m.a * p.x + m.c * p.y + m.tx;
    double y = m.b * p.x + m.d * p.y + m.ty;
    return CGPointMake(x, y);
}

UIEdgeInsets edgeAll(double v) {
    return UIEdgeInsetsMake(v, v, v, v);
}

UIEdgeInsets edgeXY(double x, double y) {
    return UIEdgeInsetsMake(y, x, y, x);
}

@end