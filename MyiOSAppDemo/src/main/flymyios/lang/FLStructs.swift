//
// Created by Eric Chen on 2021/1/22.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

//class FLStructs {
//}
#if false

extension UIEdgeInsets {
    public init(_ v:CGFloat) {
        // fails...
        //top = left = right = bottom = v
        self.init(top: v, left: v, bottom: v, right: v)
    }

    public init(x:CGFloat, y:CGFloat) {
        self.init(top: y, left: x, bottom: y, right: x)
    }
}

//Geometry
extension CGRect {
    public var left : Double {
        get {return Double(origin.x)}
    }
    public var top : Double {
        get {return Double(origin.y)}
    }
    public var right : Double {
        get {return Double(origin.x + size.width)}
    }
    public var bottom : Double {
        get {return Double(origin.y + size.height)}
    }
    public var ltrb : String {
        get {return String(format: "[%.0f,%.0f - %.0f,%.0f]", left, top, right, bottom) }
    }

    public static let sortTopLeft: (CGRect, CGRect) -> Bool = { r1, r2 in
        // sort by top left
        let L1 = r1.left, t1 = r1.top
        let L2 = r2.left, t2 = r2.top
        if (t1 != t2) {
            return t1 < t2
        }
        // t1 == t2
        if (L1 != L2) {
            return L1 < L2
        }
        // same
        return true
    }
}

//Geometry
extension CGPoint  {
    public func length(_ p:CGPoint = .zero) -> CGFloat {
        let q = vectorTo(p)
        return hypot(q.x, q.y)
    }

    //  ->
    //  AB = A.vectorTo(B)
    public func vectorTo(_ p:CGPoint) -> CGPoint {
        return p.offset(self.negate())
    }

    // http://www.cplusplus.com/reference/cmath/atan2/
    // atan2(y, x) = arc tangent of (y/x), [-pi ~ +pi]
    public func degree() -> Double {
        // Swift fail to perform auto casting to double...., so we uses verbose Double()
        return radToDeg(Double(atan2(y, x)))
    }

    public func offset(_ p:CGPoint) -> CGPoint {
        return CGPoint.init(x: x + p.x, y: y + p.y)
    }

    public func center(_ p:CGPoint) -> CGPoint {
        return CGPoint.init(x: (x + p.x) / 2, y: (y + p.y) / 2)
    }

    public func negate() -> CGPoint {
        return CGPoint.init(x: -x, y: -y)
    }

    public func f2() -> String {
        return String.init(format:"(%7.2f, %7.2f)", self.x, self.y)
    }

    public func toPointF() -> PointF {
        let p = PointF.init()
        let q = self
        p.x = Double(q.x)
        p.y = Double(q.y)
        return p
    }
}

//Geometry
extension CGSize {
    public func wxh() -> String {
        return String.init(format: "%dx%d", Int(self.width), Int(self.height));
    }
}

#else
#endif