//
// Created by Eric Chen on 2020/12/29.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLLayouts.h"
#import "FLNSKit.h"
#import "FLUIKit.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wimplicit-int-conversion"
#pragma clang diagnostic ignored "-Wsign-conversion"
@implementation FLLayouts {

}
#pragma mark - Apply contraint

+ (void) activate:(UIView*)root forConstraint:(NSArray<id>*)all {
    // Not use the root.subViews, since it will find UISlider's contraint
    // <_UISlideriOSVisualElement: 0x14b6145f0; frame = (0 0; 100 34); opaque = NO; autoresize = W+H; layer = <CALayer: 0x283337920>>
    // and cause UISlider fail to layout with given constraints

    // Step 1: Collects the used views in constraints, excldue the root
    NSMutableSet<UIView*>* used = [FLLayouts getUsedViews:all];
    [used removeObject:root];
    // Omit root since it may have constraint from storyboard
    // root.translatesAutoresizingMaskIntoConstraints = false;
    //qwe("activate cons: %s", ssString(root));
    //[used.allObjects printAll];
    [FLLayouts disableAutoResizingMask:used.allObjects];
    [FLLayouts applyConstraints:all];
}

+ (void) disableAutoResizingMask:(NSArray<UIView*>*) child {
    //[child printAll];
    for (UIView* v in child) {
        v.translatesAutoresizingMaskIntoConstraints = false;
        //[v removeConstraints:v.constraints];
    }
}

// Type = NSArray<NSLayoutConstraint*>* or NSLayoutConstraint*
+ (void) applyConstraints:(NSArray<id>*)all {
    // Using add constraint by each one will crashes
    NSMutableArray<NSLayoutConstraint*> *a = [FLLayouts expand:all];
    [NSLayoutConstraint activateConstraints:a];
}

#pragma mark - DFS methods
// Let all = [NSLayoutConstraint or [NSLayoutConstraint]]
// Returns non-null UIView used in NSLayoutConstraint, named S,
// formally defined as S = {x.firstItem, x.secondItem} for each x in all
+ (NSMutableSet<UIView*>*)getUsedViews:(NSArray<id>*)all {
    NSMutableSet<UIView*>* used = [NSMutableSet new];
    for (id x in all) {
        if ([x isKindOfClass:NSArray.class]) {
            NSMutableSet<UIView*>* inner = [FLLayouts getUsedViews:x];
            [used unionSet:inner];
        } else if ([x isKindOfClass:NSLayoutConstraint.class]) {
            NSLayoutConstraint* c = x;
            NSArray* a = @[c.firstItem ?: NSNull.null,
                    c.secondItem ?: NSNull.null,];
            for (id z in a) {
                bool isView = [z isKindOfClass:UIView.class];
                if (isView) {
                //if (isView && ![used containsObject:z]) {
                    [used addObject:z];
                }
            }
        } else {
            qwe("Did not add item : %s", ssString(x));
        }
    }
    return used;
}

// Expand all as List<NSLayoutConstraint>
+ (NSMutableArray<NSLayoutConstraint*>*) expand:(NSArray<id>*)all {
    NSMutableArray<NSLayoutConstraint*>* used = [NSMutableArray new];
    for (id x in all) {
        if ([x isKindOfClass:NSArray.class]) {
            NSMutableArray<NSLayoutConstraint*>* inner = [FLLayouts expand:x];
            // add all
            [used addAll:inner];
        } else if ([x isKindOfClass:NSLayoutConstraint.class]) {
            NSLayoutConstraint* c = x;
            [used add:c];
        } else {
            qwe("Did not add item : %s", ssString(x));
        }
    }
    return used;
}


// Expand all as List<UIView>
+ (NSMutableArray<UIView*>*) expandAllViews:(NSArray<id>*)all {
    NSMutableArray<UIView*>* used = [NSMutableArray new];
    for (id x in all) {
        if ([x isKindOfClass:NSArray.class]) {
            NSMutableArray<UIView*>* inner = [FLLayouts expandAllViews:x];
            // add all
            [used addAll:inner];
        } else if ([x isKindOfClass:UIView.class]) {
            UIView* c = x;
            [used add:c];
        } else {
            qwe("Did not add item : %s", ssString(x));
        }
    }
    return used;
}

