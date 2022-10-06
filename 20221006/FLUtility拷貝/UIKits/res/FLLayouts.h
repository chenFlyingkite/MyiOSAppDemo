//
// Created by Eric Chen on 2020/12/29.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned char, FLDirection) {
    FLLeftToRight = '-',
    FLTopToBottom = '|',
    FLDirectionNo = '?',
};

// From NSLayoutAttribute
typedef NS_ENUM(unsigned char, FLGravity) {
    FLGravityLeft        = 'L',
    FLGravityRight       = 'R',
    FLGravityTop         = 'T',
    FLGravityBottom      = 'B',
    FLGravityCenterX     = 'X',
    FLGravityCenterY     = 'Y',
    FLGravityCenter      = 'C',
    FLGravityMatchParent = 'M',
    FLGravityNo          = '?',
};

// chars are define like the 3*4 calculator pad
typedef NS_ENUM(unsigned char, FLCorner) {
    FLCornerLeftTop        = '7',
    FLCornerLeftCenterY    = '4',
    FLCornerLeftBottom     = '1',
    FLCornerCenterXTop     = '8',
    FLCornerCenterXCenterY = '5',
    FLCornerCenterXBottom  = '2',
    FLCornerRightTop       = '9',
    FLCornerRightCenterY   = '6',
    FLCornerRightBottom    = '3',
    FLCornerNo             = '0',
};

typedef NS_ENUM(unsigned char, FLSame) {
    FLSameLeftRight          = 'H',
    FLSameTopBottom          = 'I',
    FLSameWidthHeight        = '+',
    FLSameLeftTopRightBottom = '#',
    FLSameNo                 = '?',
};

typedef NS_ENUM(unsigned char, FLSide) {
    FLSideLeft   = 'L',
    FLSideTop    = 'T',
    FLSideRight  = 'R',
    FLSideBottom = 'B',
    FLSideNo     = '?',
};

@interface FLLayouts : NSObject

#pragma mark - Apply contraint
// Mostly used, = disableAutoResizingMask + applyConstraints
+ (void) activate:(UIView*)root forConstraint:(NSArray<id>*)all;
+ (void) disableAutoResizingMask:(NSArray<__kindof UIView*>*)v1;
// can we contains NSLayoutConstraint* or NSArray<NSLayoutConstraint*>* mixing;
+ (void) applyConstraints:(NSArray<id>*)all;
//-- For View trees
// child = NSArray<UIView* or NSArray<UIView*>*>, returns root
+ (__kindof UIView*) addViewTo:(__kindof UIView*)root child:(NSArray*)child;
+ (NSMutableArray<UIView*>*) expandAllViews:(NSArray<id>*)all;
//--

#pragma mark - Safe Area
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 equalToSafeAreaOf:(__kindof UIView*)v2;
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 equalToSafeAreaOf:(__kindof UIView*)v2 side:(NSString*) side;

#pragma mark - Constant value
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 set:(NSLayoutAttribute)attr to:(double)val;
+ (NSArray<NSLayoutConstraint*>*) views:(NSArray<__kindof UIView*>*)v1 set:(NSLayoutAttribute)attr to:(double)val;
#pragma mark - Size
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 width:(double)w height:(double)h;
#pragma mark - size ratio
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 width:(double)w height:(double)h offset:(bool)val;

#pragma mark - one property alignment
/// v1.attr = v2.attr + offset
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 align:(NSLayoutAttribute)attr to:(__kindof UIView*)v2 offset:(double)c;
/// v1.attr = v2.attr
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 align:(NSLayoutAttribute)attr to:(__kindof UIView*)v2;

#pragma mark - two property alignment
//// v1.a1 = v2.a2 + c
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 align:(NSLayoutAttribute)a1 to:(__kindof UIView*)v2 of:(NSLayoutAttribute)a2 offset:(double)c;
//// v1.a1 = v2.a2
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 align:(NSLayoutAttribute)a1 to:(__kindof UIView*)v2 of:(NSLayoutAttribute)a2;

