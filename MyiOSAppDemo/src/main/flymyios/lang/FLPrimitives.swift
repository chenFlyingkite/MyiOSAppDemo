//
// Created by Eric Chen on 2021/2/5.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

// This class extends the basic functions for Primitive types, like
// Int, Long, Float, Double, Character,
// also String, Array,
// FLCollections owns the basic methods for Dictionary and more
class FLPrimitives {

//        FLPrimitives.peekStringSize("Remove any object, retry until perfect")
//        FLPrimitives.peekStringSize("Get ready for spring with new themed decorations")
//        FLPrimitives.peekStringSize("Surround your snaps in stylish \nwraparound effects")
//        FLPrimitives.peekStringSize("Create bizarre and wonderful \nexpressions with Surreal Art")

    @objc
    class func peekStringSize(_ key:String) {
        let a = ["zh-Hans", "zh-Hant", "ja", "ko",
                 "de", "en", "es", "fr", "it", "pt-BR", "ru",
                 "Base"]
        let n = a.count
        var i = 0
        var k = key
        while (i < n) {
            let ai = a[i]
            let p = Bundle.main.path(forResource: ai, ofType: "lproj") ?? ""
            let b = Bundle(path: p)
            let s = b?.localizedString(forKey: k, value: "", table: nil) ?? ""
            let w = CGSize(width: 100, height: .max)
            let z = NSString(string: s).boundingRect(with: w, options: .usesLineFragmentOrigin, attributes: nil, context: nil)
            let q = Self.measureSize(s, UIFont.systemFont(ofSize: 19), width: 100)
            wqe("la = \(ai), s(\(s.count)) = \(s), w = \(w), z = \(z), q = \(q), p = \(p)")
            i++
        }
    }

    class func measureWrapHeight(_ t:UILabel) -> CGRect {
        return Self.measureWrapContent(t, atMostWidth: t.frame.width.lf())
    }

    class func measureWrapWidth(_ t:UILabel) -> CGRect {
        return Self.measureWrapContent(t, atMostHeight: t.frame.height.lf())
    }

    class func measureWrapContent(_ t:UILabel, atMostWidth w: Double) -> CGRect {
        return Self.measureSize(t.text ?? "", t.font, width: w)
    }

    class func measureWrapContent(_ t:UILabel, atMostHeight h: Double) -> CGRect {
        return Self.measureSize(t.text ?? "", t.font, height: h)
    }

    // return the rect that measured as compact bounding rect for string in font
    // bottom + 1 is to make additional space for it, too compact may make text still truncated
    class func measureSize(_ str: String, _ font:UIFont, width: Double) -> CGRect {
        let r = NSString(string: str).boundingRect(with: CGSize(width: width, height: 1.0 * Int.max),
                options: .usesLineFragmentOrigin,
                attributes: [.font: font],
                context: nil)
        let ans = CGRect(l: r.left, t: r.top, r: r.right, b: r.bottom + 1)
        return ans
    }

    // right + 1 is to make additional space for it, too compact may make text still truncated
    class func measureSize(_ str: String, _ font:UIFont, height: Double) -> CGRect {
        let r = NSString(string: str).boundingRect(with: CGSize(width: 1.0 * Int.max, height: height),
                options: .usesLineFragmentOrigin,
                attributes: [.font: font],
                context: nil)
        let ans = CGRect(l: r.left, t: r.top, r: r.right + 1, b: r.bottom)
        return ans
    }
}


extension String {

    // Swift does not have the basic method of char arrays..
    func toChars() -> [Character] {
        var cs:[Character] = []
        var s = String(self);
        let n = s.count
        for i in 0..<n {
            let c = s.removeFirst()
            cs.append(c)
        }
        return cs
    }

    // return i where s[i] is the k-th character of c, -1 is not found
    // at = 0 -> return s
    // at > 0 -> from head count at-th char position
    // at < 0 -> .... tail ....
    private func find(_ s:String, _ c:Character, _ at:Int) -> Int {
        if (at == 0) { return -1 }

        let cs = s.toChars()
        let n = cs.count
        let dst = abs(at)
        var now = 0;
        for i in 0..<n {
            let k = (at >= 0) ? (i) : (n-1-i)
            if (cs[k] == c) {
                now++
                if (now == dst) {
                    return k
                }
            }
        }
        return -1
    }

    // Swift is very messy for s.substring(s.lastIndexOf(e)+1)
    // return s.substring(s.lastIndexOf(c) + 1) by given character c
    func after(_ c:Character, _ k : Int = 1) -> String {
        let s = self
        let at = self.find(s, c, k)
        if (at < 0) {
            return s
        } else {
            let e = Index.init(utf16Offset: at, in: s)
            let e1 = s.index(after: e)
            return String(s[e1...])
        }
    }
}

