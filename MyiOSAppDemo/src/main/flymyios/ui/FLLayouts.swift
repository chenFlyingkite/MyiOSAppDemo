//
// Created by Eric Chen on 2020/12/29.
//

import Foundation
import UIKit

//https://www.wolfram.com/mathematica/new-in-8/comprehensive-image-processing-environment/

public class FLLayouts {
    public typealias NSLayoutAttribute = NSLayoutConstraint.Attribute

    // MARK: Apply contraint
    public class func activate(_ root: UIView, forConstraint all: Array<AnyObject>) -> Void {
        // Not use the root.subViews, since it will find UISlider's contraint
        // <_UISlideriOSVisualElement: 0x14b6145f0; frame = (0 0; 100 34); opaque = NO; autoresize = W+H; layer = <CALayer: 0x283337920>>
        // and cause UISlider fail to layout with given constraints

        // Step 1: Collects the used views in constraints, excldue the root
        var used: Set<UIView> = Self.getUsedViews(all)
        used.remove(root)
//        NSMutableSet < UIView*>* used = [FLLayouts getUsedViews:all];
//        [used removeObject:root];

        // Omit root since it may have constraint from storyboard
        // root.translatesAutoresizingMaskIntoConstraints = false;
        //qwe("activate cons: %s", ssString(root));
        //[used.allObjects printAll];

        Self.disableAutoResizingMask(used)
        // Self.disableAutoResizingMask(used.toArray()) // same
        Self.applyConstraints(all)
//        [FLLayouts disableAutoResizingMask:used.allObjects];
//        [FLLayouts applyConstraints:all];
    }