+ (__kindof UIView*) addViewTo:(__kindof UIView*)root child:(NSArray*)child {
    // DFS on child and add its child, then return root (child's parent)
    bool isToStack = [root isKindOfClass:UIStackView.class];
    for (int i = 0; i < child.count; i++) {
        id v = child[i]; // v is UIView* or NSArray*
        UIView* w;
        if ([v isKindOfClass:NSArray.class]) {
            NSArray *vs = (NSArray *) v;
            if (i < 1) {
                qwe("Wrong for child[%d]", i-1);
            } else {
                if ([child[i-1] isKindOfClass:UIView.class]) {
                    UIView* rt = (UIView *) child[i - 1];
                    w = [FLLayouts addViewTo:rt child:vs];
                }
            }
        } else if ([v isKindOfClass:UIView.class]) {
            w = (UIView *) v;
        }
        if (w) {
            if (isToStack) {
                __kindof UIStackView * stack = root;
                [stack addArrangedSubview:w];
            } else {
                [root addSubview:w];
            }
        }
    }
    return root;
}

#pragma mark - Safe Area
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 equalToSafeAreaOf:(__kindof UIView*)v2 {
    return [FLLayouts view:v1 equalToSafeAreaOf:v2 side:@"LTRB"];
//    bool valid = v1 && v2;
//    NSMutableArray<NSLayoutConstraint*>* a = [NSMutableArray new];
//    if (valid) {
//        UILayoutGuide* g = v2.safeAreaLayoutGuide;
//        NSArray *b = @[
//            [v1.leftAnchor   constraintEqualToAnchor:g.leftAnchor],
//            [v1.topAnchor    constraintEqualToAnchor:g.topAnchor],
//            [v1.rightAnchor  constraintEqualToAnchor:g.rightAnchor],
//            [v1.bottomAnchor constraintEqualToAnchor:g.bottomAnchor],
//        ];
//        [a addAll:b];
//    }
//    return a;
}
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 equalToSafeAreaOf:(__kindof UIView*)v2 side:(NSString*) side {
    bool valid = v1 && v2;
    NSMutableArray<NSLayoutConstraint*>* a = [NSMutableArray new];
    if (valid) {
        UILayoutGuide* g = v2.safeAreaLayoutGuide;
        NSMutableArray *b = [NSMutableArray new];
        for (int i = 0; i < side.length; i++) {
            unichar c = [side characterAtIndex:i];
            if ('a' <= c && c <= 'z') {
                c = c - ' ';
            }
            if (c == 'T') {
                [b add:[v1.topAnchor   constraintEqualToAnchor:g.topAnchor]];
            } else if (c == 'L') {
                [b add:[v1.leftAnchor   constraintEqualToAnchor:g.leftAnchor]];
            } else if (c == 'R') {
                [b add:[v1.rightAnchor   constraintEqualToAnchor:g.rightAnchor]];
            } else if (c == 'B') {
                [b add:[v1.bottomAnchor   constraintEqualToAnchor:g.bottomAnchor]];
            }
        }
        [a addAll:b];
    }
    return a;
}

#pragma mark - Constant value
// v1.attr = val
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 set:(NSLayoutAttribute)attr to:(double)val {
    return [NSLayoutConstraint constraintWithItem:v1 attribute:attr relatedBy:NSLayoutRelationEqual
                                           toItem:nil attribute:attr multiplier:1 constant:val];
}

+ (NSArray<NSLayoutConstraint*>*) views:(NSArray<__kindof UIView*>*)v1 set:(NSLayoutAttribute)attr to:(double)val {
    NSMutableArray<NSLayoutConstraint*>*a = [NSMutableArray new];
    for (int i = 0; i < v1.count; i++) {
        UIView *v = v1[i];
        a[i] = [FLLayouts view:v set:attr to:val];
    }
    return a;
}

