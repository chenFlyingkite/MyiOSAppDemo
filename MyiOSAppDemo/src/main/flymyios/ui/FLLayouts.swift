//
// Created by Eric Chen on 2020/12/29.
//

import Foundation
import UIKit

//https://www.wolfram.com/mathematica/new-in-8/comprehensive-image-processing-environment/

public enum FLDirection : Character {
    case leftToRight = "-"
    case topToBottom = "|"
    case no          = "?"
}

public enum FLGravity : Character {
    case left        = "L"
    case right       = "R"
    case top         = "T"
    case bottom      = "B"
    case centerX     = "X"
    case centerY     = "Y"
    case center      = "C"
    case matchParent = "M"
    case no          = "?"
}

// chars are define like the 3*4 calculator pad

public enum FLCorner : Character {
    case leftTop        = "7"
    case leftCenterY    = "4"
    case leftBottom     = "1"
    case centerXTop     = "8"
    case centerXCenterY = "5"
    case centerXBottom  = "2"
    case rightTop       = "9"
    case rightCenterY   = "6"
    case rightBottom    = "3"
    case no             = "0"

    private static let order = "123456789".toChars()
    public static func of(_ i:Int) -> Self {
        if (1 <= i && i <= 9) {
            let c = order[i-1]
            return Self.init(rawValue: c)!
        } else {
            return .no
        }
    }
}

public enum FLSame : Character {
    case leftRight          = "H"
    case topBottom          = "I"
    case widthHeight        = "+"
    case leftTopRightBottom = "#"
    case no                 = "?"
}

public enum FLSide : Character {
    case left   = "L"
    case top    = "T"
    case right  = "R"
    case bottom = "B"
    case no     = "?"
}

public class FLLayouts {
    public typealias NSLayoutAttribute = NSLayoutConstraint.Attribute

    // MARK: Apply contraint
    public class func activate(_ root: UIView, forConstraint all: Array<Any>) -> Void {
        // Not use the root.subViews, since it will find UISlider's contraint
        // <_UISlideriOSVisualElement: 0x14b6145f0; frame = (0 0; 100 34); opaque = NO; autoresize = W+H; layer = <CALayer: 0x283337920>>
        // and cause UISlider fail to layout with given constraints

        // Step 1: Collects the used views in constraints, exclude root
        var used: Set<UIView> = Self.getUsedViews(all)
        // Omit root since it may have constraint from storyboard
        used.remove(root)

        Self.disableAutoResizingMask(used)
        // Self.disableAutoResizingMask(used.toArray()) // same
        Self.applyConstraints(all)
    }

