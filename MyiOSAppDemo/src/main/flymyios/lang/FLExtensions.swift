//
// Created by Eric Chen on 2021/3/25.
//

import Foundation
import OpenGLES

//class FLExtensions {
//}

extension Date {
    public func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

extension DateFormatter {
    public class func of(_ f:String) -> DateFormatter {
        let x = DateFormatter()
        x.dateFormat = f
        return x
    }
}