#pragma mark - size
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 width:(double)w height:(double)h {
    return @[
            [FLLayouts view:v1 set:NSLayoutAttributeWidth to:w],
            [FLLayouts view:v1 set:NSLayoutAttributeHeight to:h],
    ];
}

#pragma mark - size ratio
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 width:(double)w height:(double)h offset:(bool)val {
    return [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                           toItem:v1 attribute:NSLayoutAttributeHeight multiplier:w/h constant:val];
}

#pragma mark - one property alignment
// v1.attr = v2.attr + c
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 align:(NSLayoutAttribute)attr to:(__kindof UIView*)v2 offset:(double)c {
    return [NSLayoutConstraint constraintWithItem:v1 attribute:attr relatedBy:NSLayoutRelationEqual
                                           toItem:v2 attribute:attr multiplier:1 constant:c];
}

// v1.attr = v2.attr
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 align:(NSLayoutAttribute)attr to:(__kindof UIView*)v2 {
    return [NSLayoutConstraint constraintWithItem:v1 attribute:attr relatedBy:NSLayoutRelationEqual
                                           toItem:v2 attribute:attr multiplier:1 constant:0];
}

#pragma mark - two property alignment
// v1.a1 = v2.a2 + c
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 align:(NSLayoutAttribute)a1 to:(__kindof UIView*)v2 of:(NSLayoutAttribute)a2 offset:(double)c {
    return [NSLayoutConstraint constraintWithItem:v1 attribute:a1 relatedBy:NSLayoutRelationEqual
                                           toItem:v2 attribute:a2 multiplier:1 constant:c];
}

// v1.a1 = v2.a2
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 align:(NSLayoutAttribute)a1 to:(__kindof UIView*)v2 of:(NSLayoutAttribute)a2 {
    return [NSLayoutConstraint constraintWithItem:v1 attribute:a1 relatedBy:NSLayoutRelationEqual
                                           toItem:v2 attribute:a2 multiplier:1 constant:0];
}


#pragma mark - Relative Layout
// v1.bottom = v2.top - c
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 above:(__kindof UIView*)v2 offset:(double) c {
    return [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                           toItem:v2 attribute:NSLayoutAttributeTop multiplier:1 constant:-c];
}

// v1.bottom = v2.top
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 above:(__kindof UIView*)v2 {
    return [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                           toItem:v2 attribute:NSLayoutAttributeTop multiplier:1 constant:0];
}

// v1.top = v2.bottom + c
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 below:(__kindof UIView*)v2 offset:(double)c {
    return [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                           toItem:v2 attribute:NSLayoutAttributeBottom multiplier:1 constant:c];
}

