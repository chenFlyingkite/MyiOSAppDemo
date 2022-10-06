//
// Created by Eric Chen on 2020/12/30.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLLog.h"

/**
 * Utility for CGGeometry
 */
@interface FLCGUtil : NSObject

#pragma mark - Methods C/C++ like

/**
 * @return min(z.width, z.height)
 */
double minSide(CGSize z);

/**
 * @return max(z.width, z.height)
 */
double maxSide(CGSize z);

/**
 * Return rect R satisfies
 * <br/> 1. R.w : R.h = w : h
 * <br/> 2. R center crops r, either width or height is same as r
 * <br/>   2.1 if R.w = r.w -> R.h > r.h
 * <br/>   2.2 if R.h = r.h -> R.w > r.w
 * <br/>
 * <br/> That is, return [ABCD] = rectCenterCropIn([PQRS], ..)
 * <br/>  A     P  Q    B
 * <br/>  +-----+--+----+
 * <br/>  |     |  |    |
 * <br/>  +-----+--+----+
 * <br/>  D     S  R    C
 */
CGRect rectCenterCropIn(CGSize r, double w, double h);

/**
 * Return rect R satisfies
 * <br/> 1. R.w : R.h = w : h
 * <br/> 2. R fits center in r, either width or height is same as r
 * <br/>   2.1 if R.w = r.w -> R.h < r.h
 * <br/>   2.2 if R.h = r.h -> R.w < r.w
 * <br/>
 * <br/> That is, return [PQRS] = rectFitCenterIn([ABCD], ..)
 * <br/>  A     P  Q    B
 * <br/>  +-----+--+----+
 * <br/>  |     |  |    |
 * <br/>  +-----+--+----+
 * <br/>  D     S  R    C
 */
CGRect rectFitCenterIn(CGSize r, double w, double h);

/**
 * Return points (in form of NSString) of parameter r's left-top, right-top, left-bottom, right bottom
 * <br/> Points are created by NSStringFromCGPoint(CGPoint point)
 * <br/> To parse from NSString to CGPoint, use CGPoint CGPointFromString(NSString *string)
 */
NSArray<NSString*>* rectCorners(CGRect r);

/**
 * @return center of rect, = (x + w/2, y + h/2)
 */
CGPoint rectCenter(CGRect r);

#pragma mark - CGPoint / Rect / Size's basic operation

/**
 * @return offsetPoint2(p, dp.x, dp.y)
 * @seealso offsetPoint2(dx, dy)
 */
CGPoint offsetPoint(CGPoint p, CGPoint dp);

/**
 * Offset the point's coordinate by (dx, dy)
 * @param p The CGPoint of p
 * @param dx x offset
 * @param dy y offset
 * @return (p.x + x, p.y + y)
 */
CGPoint offsetPoint2(CGPoint p, CGFloat x, CGFloat y);

/**
 * @return CGRectOffset(r, p.x, p.y)
 */
CGRect offsetRect(CGRect r, CGPoint p);

/**
 * @return s.width = 0 or s.height = 0
 */
bool isEmptySize(CGSize s);

/**
 * @return s.width <= 0 or s.height <= 0
 */
bool isNonPositiveSize(CGSize s);

/**
 * @return s.width / s.height
 */
double whRatio(CGSize s);

/**
 * @return (-s.width, -s.height)
 */
CGSize negateSize(CGSize s);

/**
 * negateSize(s) = scaleSize(s, -1)
 * @return (s.width * r, s.height * r)
 */
CGSize scaleSize(CGSize s, double r);

/**
 * @return (s.width + p.x, s.height + p.y)
 */
CGSize extendSize(CGSize s, CGPoint p);

/**
 * Extend size with each side
 * @return (s.width + x, s.height + y)
 */
CGSize extendSize2(CGSize s, double x, double y);

/**
 * Negate the point's coordinates
 * @return (-p.x, -p.y)
 */
CGPoint negatePoint(CGPoint p);

/**
 * negatePoint(p) = scalePoint(p, -1)
 * @return (p.x * r, p.y * r)
 */
CGPoint scalePoint(CGPoint p, double r);

/**
 * Representation
 * <br/> [ x ] = [ a  c ]  *  [ p.x ]  +  [ tx ]
 * <br/> [ y ]   [ b  d ]     [ p.y ]     [ ty ]
 * <br/> Augmented Matrix
 * <br/> [ x ]   [ a  c  ty ]   [ p.x ]
 * <br/> [ y ] = [ b  d  tx ] * [ p.y ]
 * <br/> [ 1 ]   [ 0  0  1  ]   [  1  ]
 * @return (x, y)
 */
CGPoint transformPoint(CGPoint p, CGAffineTransform m);

UIEdgeInsets edgeAll(double v);
UIEdgeInsets edgeXY(double x, double y);
@end