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

extension UInt {
    public func hex() -> String { return String(format: "0x%x", self); }
}
extension UInt32 {
    public func hex() -> String { return String(format: "0x%x", self); }
}
extension Int32 {
    public func hex() -> String { return String(format: "0x%x", self); }
}

extension Int {
    public func hex() -> String { return String(format:"0x%x", self); }
    @discardableResult
    public static postfix func ++ (x: inout Int) -> Int { x = x + 1; return x; }
    @discardableResult
    public static postfix func -- (x: inout Int) -> Int { x = x - 1; return x; }
}


// Rounding
//extension FloatingPoint {
extension BinaryFloatingPoint {
//extension Float {
    public func roundedInt() -> Int { return Int(self.rounded()); }
}
//extension Double {
//    public func roundedInt() -> Int { return Int(self.rounded()); }
//}

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
