//
// Created by Eric Chen on 2021/3/25.
//

import Foundation

public class FLStrings {

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
}
