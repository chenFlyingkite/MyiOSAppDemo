//
// Created by Eric Chen on 2021/1/22.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class FLStructs {
    // returns the rect that the pixel that alpha > 0's bounds
    // default precision is 1, so checking each pixel (i, j) where i % precision == 0 && j % precision == 0
    // for faster but rough result by using larger value of precision, like 4, so returned each component of (l, t, r, b) will be multiply of precision
    // That is, if given precision = 1 returns (123, 456, 789, 1011)
    // , then given precision = 10 may returns (120, 450, 780, 1010)
    class func rectingPositiveAlpha(_ img:UIImage, _ precision:Int = 1) -> CGRect {
        let log = 0 > 0
        if (log) {
            wqe("cgm = \(img.cgImage)")
        }
        //wqe("dat = \(img.cgImage?.dataProvider?.data)") // data is large, no print me
        let clk = FLTicTac()
        if let cgm = img.cgImage,
           let dat = cgm.dataProvider?.data {
            let pixels = CFDataGetBytePtr(dat)!
            let n = CFDataGetLength(dat)
            if (log) {
                print("\(n) bytes in pixels \(pixels)")
            }
            let w = cgm.width
            let h = cgm.height
            let bpr = cgm.bytesPerRow
            let bpp = cgm.bitsPerPixel / 8
            if (log) {
                print("\(w)x\(h) bytes bpr = \(bpr), bpp \(bpp)")
            }
            // scan all the pixels....
            clk.tic()
            var l = w, t = h, r = 0, b = 0
            var found = false
            // peeking image contents
            var seeX = false, seeY = false
            let xn = ceil(1.0 * w / precision).roundInt()
            let yn = ceil(1.0 * h / precision).roundInt()
            let dx = 100, dy = 100
            for jj in 0..<yn {
                let j = min(h, jj * precision)
                seeY = j % dy == 0
                if (seeY) {
                    if (log) {
                        print("#\(String.init(format: "%4d", j)) : ", terminator: "")
                    }
                }
                for ii in 0..<xn {
                    let i = min(w, ii * precision)
                    var k = j * bpr + i * bpp
                    // Is it work for various color format?, argb or rgba ?
                    var cr = pixels[k+0]
                    var cg = pixels[k+1]
                    var cb = pixels[k+2]
                    var ca = pixels[k+3]
                    seeX = i % dx == 0
                    var see = seeX && seeY
                    if (see) {
                        if (log) {
                            let clr = UIColor.init(argb: Int32(ca), r: Int32(cr), g: Int32(cg), b: Int32(cb))
                            let s = String(format: "%08x", clr.colorInt())
                            print(" \(s),", terminator: "")
                        }
                    }
                    if (ca != 0) {
                        found = true
                        l = min(l, i)
                        t = min(t, j)
                        r = max(r, i)
                        b = max(b, j)
                    }
                }
                if (seeY) {
                    if (log) {
                        print("")
                    }
                }
            }
            clk.tacS("see each pixel gets(l,t,r,b) = (\(l), \(t), \(r), \(b))")
            if (found) {
                return CGRect(l: l, t: t, r: r, b: b)
            }
        }
        return CGRect.zero
    }
}

extension UIEdgeInsets {
    public init(_ v:CGFloat) {
        // fails...
        //top = left = right = bottom = v
        self.init(top: v, left: v, bottom: v, right: v)
    }

    public init(x:CGFloat, y:CGFloat) {
        self.init(top: y, left: x, bottom: y, right: x)
    }

    public func negate() -> UIEdgeInsets {
        return UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
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

    public init(l: Double, t:Double, r:Double, b:Double) {
        self.init(x: l, y: t, width: r - l, height: b - t)
    }
    public init(l: Int, t:Int, r:Int, b:Int) {
        self.init(x: l, y: t, width: r - l, height: b - t)
    }

    public static let unit = CGRect(x: 0, y: 0, width: 1, height: 1)

    public func scale(sx: Double, sy:Double) -> CGRect {
        return Self.init(x: self.left * sx, y: self.top * sy, width: self.width.lf() * sx, height: self.height.lf() * sy)
    }
    public func divide(_ w: Double, _ h:Double) -> CGRect {
        return Self.init(l: self.left / w, t: self.top / h, r: self.right / w, b: self.bottom / h)
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

    public func extend(_ ins: UIEdgeInsets) -> CGRect {
        let dl = ins.left.lf()
        let dt = ins.top.lf()
        let dr = ins.right.lf()
        let db = ins.bottom.lf()
        let ml = left + dl
        let mt = top + dt
        let mw = width.lf() - (dl + dr)
        let mh = height.lf() - (dt + db)
        return Self.init(x: ml, y: mt, width: mw, height: mh)
    }
}

//Geometry
extension CGPoint {
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

    public static let unit = CGPoint(x: 1, y: 1)
}

//Geometry
extension CGSize {
    public static let unit = CGSize(width: 1, height: 1)

    public func wxh() -> String {
        return String.init(format: "%dx%d", Int(self.width), Int(self.height));
    }
}