    public class func disableAutoResizingMask(_ child: Set<UIView>) -> Void {
        for v in child {
            v.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    public class func disableAutoResizingMask(_ child: Array<UIView>) -> Void {
        let n = child.count
        for i in 0..<n {
            let v = child[i]
            v.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    // Type = NSArray<NSLayoutConstraint*>* or NSLayoutConstraint*
    public class func applyConstraints(_ all: Array<Any>) -> Void {
        let a = Self.expand(all)
        NSLayoutConstraint.activate(a)
    }

    // MARK: Add views
    // DFS on child and add child to parent, then return root (child's parent)
    @discardableResult
    public class func addViewTo(_ root: UIView, child:Array<Any>) -> UIView {
        //let isToStack = root is UIStackView// [root isKindOfClass:UIStackView.class];
        let n = child.count
        for i in 0..<n {
            let x = child[i]
            var w: UIView? = nil
            if let a = x as? Array<Any> {
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

    // MARK: DFS methods
    // Let all = [NSLayoutConstraint or [NSLayoutConstraint]]
    // Returns non-null UIView used in NSLayoutConstraint, named S,
    // formally defined as S = {x.firstItem, x.secondItem} for each x in all
    private class func getUsedViews(_ all:Array<Any>) -> Set<UIView> {
        var used:Set<UIView> = [];
        for x in all {
            if let a = x as? Array<Any> {
                let inner = Self.getUsedViews(a)
                used = used.union(inner)
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

    private class func expand(_ all:Array<Any>) -> Array<NSLayoutConstraint> {
        var used: Array<NSLayoutConstraint> = []
        for x in all {
            if let a = x as? Array<Any> {
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

    // Expand all as List<UIView>
    public class func expandAllViews(_ all:Array<Any>) -> Array<UIView> {
        var used:Array<UIView> = []
        for x in all {
            if let a = x as? Array<Any> {
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

    // Round robin on margins
    private class func round(_ x:Int, _ n:Int) -> Int {
        if (x == n - 1) {
            return 0
        } else {
            return x + 1
        }
    }

    // MARK: Safe area
    public class func view(_ v1:UIView, equalToSafeAreaOf v2:UIView) -> Array<NSLayoutConstraint> {
        let g = v2.safeAreaLayoutGuide
        return [
            v1.topAnchor.constraint(equalTo: g.topAnchor),
            v1.leftAnchor.constraint(equalTo: g.leftAnchor),
            v1.rightAnchor.constraint(equalTo: g.rightAnchor),
            v1.bottomAnchor.constraint(equalTo: g.bottomAnchor),
        ]
    }

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

    // MARK: Size
    public class func view(_ v1:UIView, width:Double , height: Double) -> Array<NSLayoutConstraint> {
        return [
            Self.view(v1, set: .width, to: width),
            Self.view(v1, set: .height, to: height),
        ]
    }

    // MARK: v1.attr = v2.attr + c
    public class func view(_ v1:UIView? = nil, aline attr:NSLayoutAttribute, to v2:Array<UIView>, margins margins:Array<Double> = [0]) -> Array<NSLayoutConstraint> {
        var ans:[NSLayoutConstraint] = []
        let n = v2.count
        if (n == 0) {
            return ans
        }

        // Determine first one
        var from:Int = 0
        var p:UIView
        if let v1 = v1 {
            //  v1, v2 = [a, b, ..., ]
            //  p^        ^from
            from = 0
            p = v1
        } else {
            //  nil, v2 = [a, b, ..., ]
            //            p^  ^from
            from = 1
            p = v2[0];
        }
        // margin index
        var gaps = margins
        var gat = 0
        if (gaps.count == 0) {
            gaps = [0]
        }
        let glen = gaps.count
        // margin

        // Create them
        for i in from..<n {
            let v = v2[i]
            let dx = gaps[gat]
            let c = Self.view(p, align: attr, to: v, offset: dx)
            ans.append(c)
            // Round robin on margins
            gat = round(gat, glen)
        }
        return ans
    }

    public class func view(_ v1:UIView, align attr:NSLayoutAttribute, to v2:UIView, offset c:Double = 0) -> NSLayoutConstraint {
        return NSLayoutConstraint.init(item: v1, attribute: attr, relatedBy: .equal,
                toItem: v2, attribute: attr, multiplier: 1, constant: CGFloat(c))
    }

    // MARK: Relative Layout, above|below, to(Left|Right)Of
    // v1.bottom = v2.top - c
    public class func view(_ v1:UIView, above v2:UIView, offset c:Double = 0) -> NSLayoutConstraint {
        return NSLayoutConstraint.init(item: v1, attribute: .bottom, relatedBy: .equal,
                toItem: v2, attribute: .top, multiplier: 1, constant: CGFloat(-c))
    }

    public class func view(_ v1:UIView, below v2:UIView, offset c:Double = 0) -> NSLayoutConstraint {
        return Self.view(v2, above:v1, offset: -c)
    }

    // v1.left = v2.right + c
    public class func view(_ v1:UIView, toLeftOf v2:UIView, offset c:Double = 0) -> NSLayoutConstraint {
        return NSLayoutConstraint.init(item: v1, attribute: .right, relatedBy: .equal,
                toItem: v2, attribute: .left, multiplier: 1, constant: CGFloat(-c))
    }

    public class func view(_ v1:UIView, toRightOf v2:UIView, offset c:Double = 0) -> NSLayoutConstraint {
        return Self.view(v2, toLeftOf:v1, offset: -c)
    }

    // MARK: Linear layout
    public class func layout(_ v2:Array<UIView>, axis direction:FLDirection, margins gaps: Array<Double> = [0]) -> Array<NSLayoutConstraint> {
        return Self.view(nil, layout: v2, axis: direction, margins:gaps)
    }

    public class func view(_ v1:UIView?, layout v2:Array<UIView>, axis direction:FLDirection, margins margins: Array<Double> = [0]) -> Array<NSLayoutConstraint> {
        var ans:Array<NSLayoutConstraint> = []
        let n = v2.count
        var head:NSLayoutAttribute = .left
        var tail:NSLayoutAttribute = .right
        let upDown = direction == .topToBottom
        if (upDown) {
            head = .top
            tail = .bottom
        }
        // margin index
        var gaps = margins
        var gat = 0
        if (gaps.count == 0) {
            gaps = [0]
        }
        let glen = gaps.count
        // margin

        var dx:Double = 0
        // first one
        if let v1 = v1 {
            dx = gaps[gat]
            let c = Self.view(v1, align: head, to: v2[0], offset:dx)
            ans.append(c)
            gat = round(gat, glen)
        }

        // Create middle
        for i in 1..<n {
            let v = v2[i]
            let w = v2[i-1]
            dx = gaps[gat]
            var c : NSLayoutConstraint
            if (upDown) {
                c = Self.view(w, above:v, offset:dx)
            } else {
                c = Self.view(w, toLeftOf: v, offset:dx)
            }
            ans.append(c)
            gat = round(gat, glen)
        }

        // last one
        if let v1 = v1 {
            dx = gaps[gat]
            let c = Self.view(v1, align: tail, to: v2[n-1], offset:dx)
            ans.append(c)
            gat = round(gat, glen)
        }

        return ans
    }

    public class func view(_ v1:UIView, layout v2:Array<UIView>, axis direction:FLDirection, gravity gravity:FLGravity, margins margins:Array<Double>) -> Array<NSLayoutConstraint> {
        var ans:Array<NSLayoutConstraint> = []
        var size: NSLayoutAttribute = .notAnAttribute
        switch (direction) {
        case .leftToRight: size = .height
        case .topToBottom: size = .width
        default: break
        }
        // For direction
        if (direction != .no) {
            let cs = Self.view(v1, layout: v2, axis: direction)
            ans += cs
        }

        // For gravity
        var g: NSLayoutAttribute = .notAnAttribute
        switch (gravity) {
        case .left: g = .left
        case .right: g = .right
        case .top: g = .top
        case .bottom: g = .bottom
        case .centerX: g = .centerX
        case .centerY: g = .centerY
        case .center: do {
            ans += Self.view(v1, aline: .centerX, to: v2)
            ans += Self.view(v1, aline: .centerY, to: v2)
            break
        }
        case .matchParent: g = size
        default: break
        }
        if (g != .notAnAttribute) {
            ans += Self.view(v1, aline: g, to: v2)
        }
        return ans
    }

    // MARK: Corner = 2 side alignment
    public class func view(_ v1:UIView, corner at:FLCorner, to v2:UIView, offsetX dx:Double = 0, offsetY dy:Double = 0) -> Array<NSLayoutConstraint> {
        var ans:Array<NSLayoutConstraint> = []
        var x:NSLayoutAttribute = .left
        var y:NSLayoutAttribute = .top
        if (at == .leftTop) {
            x = .left
            y = .top
        } else if (at == .leftCenterY) {
            x = .left
            y = .centerY
        } else if (at == .leftBottom) {
            x = .left
            y = .bottom
        } else if (at == .centerXTop) {
            x = .centerX
            y = .top
        } else if (at == .centerXCenterY) {
            x = .centerX
            y = .centerY
        } else if (at == .centerXBottom) {
            x = .centerX
            y = .bottom
        } else if (at == .rightTop) {
            x = .right
            y = .top
        } else if (at == .rightCenterY) {
            x = .right
            y = .centerY
        } else if (at == .rightBottom) {
            x = .right
            y = .bottom
        } else {
        }
        ans.append(Self.view(v1, align: x, to: v2, offset: dx))
        ans.append(Self.view(v1, align: y, to: v2, offset: dy))
        return ans
    }

    // MARK: Drawer
    public class func view(_ v1:UIView, drawer at:FLSide, to v2:UIView, depth d:Double, offset margin:UIEdgeInsets = .zero) -> Array<NSLayoutConstraint> {
        var ans:Array<NSLayoutConstraint> = []
        if (at == .no) {
            return ans
        }

        var c: NSLayoutConstraint
        // left
        if (at == .right) {
            c = Self.view(v1, set: .width, to: d)
        } else {
            c = Self.view(v1, align:.left, to: v2, offset:Double(margin.left))
        }
        ans.append(c)
        // top
        if (at == .bottom) {
            c = Self.view(v1, set: .height, to: d)
        } else {
            c = Self.view(v1, align: .top, to: v2, offset: Double(margin.top))
        }
        ans.append(c)
        // right
        if (at == .left) {
            c = Self.view(v1, set: .width, to: d)
        } else {
            c = Self.view(v1, align: .right, to: v2, offset:Double(-margin.right))
        }
        ans.append(c)
        // bottom
        if (at == .bottom) {
            c = Self.view(v1, set: .height, to: d)
        } else {
            c = Self.view(v1, align: .bottom, to: v2, offset:Double(-margin.bottom))
        }
        ans.append(c)
        return ans
    }

    // Mark: - Same
    // v1.(width|height) = v2.(width|height) + (dx|dy)
    public class func view(_ v1:UIView, sameWHTo v2:UIView, offsetX dx:Double = 0, offsetY dy:Double = 0) -> Array<NSLayoutConstraint> {
        return [
            Self.view(v1, align: .width, to: v2, offset: dx),
            Self.view(v1, align: .height, to: v2, offset: dy),
        ]
    }

    // v1.(left|right) = v2.(left|right) + (dx|dy)
    public class func view(_ v1:UIView, sameXTo v2:UIView, offset margin:UIEdgeInsets = .zero) -> Array<NSLayoutConstraint> {
        return [
            Self.view(v1, align: .left, to: v2, offset:Double(margin.left)),
            Self.view(v1, align: .right, to: v2, offset:Double(-margin.right)),
        ]
    }

    // v1.(top|bottom) = v2.(top|bottom) + (dx|dy)
    public class func view(_ v1:UIView, sameYTo v2:UIView, offset margin:UIEdgeInsets = .zero) -> Array<NSLayoutConstraint> {
        return [
            Self.view(v1, align: .top, to: v2, offset:Double(margin.top)),
            Self.view(v1, align: .bottom, to: v2, offset:Double(-margin.bottom)),
        ]
    }

    // v1.allSides = v2.allSides + offset
    public class func view(_ v1:UIView, sameTo v2:UIView, offset margin:UIEdgeInsets = .zero) -> Array<NSLayoutConstraint> {
        return [
            Self.view(v1, align: .top, to: v2, offset:Double(margin.top)),
            Self.view(v1, align: .left, to: v2, offset:Double(margin.left)),
            Self.view(v1, align: .right, to: v2, offset:Double(-margin.right)),
            Self.view(v1, align: .bottom, to: v2, offset:Double(-margin.bottom)),
        ]
    }

    public class func views(_ v1:Array<UIView>, same opt:FLSame, margins margins:UIEdgeInsets = .zero) -> Array<NSLayoutConstraint> {
        var ans:Array<NSLayoutConstraint> = []
        let n = v1.count
        if (opt == .no || n == 0) {
            return ans
        } else {
            var c :Array<NSLayoutConstraint> = []
            let p = v1[0]
            for i in 1..<n {
                let vi = v1[i]
                if (opt == .leftRight) {
                    c = Self.view(p, sameXTo: vi, offset: margins)
                } else if (opt == .topBottom) {
                    c = Self.view(p, sameYTo: vi, offset:margins)
                } else if (opt == .widthHeight) {
                    c = Self.view(p, sameWHTo: vi, offsetX:Double(margins.left), offsetY:Double(margins.top))
                } else if (opt == .leftTopRightBottom) {
                    c = Self.view(p, sameTo: vi, offset:margins)
                } else {
                    c = []
                }
                if (c.count > 0) {
                    ans += c
                }
            }
        }
        return ans
    }

    // TODO : Going

}