#pragma mark - Relative Layout
/// v1.bottom = v2.top - c
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 above:(__kindof UIView*)v2 offset:(double) c;
/// v1.bottom = v2.top
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 above:(__kindof UIView*)v2;
/// v1.top = v2.bottom + c
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 below:(__kindof UIView*)v2 offset:(double)c;
/// v1.top = v2.bottom
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 below:(__kindof UIView*)v2;
/// v1.right = v2.left + c
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 toLeftOf:(__kindof UIView*)v2 offset:(double)c;
/// v1.right = v2.left
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 toLeftOf:(__kindof UIView*)v2;
/// v1.left = v2.right + c
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 toRightOf:(__kindof UIView*)v2 offset:(double)c;
/// v1.left = v2.right
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 toRightOf:(__kindof UIView*)v2;

+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 layout:(NSArray<__kindof UIView*>*)v2 axis:(FLDirection)direction gravity:(FLGravity)gravity;
+ (NSArray<NSLayoutConstraint*>*) views:(NSArray<__kindof UIView*>*)v2 layoutAxis:(FLDirection)direction gravity:(FLGravity)gravity;

// true = vertical, false = horizontal
// In iOS, its subviews may not be the visual order in storyboard, actual order is in xib file...
+ (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 layoutChildAxis:(FLDirection)direction gravity:(FLGravity)gravity;


#pragma mark - Multiple views
//TODO Rename me!, swift confusing
+ (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 aline:(NSLayoutAttribute)attr to:(NSArray<__kindof UIView*>*)v2;
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 layout:(NSArray<__kindof UIView*>*)v2 axis:(FLDirection)direction;
+ (NSArray<NSLayoutConstraint*>*) layout:(NSArray<__kindof UIView*>*)v2 axis:(FLDirection)direction;

#pragma mark - Corner = 2 side alignment
/// v1.attr1 = v2.attr1 & v1.attr2 = v2.attr2
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 corner:(FLCorner)at to:(__kindof UIView*)v2;
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 corner:(FLCorner)at to:(__kindof UIView*)v2 offsetX:(double)dx offsetY:(double)dy;

#pragma mark - Drawer = 3 side alignment
/// v1 as a drawer at v2's side, v1.width/height = depth, v1.alignments = v2 + margins
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 drawer:(FLSide)at to:(__kindof UIView*)v2 depth:(double)d;
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 drawer:(FLSide)at to:(__kindof UIView*)v2 depth:(double)d offset:(UIEdgeInsets)margin;

#pragma mark - Same = 4 side alignment
// same width height
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView *)v1 sameWHTo:(__kindof UIView*)v2;
// same left & right
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView *)v1 sameXTo:(__kindof UIView*)v2;
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView *)v1 sameXTo:(__kindof UIView*)v2 offset:(UIEdgeInsets)margin;
// same top and bottom
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView *)v1 sameYTo:(__kindof UIView*)v2;
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView *)v1 sameYTo:(__kindof UIView*)v2 offset:(UIEdgeInsets)margin;
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 sameTo:(__kindof UIView*)v2;
/// Let v1.bounds = v2.bounds + insets
/// Let v1.bounds = {0, 0, 70, 80}, want v2 in v1 with margins = {5, 10, 7, 9}
/// -> v2.bound = {0+5, 0+10, 70-7, 80-9}
/// Calls (v2, v1, {5, 10, 7, 9})
+ (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 sameTo:(__kindof UIView *)v2 offset:(UIEdgeInsets)margin;
#pragma mark - Same multiple views
+ (NSArray<NSLayoutConstraint*>*) views:(NSArray<__kindof UIView*>*)vs align:(NSLayoutAttribute)attr;
+ (NSArray<NSLayoutConstraint*>*) views:(NSArray<__kindof UIView*>*)vs same:(FLSame)opt;
@end

// placeAt margin
