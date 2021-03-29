//
// Created by Eric Chen on 2021/3/25.
//

import Foundation

public class FLStrings {
    public static let fmt_yyyyMMddHHmmssSSS = DateFormatter.of("yyyy-MM-dd HH:mm:ss.SSS")
    public static let fmt_MMddHHmmssSSS = DateFormatter.of("MM-dd HH:mm:ss.SSS")

    // returns Regex = (s){n}
    // Result is same as String.init(repeating: s, count: n)
    // but this method runs faster
    public class func repeats(_ s:String, _ n:Int) -> String {
        //
        var ans = ""
        var now = s
        var x = n
        while (x > 0) {
            if ((x & 0x1) == 1) {
                ans += now
            }
            now += now
            x >>= 1
        }
        return ans
    }


    // Returns now like "07-03 11:22:33.444"
    public class func now() -> String {
        let d = Date()
        return fmt_MMddHHmmssSSS.string(from: d)
    }

    // Returns formatted date of now
    public class func now(_ format:String) -> String {
        let d = Date()
        let f = DateFormatter.of(format)
        return f.string(from: d)
    }

    public class func join(_ a: [String], delim d: String = "") -> String {
        var ans = ""
        for i in 0..<a.count {
            ans += a[i] + d
        }
        return ans
    }

    public class func join(_ a:[AnyObject], pre:String = "", delim d:String = "", post:String = "") -> String {
        let n = a.count
        var s = pre
        for i in 0..<n {
            if (i > 0) {
                s += d
            }
            // is it redundant?
            if let ai = a[i] as? String {
                s += ai
            } else {
                s += String(describing: a[i])
            }
        }
        s += post
        return s
    }

    /**
     LC#165
     Compares version codes with delimiter
     Version code is like int([.]int)* with num = integer numbers
     let v1, v2 are two strings split by dot, then
     return | v1        | v2
      -1    | "7.2.5.3" | "7.2.6"
       0    | "1.0.0"   | "1"
       0    | "1.01"    | "1.001"
      -1    | "0.1"     | "1.1"
       1    | "1.0.1"   | "1.0"
     */
    public class func compareVersion(v1:String, v2:String, delim:String = ".") -> Int {
        let v1s = v1.components(separatedBy: delim)
        let v2s = v2.components(separatedBy: delim)
        let n1 = v1s.count
        let n2 = v2s.count
        let mx = max(n1, n2)
        for i in 0..<mx {
            var x = 0, y = 0
            if (i < n1) {
                x = (v1s[i] as NSString).integerValue
            }
            if (i < n2) {
                y = (v2s[i] as NSString).integerValue
            }
            if (x < y) {
                return -1
            } else if (x > y) {
                return 1
            }
        }
        return 0
    }

//        + (NSString*) join:(NSDictionary*)map pre:(NSString *)pre delimKV:(NSString *)d1 delimEntry:(NSString*)d2 post:(NSString *)post {
//    NSMutableString *s = [NSMutableString new];
//    // Pre
//    [s setString:pre];
//    // array
//    NSArray *keys = map.allKeys;
//    for (int i = 0; i < keys.count; i++) {
//        NSObject *k = keys[i];
//        NSObject *v = map[k];
//        if (i != 0) {
//            [s appendString:d2];
//        }
//        [s appendFormat:@"%@%@%@", k, d1, v];
//    }
//    // Post
//    [s appendString:post];
//    return s;
//}
//
//        + (NSString*) joinAsUrlParameter:(NSDictionary*)map {
//    return [FLStringKit join:map pre:@"" delimKV:@"=" delimEntry:@"&" post:@""];
//}

}