// Primitive types
//extension Array<Element> {
extension Array {
    func printAll() {
        print(toString())
    }

    // [A, B, C, [D, E, [F, []]], [], G]
    func toString(_ delim:String = ", ") -> String {
        var s = "["
        let n = self.count
        for i in 0..<n {
            let x = self[i]
            var str = ""
            if let x = x as? Array {
                str = x.toString()
            } else {
                str = String(describing: x)
            }
            if (i == 0) {
                s += str
            } else {
                s += delim + str
            }
        }
        s += "]"
        return s
    }

}


// MARK: Extensions for type casting
// In Java,
// https://docs.oracle.com/javase/specs/jls/se7/html/jls-5.html
// Widening Casting (automatically) - converting a smaller type to a larger type size
// byte -> short -> char -> int -> long -> float -> double


// Narrowing Casting (manually) - converting a larger type to a smaller size type
// double -> float -> long -> int -> char -> short -> byte
// Int64 (in Swift) = long long (in C)


extension Int {
    public func hex() -> String { return String.init(format:"0x%8x", self); }
    @discardableResult
    public static postfix func ++ (x: inout Int) -> Int { x = x + 1; return x; }
    @discardableResult
    public static postfix func -- (x: inout Int) -> Int { x = x - 1; return x; }
}

// Type conversion
extension CGFloat {
    public func lf() -> Double { return Double(self); }
}
extension Float {
    public func cgFloat() -> CGFloat { return CGFloat(self); }
}
extension Double {
    public func cgFloat() -> CGFloat { return CGFloat(self); }
}

// Rounding
extension Float {
    public func roundInt() -> Int { return Int(self.rounded()); }
    public func ceilInt()  -> Int { return Int((self + 0.5).rounded()); }
    public func floorInt() -> Int { return Int((self - 0.5).rounded()); }
}
extension Double {
    public func roundInt() -> Int { return Int(self.rounded()); }
    public func ceilInt()  -> Int { return Int((self + 0.5).rounded()); }
    public func floorInt() -> Int { return Int((self - 0.5).rounded()); }
}
extension CGFloat {
    public func roundInt() -> Int { return Int(self.rounded()); }
    public func ceilInt()  -> Int { return Int((self + 0.5).rounded()); }
    public func floorInt() -> Int { return Int((self - 0.5).rounded()); }
}

// + - * / to Double
extension Double {
    // For Int
    public static func + (lhs:    Int, rhs: Double) -> Double { return Double(lhs) + rhs; }
    public static func + (lhs: Double, rhs:    Int) -> Double { return lhs + Double(rhs); }
    public static func - (lhs:    Int, rhs: Double) -> Double { return Double(lhs) - rhs; }
    public static func - (lhs: Double, rhs:    Int) -> Double { return lhs - Double(rhs); }
    public static func * (lhs:    Int, rhs: Double) -> Double { return Double(lhs) * rhs; }
    public static func * (lhs: Double, rhs:    Int) -> Double { return lhs * Double(rhs); }
    public static func / (lhs:    Int, rhs: Double) -> Double { return Double(lhs) / rhs; }
    public static func / (lhs: Double, rhs:    Int) -> Double { return lhs / Double(rhs); }

    // For Int64
    public static func + (lhs:  Int64, rhs: Double) -> Double { return Double(lhs) + rhs; }
    public static func + (lhs: Double, rhs:  Int64) -> Double { return lhs + Double(rhs); }
    public static func - (lhs:  Int64, rhs: Double) -> Double { return Double(lhs) - rhs; }
    public static func - (lhs: Double, rhs:  Int64) -> Double { return lhs - Double(rhs); }
    public static func * (lhs:  Int64, rhs: Double) -> Double { return Double(lhs) * rhs; }
    public static func * (lhs: Double, rhs:  Int64) -> Double { return lhs * Double(rhs); }
    public static func / (lhs:  Int64, rhs: Double) -> Double { return Double(lhs) / rhs; }
    public static func / (lhs: Double, rhs:  Int64) -> Double { return lhs / Double(rhs); }

    // For Float
    public static func + (lhs:  Float, rhs: Double) -> Double { return Double(lhs) + rhs; }
    public static func + (lhs: Double, rhs:  Float) -> Double { return lhs + Double(rhs); }
    public static func - (lhs:  Float, rhs: Double) -> Double { return Double(lhs) - rhs; }
    public static func - (lhs: Double, rhs:  Float) -> Double { return lhs - Double(rhs); }
    public static func * (lhs:  Float, rhs: Double) -> Double { return Double(lhs) * rhs; }
    public static func * (lhs: Double, rhs:  Float) -> Double { return lhs * Double(rhs); }
    public static func / (lhs:  Float, rhs: Double) -> Double { return Double(lhs) / rhs; }
    public static func / (lhs: Double, rhs:  Float) -> Double { return lhs / Double(rhs); }

}