// v1.top = v2.bottom
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 below:(__kindof UIView*)v2 {
    return [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                           toItem:v2 attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
}

// v1.right = v2.left + c
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 toLeftOf:(__kindof UIView*)v2 offset:(double)c {
    return [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual
                                           toItem:v2 attribute:NSLayoutAttributeLeft multiplier:1 constant:c];
}

// v1.right = v2.left
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 toLeftOf:(__kindof UIView*)v2 {
    return [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual
                                           toItem:v2 attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
}

// v1.left = v2.right + c
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 toRightOf:(__kindof UIView*)v2 offset:(double)c {
    return [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual
                                           toItem:v2 attribute:NSLayoutAttributeRight multiplier:1 constant:c];
}

// v1.left = v2.right
+ (NSLayoutConstraint*) view:(__kindof UIView*)v1 toRightOf:(__kindof UIView*)v2 {
    return [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual
                                           toItem:v2 attribute:NSLayoutAttributeRight multiplier:1 constant:0];
}

#pragma mark - Layout child
+ (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 layoutChildAxis:(FLDirection)direction gravity:(FLGravity)gravity {
    return [FLLayouts view:v1 layout:v1.subviews axis:direction gravity:gravity];
}

+ (NSArray<NSLayoutConstraint*>*) views:(NSArray<__kindof UIView*>*)v2 layoutAxis:(FLDirection)direction gravity:(FLGravity)gravity {
    return [FLLayouts view:nil layout:v2 axis:direction gravity:gravity];
}

+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 layout:(NSArray<__kindof UIView*>*)v2 axis:(FLDirection)direction gravity:(FLGravity)gravity {
    return [FLLayouts view:v1 layout:v2 axis:direction gravity:gravity margins:nil];
}

+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 layout:(NSArray<__kindof UIView*>*)v2 axis:(FLDirection)direction gravity:(FLGravity)gravity margins:(NSArray<NSNumber*>*)margins {
    NSMutableArray<NSLayoutConstraint*>* a = [NSMutableArray new];
    NSLayoutAttribute t1 = NSLayoutAttributeNotAnAttribute;
    NSLayoutAttribute t2 = NSLayoutAttributeNotAnAttribute;
    // For direction
    if (gravity == FLGravityMatchParent) {
        if (direction == FLLeftToRight) {
            t1 = NSLayoutAttributeTop;
            t2 = NSLayoutAttributeBottom;
        } else if (direction == FLTopToBottom) {
            t1 = NSLayoutAttributeLeft;
            t2 = NSLayoutAttributeRight;
        } else {
        }
    } else if (gravity == FLGravityCenter) {
        t1 = NSLayoutAttributeCenterX;
        t2 = NSLayoutAttributeCenterY;
    }
    if (t1 != NSLayoutAttributeNotAnAttribute) {
        [a addAll:[FLLayouts view:v1 aline:t1 to:v2]];
    }
    if (t2 != NSLayoutAttributeNotAnAttribute) {
        [a addAll:[FLLayouts view:v1 aline:t2 to:v2]];
    }
    if (direction != FLDirectionNo) {
        [a addAll: [FLLayouts view:v1 layout:v2 axis:direction]];
    }
    // For gravity
    NSLayoutAttribute g = NSLayoutAttributeNotAnAttribute;
    switch (gravity) {
        case FLGravityLeft:    g = NSLayoutAttributeLeft;    break;
        case FLGravityRight:   g = NSLayoutAttributeRight;   break;
        case FLGravityTop:     g = NSLayoutAttributeTop;     break;
        case FLGravityBottom:  g = NSLayoutAttributeBottom;  break;
        case FLGravityCenterX: g = NSLayoutAttributeCenterX; break;
        case FLGravityCenterY: g = NSLayoutAttributeCenterY; break;
        // since t1, t2 assigned
        case FLGravityCenter: break;
        case FLGravityMatchParent:  break;
        default: break;
    }
    if (g != NSLayoutAttributeNotAnAttribute) {
        [a addAll:[FLLayouts view:v1 aline:g to:v2]];
    }
    return a;
}

#pragma mark - Multiple views

+ (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 aline:(NSLayoutAttribute)attr to:(NSArray<__kindof UIView*>*)v2 {
    NSMutableArray<NSLayoutConstraint*>* a = [NSMutableArray new];
    int from = 0;
    UIView* p = nil;
    if (v1) {
        //  v1, v2 = [a, b, ..., ]
        //  p^        ^from
        from = 0;
        p = v1;
    } else {
        //  nil, v2 = [a, b, ..., ]
        //            p^  ^from
        from = 1;
        if (v2.count > 0) {
            p = v2[0];
        }
    }
    for (int i = from; i < v2.count; i++) {
        UIView* v = v2[i];
        if (v) {
            [a add:[FLLayouts view:p align:attr to:v]];
        }
    }
    return a;
}

+ (NSArray<NSLayoutConstraint*>*) layout:(NSArray<__kindof UIView*>*)v2 axis:(FLDirection)direction {
    return [FLLayouts view:nil layout:v2 axis:direction gravity:FLGravityNo];
}

+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 layout:(NSArray<__kindof UIView*>*)v2 axis:(FLDirection)direction {
    NSMutableArray<NSLayoutConstraint*>* a = [NSMutableArray new];
    NSLayoutAttribute begin = NSLayoutAttributeLeft;
    NSLayoutAttribute ended = NSLayoutAttributeRight;
    bool upDown = direction == FLTopToBottom;
    if (upDown) {
        begin = NSLayoutAttributeTop;
        ended = NSLayoutAttributeBottom;
    }
    NSLayoutConstraint* x;
    long n = v2.count;
    if (n > 0) {
        if (v1) {
            x = [FLLayouts view:v1 align:begin to:v2[0]];
            [a addObject:x];
        }
    }
    for (int i = 1; i < n; i++) {
        // [... w, v]
        UIView* v = v2[i];
        UIView* w = v2[i-1];
        if (upDown) {
            x = [FLLayouts view:w above:v];
        } else {
            x = [FLLayouts view:w toLeftOf:v];
        }
        [a addObject:x];
    }
    if (n > 0) {
        if (v1) {
            x = [FLLayouts view:v1 align:ended to:v2[n - 1]];
            [a addObject:x];
        }
    }
    return a;
}


#pragma mark - Corner = 2 side alignment

+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 corner:(FLCorner)at to:(__kindof UIView*)v2 {
    return [FLLayouts view:v1 corner:at to:v2 offsetX:0 offsetY:0];
}

/// v1.attr1 = v2.attr1 & v1.attr2 = v2.attr2
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 corner:(FLCorner)at to:(__kindof UIView*)v2 offsetX:(double)dx offsetY:(double)dy {
    NSLayoutAttribute x = NSLayoutAttributeLeft;
    NSLayoutAttribute y = NSLayoutAttributeTop;
    if (at == FLCornerLeftTop) {
        x = NSLayoutAttributeLeft;
        y = NSLayoutAttributeTop;
    } else if (at == FLCornerLeftCenterY) {
        x = NSLayoutAttributeLeft;
        y = NSLayoutAttributeCenterY;
    } else if (at == FLCornerLeftBottom) {
        x = NSLayoutAttributeLeft;
        y = NSLayoutAttributeBottom;
    } else if (at == FLCornerCenterXTop) {
        x = NSLayoutAttributeCenterX;
        y = NSLayoutAttributeTop;
    } else if (at == FLCornerCenterXCenterY) {
        x = NSLayoutAttributeCenterX;
        y = NSLayoutAttributeCenterY;
    } else if (at == FLCornerCenterXBottom) {
        x = NSLayoutAttributeCenterX;
        y = NSLayoutAttributeBottom;
    } else if (at == FLCornerRightTop) {
        x = NSLayoutAttributeRight;
        y = NSLayoutAttributeTop;
    } else if (at == FLCornerRightCenterY) {
        x = NSLayoutAttributeRight;
        y = NSLayoutAttributeCenterY;
    } else if (at == FLCornerRightBottom){
        x = NSLayoutAttributeRight;
        y = NSLayoutAttributeBottom;
    }
    return @[[FLLayouts view:v1 align:x to:v2 offset:dx],
             [FLLayouts view:v1 align:y to:v2 offset:dy],
     ];
}


#pragma mark - Drawer
+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 drawer:(FLSide)at to:(__kindof UIView*)v2 depth:(double)d {
    return [FLLayouts view:v1 drawer:at to:v2 depth:d offset:UIEdgeInsetsZero];
}

+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 drawer:(FLSide)at to:(__kindof UIView*)v2 depth:(double)d offset:(UIEdgeInsets)margin {
    NSMutableArray<NSLayoutConstraint*> *a = [NSMutableArray new];
    if (at == FLSideNo) {
        return a;
    }
    NSLayoutConstraint *c;
    // left
    if (at == FLSideRight) {
        c = [FLLayouts view:v1 set:NSLayoutAttributeWidth to:d];
    } else {
        c = [FLLayouts view:v1 align:NSLayoutAttributeLeft to:v2 offset:margin.left];
    }
    [a add:c];
    // top
    if (at == FLSideBottom) {
        c = [FLLayouts view:v1 set:NSLayoutAttributeHeight to:d];
    } else {
        c = [FLLayouts view:v1 align:NSLayoutAttributeTop to:v2 offset:margin.top];
    }
    [a add:c];
    // right
    if (at == FLSideLeft) {
        c = [FLLayouts view:v1 set:NSLayoutAttributeWidth to:d];
    } else {
        c = [FLLayouts view:v1 align:NSLayoutAttributeRight to:v2 offset:-margin.right];
    }
    [a add:c];
    // bottom
    if (at == FLSideTop) {
        c = [FLLayouts view:v1 set:NSLayoutAttributeHeight to:d];
    } else {
        c = [FLLayouts view:v1 align:NSLayoutAttributeBottom to:v2 offset:-margin.bottom];
    }
    [a add:c];
    return a;
}

#pragma mark - Same

// v1.width = v2.width
// v1.height = v2.height
+ (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 sameWHTo:(__kindof UIView*)v2 {
    return @[
            [FLLayouts view:v1 align:NSLayoutAttributeWidth to:v2],
            [FLLayouts view:v1 align:NSLayoutAttributeHeight to:v2],
            ];
}

// v1.left = v2.left
// v1.right = v2.right
+ (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 sameXTo:(__kindof UIView*)v2 {
    return [FLLayouts view:v1 sameXTo:v2 offset:UIEdgeInsetsZero];
}

+ (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 sameXTo:(__kindof UIView*)v2 offset:(UIEdgeInsets)margin {
    return @[
            [FLLayouts view:v1 align:NSLayoutAttributeLeft to:v2 offset:margin.left],
            [FLLayouts view:v1 align:NSLayoutAttributeRight to:v2 offset:-margin.right],
    ];
}

// v1.top = v2.top
// v1.bottom = v2.bottom
+ (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 sameYTo:(__kindof UIView*)v2 {
    return [FLLayouts view:v1 sameYTo:v2 offset:UIEdgeInsetsZero];
}

+ (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 sameYTo:(__kindof UIView*)v2 offset:(UIEdgeInsets)margin {
    return @[
            [FLLayouts view:v1 align:NSLayoutAttributeTop to:v2 offset:margin.top],
            [FLLayouts view:v1 align:NSLayoutAttributeBottom to:v2 offset:-margin.bottom],
    ];
}

+ (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 sameTo:(__kindof UIView*)v2 {
    return [FLLayouts view:v1 sameTo:v2 offset:UIEdgeInsetsZero];
}

+ (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 sameTo:(__kindof UIView *)v2 offset:(UIEdgeInsets)margin {
    return @[
            [FLLayouts view:v1 align:NSLayoutAttributeTop to:v2 offset:+margin.top],
            [FLLayouts view:v1 align:NSLayoutAttributeLeft to:v2 offset:+margin.left],
            [FLLayouts view:v1 align:NSLayoutAttributeRight to:v2 offset:-margin.right],
            [FLLayouts view:v1 align:NSLayoutAttributeBottom to:v2 offset:-margin.bottom],
    ];
}

#pragma mark - Sames
// v[0].attr = v[i].attr for i = 1 ~ n-1
+ (NSArray<NSLayoutConstraint*>*) views:(NSArray<__kindof UIView*>*)vs align:(NSLayoutAttribute)attr {
    NSMutableArray<NSLayoutConstraint*> *a = [NSMutableArray new];
    for (int i = 1; i < vs.count; i++) {
        NSLayoutConstraint* c = [FLLayouts view:vs[i] align:attr to:vs[0]];
        [a add:c];
    }
    return a;
}

+ (NSArray<NSLayoutConstraint*>*) views:(NSArray<__kindof UIView*>*)vs same:(FLSame)opt {
    NSMutableArray<NSLayoutConstraint*> *a = [NSMutableArray new];
    FLSame same = FLSameNo;
    NSArray<NSLayoutConstraint*>*(^run)(UIView *, UIView *) = nil;
    if (opt == FLSameLeftRight) {
        run = ^NSArray<NSLayoutConstraint*>*(UIView *v1, UIView *v2) {
            return [FLLayouts view:v1 sameXTo:v2];
        };
    } else if (opt == FLSameTopBottom) {
        run = ^NSArray<NSLayoutConstraint*>*(UIView *v1, UIView *v2) {
            return [FLLayouts view:v1 sameYTo:v2];
        };
    } else if (opt == FLSameWidthHeight) {
        run = ^NSArray<NSLayoutConstraint*>*(UIView *v1, UIView *v2) {
            return [FLLayouts view:v1 sameWHTo:v2];
        };
    } else if (opt == FLSameLeftTopRightBottom) {
        run = ^NSArray<NSLayoutConstraint*>*(UIView *v1, UIView *v2) {
            return [FLLayouts view:v1 sameTo:v2];
        };
    } else {
    }
    if (run) {
        for (int i = 1; i < vs.count; i++) {
            NSArray<NSLayoutConstraint*>* c = run(vs[i], vs[0]);
            [a addAll:c];
        }
    }
    return a;
}


- (void) addStackView:(UIView*) parent {
    // 0 = fill equal same row/column
    // 1 = given width/height
    int way = 0;
    UIStackView* a;
    a = [UIStackView new];
    //a = self.horiz;
    a.axis = UILayoutConstraintAxisVertical;
    a.axis = UILayoutConstraintAxisHorizontal;
    if (way == 0) {
        a.alignment = UIStackViewAlignmentFill;
        a.distribution = UIStackViewDistributionFillEqually;
    } else if (way == 1) {
        a.alignment = UIStackViewAlignmentLeading;
        a.alignment = UIStackViewAlignmentCenter;
        a.alignment = UIStackViewAlignmentTrailing;
        a.distribution = UIStackViewDistributionEqualSpacing;
    } else {

    }
    a.spacing = 2;
    NSMutableArray<NSLayoutConstraint*> * cons = [NSMutableArray new];
    for (int i = 0; i < 5; i++) {
        UIView *x = [UIView new];
        x.layer.backgroundColor = FLUIKit.color12[i].CGColor;
        // No use addSubview for it
        // [a addSubview:x]; fails for stackview
        if (way == 0) {
            [a addArrangedSubview:x];
        } else if (way == 1) {
            [cons add:[x.widthAnchor constraintEqualToConstant:20 + 10* i] ];
            [cons add:[x.heightAnchor constraintEqualToConstant:20 + 10* i] ];

        }
        //[cons add:[x.heightAnchor constraintEqualToConstant:20 + 10* i] ];

        //[cons add:[x.widthAnchor constraintEqualToConstant:20 + 10* i] ];
        //[cons add: [FLLayouts view:x align:NSLayoutAttributeWidth to:a ] ];
        //[cons add: [FLLayouts view:x set:NSLayoutAttributeHeight to:20] ];
        //[cons add: [FLLayouts view:x set:NSLayoutAttributeWidth to:20] ];

        //[a addSubview:x];
        //[a addArrangedSubview:x];
    }
    if (way == 1) {
        [FLLayouts applyConstraints:cons];
    } else if (way == 2) {

    } else {

    }
    //[FLLayouts applyConstraints:cons];
    //[FLLayouts activate:a forConstraint:cons];
    a.layer.backgroundColor = UIColor.brownColor.CGColor;
    CGRect f;
    f = CGRectMake(0, 200, 300, 70);
    a.frame = f;
    [parent addSubview:a];
}

//+ (instancetype)constraintWithItem:(__kindof UIView*)view attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(nullable id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c API_AVAILABLE(macos(10.7), ios(6.0), tvos(9.0));

@end

#pragma clang diagnostic pop