    public class func disableAutoResizingMask(_ child:Set<UIView>) -> Void {
        for v in child {
            v.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    public class func disableAutoResizingMask(_ child: Array<UIView>) -> Void {
        //[child printAll];
        let n = child.count
        for i in 0..<n {
            let v = child[i]
            v.translatesAutoresizingMaskIntoConstraints = false
        }
//        for (UIView* v in child) {
//            bool isView = [v isKindOfClass:UIView.class]; //  it is really strange.... fixme
//            if (isView) { // to omit the layout guide
//                v.translatesAutoresizingMaskIntoConstraints = false;
//                //[v removeConstraints:v.constraints];
//            } else {
//                qwe("omit %s", ssString(v));
//            }
//        }
    }

    // Type = NSArray<NSLayoutConstraint*>* or NSLayoutConstraint*
    public class func applyConstraints(_ all: Array<AnyObject>) -> Void {
        let a = Self.expand(all)
        NSLayoutConstraint.activate(a)
    }

//+ (void) applyConstraints:(NSArray<id>*)all {
//    // Using add constraint by each one will crashes
//    NSMutableArray<NSLayoutConstraint*> *a = [FLLayouts expand:all];
//    [NSLayoutConstraint activateConstraints:a];
//}

    // MARK: Add views
    // DFS on child and add child to parent, then return root (child's parent)
    public class func addViewTo(_ root: UIView, child:Array<AnyObject>) -> UIView {
        //let isToStack = root is UIStackView// [root isKindOfClass:UIStackView.class];
        let n = child.count
        for i in 0..<n {
            let x = child[i]
            var w: UIView? = nil
            if let a = x as? Array<AnyObject> {
                let p = i - 1
                if (p < 0) {
                    print("Wrong for child[\(p)]")
                } else {
                    let ch = child[p]
                    if let v = ch as? UIView {
                        w = Self.addViewTo(v, child: a)
                    }
                }
            } else if let v = x as? UIView {
                w = v;
            }
            //if (w != nil) {
            if let w = w {
                if let stack = root as? UIStackView {
                    stack.addArrangedSubview(w)
                } else {
                    root.addSubview(w)
                }
            }
        }
        return root
    }
//
//+ (__kindof UIView*) addViewTo:(__kindof UIView*)root child:(NSArray*)child {
//    // DFS on child and add its child, then return root (child's parent)
//        bool isToStack = [root isKindOfClass:UIStackView.class];
//for (int i = 0; i < child.count; i++) {
//        id v = child[i]; // v is UIView* or NSArray*
//        UIView* w;
//if ([v isKindOfClass:NSArray.class]) {
//        NSArray *vs = (NSArray *) v;
//if (i < 1) {
//        qwe("Wrong for child[%d]", i-1);
//} else {
//    if ([child[i-1] isKindOfClass:UIView.class]) {
//        UIView* rt = (UIView *) child[i - 1];
//        w = [FLLayouts addViewTo:rt child:vs];
//    }
//}
//} else if ([v isKindOfClass:UIView.class]) {
//    w = (UIView *) v;
//}
//if (w) {
//    if (isToStack) {
//        __kindof UIStackView * stack = root;
//        [stack addArrangedSubview:w];
//    } else {
//        [root addSubview:w];
//    }
//}
//}
//return root;
//}

    // MARK: DFS methods
    // Let all = [NSLayoutConstraint or [NSLayoutConstraint]]
    // Returns non-null UIView used in NSLayoutConstraint, named S,
    // formally defined as S = {x.firstItem, x.secondItem} for each x in all
    private class func getUsedViews(_ all:Array<AnyObject>) -> Set<UIView> {
        var used:Set<UIView> = [];
        for x in all {
            if let a = x as? Array<AnyObject> {
                let inner = Self.getUsedViews(a)
                used = used.union(inner) // TODO need?
            } else if let c = x as? NSLayoutConstraint {
                let vi = [c.firstItem, c.secondItem]
                for y in vi {
                    if let v = y as? UIView {
                        used.insert(v)
                    }
                }
            } else {
                print("Did not add item : \(x)")
            }
        }
        return used
    }
//    + (NSMutableSet<UIView*>*)getUsedViews:(NSArray<id>*)all {
//        NSMutableSet<UIView*>* used = [NSMutableSet new];
//        for (id x in all) {
//            if ([x isKindOfClass:NSArray.class]) {
//                NSMutableSet<UIView*>* inner = [FLLayouts getUsedViews:x];
//                [used unionSet:inner];
//            } else if ([x isKindOfClass:NSLayoutConstraint.class]) {
//                NSLayoutConstraint* c = x;
//                NSArray * a = @[c.firstItem ?: NSNull.null,
//                                c.secondItem ?: NSNull.null,];
//                for (id z in a) {
//                    bool isView = [z isKindOfClass:UIView.class];
//                    if (isView) {
//                        //if (isView && ![used containsObject:z]) {
//                        [used addObject:z];
//                    }
//                }
//            } else {
//                qwe("Did not add item : %s", ssString(x));
//            }
//        }
//        return used;
//    }

    private class func expand(_ all:Array<AnyObject>) -> Array<NSLayoutConstraint> {
        var used: Array<NSLayoutConstraint> = []
        for x in all {
            if let a = x as? Array<AnyObject> {
                let inner = Self.expand(a)
                used += inner
            } else if let c = x as? NSLayoutConstraint {
                used.append(c)
            } else {
                print("Did not add item : \(x)");
            }
        }
        return used
    }
//
//    // Expand all as List<NSLayoutConstraint>
//+ (NSMutableArray<NSLayoutConstraint*>*) expand:(NSArray<id>*)all {
//    NSMutableArray<NSLayoutConstraint*>* used = [NSMutableArray new];
//    for (id x in all) {
//        if ([x isKindOfClass:NSArray.class]) {
//            NSMutableArray<NSLayoutConstraint*>* inner = [FLLayouts expand:x];
//            // add all
//            [used addAll:inner];
//        } else if ([x isKindOfClass:NSLayoutConstraint.class]) {
//            NSLayoutConstraint* c = x;
//            [used add:c];
//        } else {
//            qwe("Did not add item : %s", ssString(x));
//        }
//    }
//    return used;
//}

    // Expand all as List<UIView>
    public class func expandAllViews(_ all:Array<AnyObject>) -> Array<UIView> {
        var used:Array<UIView> = []
        for x in all {
            if let a = x as? Array<AnyObject> {
                let inner = Self.expandAllViews(a)
                used += inner
            } else if let v = x as? UIView {
                used.append(v)
            } else {
                print("Did not add item : \(x)");
            }
        }
        return used
    }
//        + (NSMutableArray<UIView*>*) expandAllViews:(NSArray<id>*)all {
//    NSMutableArray<UIView*>* used = [NSMutableArray new];
//    for (id x in all) {
//        if ([x isKindOfClass:NSArray.class]) {
//            NSMutableArray<UIView*>* inner = [FLLayouts expandAllViews:x];
//            // add all
//            [used addAll:inner];
//        } else if ([x isKindOfClass:UIView.class]) {
//            UIView* c = x;
//            [used add:c];
//        } else {
//            qwe("Did not add item : %s", ssString(x));
//        }
//    }
//    return used;
//}


    // MARK: - For constraints, v1.a1 = m x v2.a2 + c
    // MARK: Constant value
    // v1.attr = val
    public class func view(_ v1:UIView, set attr:NSLayoutAttribute, to val:Double) -> NSLayoutConstraint {
        return NSLayoutConstraint.init(item: v1, attribute: attr, relatedBy: .equal,
                toItem: nil, attribute: attr, multiplier: 1, constant: CGFloat(val))
    }

    public class func views(_ v1:Array<UIView?>, set attr:NSLayoutAttribute, to val:Double) -> Array<NSLayoutConstraint> {
        var a:Array<NSLayoutConstraint> = []
        for v in v1 {
            if let v = v {
                let c = Self.view(v, set: attr, to: val)
                a.append(c)
            }
        }
        return a
    }
    // TODO : Going

//        + (NSArray<NSLayoutConstraint*>*) views:(NSArray<__kindof UIView*>*)v1 set:(NSLayoutAttribute)attr to:(double)val {
//    NSMutableArray<NSLayoutConstraint*>*a = [NSMutableArray new];
//    for (int i = 0; i < v1.count; i++) {
//        UIView *v = v1[i];
//        a[i] = [FLLayouts view:v set:attr to:val];
//    }
//    return a;
//}
//#pragma mark - Constant value
//// v1.attr = val
//        + (NSLayoutConstraint*) view:(__kindof UIView*)v1 set:(NSLayoutAttribute)attr to:(double)val {
//    return [NSLayoutConstraint constraintWithItem:v1 attribute:attr relatedBy:NSLayoutRelationEqual
//    toItem:nil attribute:attr multiplier:1 constant:val];
//}
//
//        + (NSArray<NSLayoutConstraint*>*) views:(NSArray<__kindof UIView*>*)v1 set:(NSLayoutAttribute)attr to:(double)val {
//    NSMutableArray<NSLayoutConstraint*>*a = [NSMutableArray new];
//    for (int i = 0; i < v1.count; i++) {
//        UIView *v = v1[i];
//        a[i] = [FLLayouts view:v set:attr to:val];
//    }
//    return a;
//}
//
//#pragma mark - size
//        + (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 width:(double)w height:(double)h {
//    return @[
//        [FLLayouts view:v1 set:NSLayoutAttributeWidth to:w],
//    [FLLayouts view:v1 set:NSLayoutAttributeHeight to:h],
//    ];
//}
}

//}
//
//#import <Foundation/Foundation.h>
//#import "FLLayouts.h"
//#import "FLNSKit.h"
//#import "FLUIKit.h"
//
//
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wsign-conversion"
//@implementation FLLayouts {
//
//}
//#pragma mark - Apply contraint
//
//
//#pragma mark - Constant value
//// v1.attr = val
//        + (NSLayoutConstraint*) view:(__kindof UIView*)v1 set:(NSLayoutAttribute)attr to:(double)val {
//    return [NSLayoutConstraint constraintWithItem:v1 attribute:attr relatedBy:NSLayoutRelationEqual
//    toItem:nil attribute:attr multiplier:1 constant:val];
//}
//
//        + (NSArray<NSLayoutConstraint*>*) views:(NSArray<__kindof UIView*>*)v1 set:(NSLayoutAttribute)attr to:(double)val {
//    NSMutableArray<NSLayoutConstraint*>*a = [NSMutableArray new];
//    for (int i = 0; i < v1.count; i++) {
//        UIView *v = v1[i];
//        a[i] = [FLLayouts view:v set:attr to:val];
//    }
//    return a;
//}
//
//#pragma mark - size
//        + (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 width:(double)w height:(double)h {
//    return @[
//        [FLLayouts view:v1 set:NSLayoutAttributeWidth to:w],
//    [FLLayouts view:v1 set:NSLayoutAttributeHeight to:h],
//    ];
//}
//
//#pragma mark - one property alignment
//// v1.attr = v2.attr + c
//        + (NSLayoutConstraint*) view:(__kindof UIView*)v1 align:(NSLayoutAttribute)attr to:(__kindof UIView*)v2 offset:(double)c {
//    return [NSLayoutConstraint constraintWithItem:v1 attribute:attr relatedBy:NSLayoutRelationEqual
//    toItem:v2 attribute:attr multiplier:1 constant:c];
//}
//
//// v1.attr = v2.attr
//        + (NSLayoutConstraint*) view:(__kindof UIView*)v1 align:(NSLayoutAttribute)attr to:(__kindof UIView*)v2 {
//    return [NSLayoutConstraint constraintWithItem:v1 attribute:attr relatedBy:NSLayoutRelationEqual
//    toItem:v2 attribute:attr multiplier:1 constant:0];
//}
//
//
//#pragma mark - Relative Layout
//// v1.bottom = v2.top - c
//        + (NSLayoutConstraint*) view:(__kindof UIView*)v1 above:(__kindof UIView*)v2 offset:(double) c {
//    return [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
//    toItem:v2 attribute:NSLayoutAttributeTop multiplier:1 constant:-c];
//}
//
//// v1.bottom = v2.top
//        + (NSLayoutConstraint*) view:(__kindof UIView*)v1 above:(__kindof UIView*)v2 {
//    return [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
//    toItem:v2 attribute:NSLayoutAttributeTop multiplier:1 constant:0];
//}
//
//// v1.top = v2.bottom + c
//        + (NSLayoutConstraint*) view:(__kindof UIView*)v1 below:(__kindof UIView*)v2 offset:(double)c {
//    return [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
//    toItem:v2 attribute:NSLayoutAttributeBottom multiplier:1 constant:c];
//}
//
//// v1.top = v2.bottom
//        + (NSLayoutConstraint*) view:(__kindof UIView*)v1 below:(__kindof UIView*)v2 {
//    return [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
//    toItem:v2 attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
//}
//
//// v1.right = v2.left + c
//        + (NSLayoutConstraint*) view:(__kindof UIView*)v1 toLeftOf:(__kindof UIView*)v2 offset:(double)c {
//    return [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual
//    toItem:v2 attribute:NSLayoutAttributeLeft multiplier:1 constant:c];
//}
//
//// v1.right = v2.left
//        + (NSLayoutConstraint*) view:(__kindof UIView*)v1 toLeftOf:(__kindof UIView*)v2 {
//    return [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual
//    toItem:v2 attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
//}
//
//// v1.left = v2.right + c
//        + (NSLayoutConstraint*) view:(__kindof UIView*)v1 toRightOf:(__kindof UIView*)v2 offset:(double)c {
//    return [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual
//    toItem:v2 attribute:NSLayoutAttributeRight multiplier:1 constant:c];
//}
//
//// v1.left = v2.right
//        + (NSLayoutConstraint*) view:(__kindof UIView*)v1 toRightOf:(__kindof UIView*)v2 {
//    return [NSLayoutConstraint constraintWithItem:v1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual
//    toItem:v2 attribute:NSLayoutAttributeRight multiplier:1 constant:0];
//}
//
//#pragma mark - Layout child
//        + (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 layoutChildAxis:(FLDirection)direction gravity:(FLGravity)gravity {
//    return [FLLayouts view:v1 layout:v1.subviews axis:direction gravity:gravity];
//}
//
//        + (NSArray<NSLayoutConstraint*>*) views:(NSArray<__kindof UIView*>*)v2 layoutAxis:(FLDirection)direction gravity:(FLGravity)gravity {
//    return [FLLayouts view:nil layout:v2 axis:direction gravity:gravity];
//}
//
//        + (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 layout:(NSArray<__kindof UIView*>*)v2 axis:(FLDirection)direction gravity:(FLGravity)gravity {
//    return [FLLayouts view:v1 layout:v2 axis:direction gravity:gravity margins:nil];
//}
//
//        + (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 layout:(NSArray<__kindof UIView*>*)v2 axis:(FLDirection)direction gravity:(FLGravity)gravity margins:(NSArray<NSNumber*>*)margins {
//    NSMutableArray<NSLayoutConstraint*>* a = [NSMutableArray new];
//    NSLayoutAttribute size = NSLayoutAttributeNotAnAttribute;
//    NSMutableArray<NSLayoutConstraint*>* b = [NSMutableArray new];
//    // For direction
//    switch (direction) {
//    case FLLeftToRight:
//        size = NSLayoutAttributeHeight;
//        break;
//    case FLTopToBottom:
//        size = NSLayoutAttributeWidth;
//        break;
//    default: break;
//    }
//    if (direction != FLDirectionNo) {
//        [a addAll: [FLLayouts view:v1 layout:v2 axis:direction]];
//    }
//    // For gravity
//    NSLayoutAttribute g = NSLayoutAttributeNotAnAttribute;
//    switch (gravity) {
//    case FLGravityLeft:    g = NSLayoutAttributeLeft;    break;
//    case FLGravityRight:   g = NSLayoutAttributeRight;   break;
//    case FLGravityTop:     g = NSLayoutAttributeTop;     break;
//    case FLGravityBottom:  g = NSLayoutAttributeBottom;  break;
//    case FLGravityCenterX: g = NSLayoutAttributeCenterX; break;
//    case FLGravityCenterY: g = NSLayoutAttributeCenterY; break;
//    case FLGravityCenter:
//        [b addAll:[FLLayouts view:v1 aline:NSLayoutAttributeCenterX to:v2]];
//        [b addAll:[FLLayouts view:v1 aline:NSLayoutAttributeCenterY to:v2]];
//        break;
//    case FLGravityMatchParent: g = size; break;
//    default: break;
//    }
//    if (g != NSLayoutAttributeNotAnAttribute) {
//        [b addAll:[FLLayouts view:v1 aline:g to:v2]];
//    }
//    if (b.count > 0) {
//        [a addAll:b];
//    }
//    [b removeAllObjects];
//    return a;
//}
//
//#pragma mark - Multiple views
//
//        + (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 aline:(NSLayoutAttribute)attr to:(NSArray<__kindof UIView*>*)v2 {
//    NSMutableArray<NSLayoutConstraint*>* a = [NSMutableArray new];
//    int from = 0;
//    UIView* p = nil;
//    if (v1) {
//        //  v1, v2 = [a, b, ..., ]
//        //  p^        ^from
//        from = 0;
//        p = v1;
//    } else {
//        //  nil, v2 = [a, b, ..., ]
//        //            p^  ^from
//        from = 1;
//        if (v2.count > 0) {
//            p = v2[0];
//        }
//    }
//    for (int i = from; i < v2.count; i++) {
//        UIView* v = v2[i];
//        if (v) {
//            [a add:[FLLayouts view:p align:attr to:v]];
//        }
//    }
//    return a;
//}
//
//        + (NSArray<NSLayoutConstraint*>*) layout:(NSArray<__kindof UIView*>*)v2 axis:(FLDirection)direction {
//    return [FLLayouts view:nil layout:v2 axis:direction gravity:FLGravityNo];
//}
//
//        + (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 layout:(NSArray<__kindof UIView*>*)v2 axis:(FLDirection)direction {
//    NSMutableArray<NSLayoutConstraint*>* a = [NSMutableArray new];
//    NSLayoutAttribute begin = NSLayoutAttributeLeft;
//    NSLayoutAttribute ended = NSLayoutAttributeRight;
//    bool upDown = direction == FLTopToBottom;
//    if (upDown) {
//        begin = NSLayoutAttributeTop;
//        ended = NSLayoutAttributeBottom;
//    }
//    NSLayoutConstraint* x;
//    long n = v2.count;
//    if (n > 0) {
//        if (v1) {
//            x = [FLLayouts view:v1 align:begin to:v2[0]];
//            [a addObject:x];
//        }
//    }
//    for (int i = 1; i < n; i++) {
//        // [... w, v]
//        UIView* v = v2[i];
//        UIView* w = v2[i-1];
//        if (upDown) {
//            x = [FLLayouts view:w above:v];
//        } else {
//            x = [FLLayouts view:w toLeftOf:v];
//        }
//        [a addObject:x];
//    }
//    if (n > 0) {
//        if (v1) {
//            x = [FLLayouts view:v1 align:ended to:v2[n - 1]];
//            [a addObject:x];
//        }
//    }
//    return a;
//}
//
//
//#pragma mark - Corner = 2 side alignment
//
//        + (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 corner:(FLCorner)at to:(__kindof UIView*)v2 {
//    return [FLLayouts view:v1 corner:at to:v2 offsetX:0 offsetY:0];
//}
//
///// v1.attr1 = v2.attr1 & v1.attr2 = v2.attr2
//        + (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 corner:(FLCorner)at to:(__kindof UIView*)v2 offsetX:(double)dx offsetY:(double)dy {
//    NSLayoutAttribute x = NSLayoutAttributeLeft;
//    NSLayoutAttribute y = NSLayoutAttributeTop;
//    if (at == FLCornerLeftTop) {
//        x = NSLayoutAttributeLeft;
//        y = NSLayoutAttributeTop;
//    } else if (at == FLCornerLeftCenterY) {
//        x = NSLayoutAttributeLeft;
//        y = NSLayoutAttributeCenterY;
//    } else if (at == FLCornerLeftBottom) {
//        x = NSLayoutAttributeLeft;
//        y = NSLayoutAttributeBottom;
//    } else if (at == FLCornerCenterXTop) {
//        x = NSLayoutAttributeCenterX;
//        y = NSLayoutAttributeTop;
//    } else if (at == FLCornerCenterXCenterY) {
//        x = NSLayoutAttributeCenterX;
//        y = NSLayoutAttributeCenterY;
//    } else if (at == FLCornerCenterXBottom) {
//        x = NSLayoutAttributeCenterX;
//        y = NSLayoutAttributeBottom;
//    } else if (at == FLCornerRightTop) {
//        x = NSLayoutAttributeRight;
//        y = NSLayoutAttributeTop;
//    } else if (at == FLCornerRightCenterY) {
//        x = NSLayoutAttributeRight;
//        y = NSLayoutAttributeCenterY;
//    } else if (at == FLCornerRightBottom){
//        x = NSLayoutAttributeRight;
//        y = NSLayoutAttributeBottom;
//    }
//    return @[[FLLayouts view:v1 align:x to:v2 offset:dx],
//    [FLLayouts view:v1 align:y to:v2 offset:dy],
//    ];
//}
//
//
//#pragma mark - Drawer
//        + (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 drawer:(FLSide)at to:(__kindof UIView*)v2 depth:(double)d {
//    return [FLLayouts view:v1 drawer:at to:v2 depth:d offset:UIEdgeInsetsZero];
//}
//
//        + (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 drawer:(FLSide)at to:(__kindof UIView*)v2 depth:(double)d offset:(UIEdgeInsets)margin {
//    NSMutableArray<NSLayoutConstraint*> *a = [NSMutableArray new];
//    if (at == FLSideNo) {
//        return a;
//    }
//    NSLayoutConstraint *c;
//    // left
//    if (at == FLSideRight) {
//        c = [FLLayouts view:v1 set:NSLayoutAttributeWidth to:d];
//    } else {
//        c = [FLLayouts view:v1 align:NSLayoutAttributeLeft to:v2 offset:margin.left];
//    }
//    [a add:c];
//    // top
//    if (at == FLSideBottom) {
//        c = [FLLayouts view:v1 set:NSLayoutAttributeHeight to:d];
//    } else {
//        c = [FLLayouts view:v1 align:NSLayoutAttributeTop to:v2 offset:margin.top];
//    }
//    [a add:c];
//    // right
//    if (at == FLSideLeft) {
//        c = [FLLayouts view:v1 set:NSLayoutAttributeWidth to:d];
//    } else {
//        c = [FLLayouts view:v1 align:NSLayoutAttributeRight to:v2 offset:-margin.right];
//    }
//    [a add:c];
//    // bottom
//    if (at == FLSideTop) {
//        c = [FLLayouts view:v1 set:NSLayoutAttributeHeight to:d];
//    } else {
//        c = [FLLayouts view:v1 align:NSLayoutAttributeBottom to:v2 offset:-margin.bottom];
//    }
//    [a add:c];
//    return a;
//}
//
//#pragma mark - Same
//
//// v1.width = v2.width
//// v1.height = v2.height
//        + (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 sameWHTo:(__kindof UIView*)v2 {
//    return @[
//        [FLLayouts view:v1 align:NSLayoutAttributeWidth to:v2],
//    [FLLayouts view:v1 align:NSLayoutAttributeHeight to:v2],
//    ];
//}
//
//// v1.left = v2.left
//// v1.right = v2.right
//        + (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 sameXTo:(__kindof UIView*)v2 {
//    return [FLLayouts view:v1 sameXTo:v2 offset:UIEdgeInsetsZero];
//}
//
//        + (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 sameXTo:(__kindof UIView*)v2 offset:(UIEdgeInsets)margin {
//    return @[
//        [FLLayouts view:v1 align:NSLayoutAttributeLeft to:v2 offset:margin.left],
//    [FLLayouts view:v1 align:NSLayoutAttributeRight to:v2 offset:-margin.right],
//    ];
//}
//
//// v1.top = v2.top
//// v1.bottom = v2.bottom
//        + (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 sameYTo:(__kindof UIView*)v2 {
//    return [FLLayouts view:v1 sameYTo:v2 offset:UIEdgeInsetsZero];
//}
//
//        + (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 sameYTo:(__kindof UIView*)v2 offset:(UIEdgeInsets)margin {
//    return @[
//        [FLLayouts view:v1 align:NSLayoutAttributeTop to:v2 offset:margin.top],
//    [FLLayouts view:v1 align:NSLayoutAttributeBottom to:v2 offset:-margin.bottom],
//    ];
//}
//
//        + (NSArray<NSLayoutConstraint*>*) view:(__kindof UIView*)v1 sameTo:(__kindof UIView*)v2 {
//    return [FLLayouts view:v1 sameTo:v2 offset:UIEdgeInsetsZero];
//}
//
//        + (NSArray<NSLayoutConstraint*>*)view:(__kindof UIView *)v1 sameTo:(__kindof UIView *)v2 offset:(UIEdgeInsets)margin {
//    return @[
//        [FLLayouts view:v1 align:NSLayoutAttributeTop to:v2 offset:+margin.top],
//    [FLLayouts view:v1 align:NSLayoutAttributeLeft to:v2 offset:+margin.left],
//    [FLLayouts view:v1 align:NSLayoutAttributeRight to:v2 offset:-margin.right],
//    [FLLayouts view:v1 align:NSLayoutAttributeBottom to:v2 offset:-margin.bottom],
//    ];
//}
//
//#pragma mark - Sames
//// v[0].attr = v[i].attr for i = 1 ~ n-1
//        + (NSArray<NSLayoutConstraint*>*) views:(NSArray<__kindof UIView*>*)vs align:(NSLayoutAttribute)attr {
//    NSMutableArray<NSLayoutConstraint*> *a = [NSMutableArray new];
//    for (int i = 1; i < vs.count; i++) {
//        NSLayoutConstraint* c = [FLLayouts view:vs[i] align:attr to:vs[0]];
//        [a add:c];
//    }
//    return a;
//}
//
//        + (NSArray<NSLayoutConstraint*>*) views:(NSArray<__kindof UIView*>*)vs same:(FLSame)opt {
//    NSMutableArray<NSLayoutConstraint*> *a = [NSMutableArray new];
//    FLSame same = FLSameNo;
//    NSArray<NSLayoutConstraint*>*(^run)(UIView *, UIView *) = nil;
//    if (opt == FLSameLeftRight) {
//        run = ^NSArray<NSLayoutConstraint*>*(UIView *v1, UIView *v2) {
//            return [FLLayouts view:v1 sameXTo:v2];
//        };
//    } else if (opt == FLSameTopBottom) {
//        run = ^NSArray<NSLayoutConstraint*>*(UIView *v1, UIView *v2) {
//            return [FLLayouts view:v1 sameYTo:v2];
//        };
//    } else if (opt == FLSameWidthHeight) {
//        run = ^NSArray<NSLayoutConstraint*>*(UIView *v1, UIView *v2) {
//            return [FLLayouts view:v1 sameWHTo:v2];
//        };
//    } else if (opt == FLSameLeftTopRightBottom) {
//        run = ^NSArray<NSLayoutConstraint*>*(UIView *v1, UIView *v2) {
//            return [FLLayouts view:v1 sameTo:v2];
//        };
//    } else {
//    }
//    if (run) {
//        for (int i = 1; i < vs.count; i++) {
//            NSArray<NSLayoutConstraint*>* c = run(vs[i], vs[0]);
//            [a addAll:c];
//        }
//    }
//    return a;
//}
//
//
//        - (void) addStackView:(UIView*) parent {
//    // 0 = fill equal same row/column
//    // 1 = given width/height
//    int way = 0;
//    UIStackView* a;
//    a = [UIStackView new];
//    //a = self.horiz;
//    a.axis = UILayoutConstraintAxisVertical;
//    a.axis = UILayoutConstraintAxisHorizontal;
//    if (way == 0) {
//        a.alignment = UIStackViewAlignmentFill;
//        a.distribution = UIStackViewDistributionFillEqually;
//    } else if (way == 1) {
//        a.alignment = UIStackViewAlignmentLeading;
//        a.alignment = UIStackViewAlignmentCenter;
//        a.alignment = UIStackViewAlignmentTrailing;
//        a.distribution = UIStackViewDistributionEqualSpacing;
//    } else {
//
//    }
//    a.spacing = 2;
//    NSMutableArray<NSLayoutConstraint*> * cons = [NSMutableArray new];
//    for (int i = 0; i < 5; i++) {
//        UIView *x = [UIView new];
//        x.layer.backgroundColor = FLUIKit.color12[i].CGColor;
//        // No use addSubview for it
//        // [a addSubview:x]; fails for stackview
//        if (way == 0) {
//            [a addArrangedSubview:x];
//        } else if (way == 1) {
//            [cons add:[x.widthAnchor constraintEqualToConstant:20 + 10* i] ];
//            [cons add:[x.heightAnchor constraintEqualToConstant:20 + 10* i] ];
//
//        }
//        //[cons add:[x.heightAnchor constraintEqualToConstant:20 + 10* i] ];
//
//        //[cons add:[x.widthAnchor constraintEqualToConstant:20 + 10* i] ];
//        //[cons add: [FLLayouts view:x align:NSLayoutAttributeWidth to:a ] ];
//        //[cons add: [FLLayouts view:x set:NSLayoutAttributeHeight to:20] ];
//        //[cons add: [FLLayouts view:x set:NSLayoutAttributeWidth to:20] ];
//
//        //[a addSubview:x];
//        //[a addArrangedSubview:x];
//    }
//    if (way == 1) {
//        [FLLayouts applyConstraints:cons];
//    } else if (way == 2) {
//
//    } else {
//
//    }
//    //[FLLayouts applyConstraints:cons];
//    //[FLLayouts activate:a forConstraint:cons];
//    a.layer.backgroundColor = UIColor.brownColor.CGColor;
//    CGRect f;
//    f = CGRectMake(0, 200, 300, 70);
//    a.frame = f;
//    [parent addSubview:a];
//}
//
////+ (instancetype)constraintWithItem:(__kindof UIView*)view attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(nullable id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c API_AVAILABLE(macos(10.7), ios(6.0), tvos(9.0));
//
//@end
//
//#pragma clang diagnostic pop
//
