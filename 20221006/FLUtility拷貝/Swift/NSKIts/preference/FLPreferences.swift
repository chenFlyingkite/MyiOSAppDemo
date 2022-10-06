//
// Created by Eric Chen on 2021/2/5.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class FLPreferences {
    class func printAll(_ pref:UserDefaults = UserDefaults.standard) {
        let m = pref.dictionaryRepresentation()
        wqe("\(m.count) items in \(m)")
        var i = 0
        for k in m.keys {
            print("#\(i) : \(k) = \(m[k])")
            i++
        }
    }
}
