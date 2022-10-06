//
// Created by Eric Chen on 2021/2/14.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class FLCollections {
}

extension Dictionary {
    func keyArray() -> Array<Key> {
        var ks:Array<Key> = []
        let m = self;
        for k in m.keys {
            ks.append(k)
        }
        return ks
    }
}

extension Set {
    func toArray() -> Array<Element> {
        var vs : Array<Element> = []
        let m = self
        for v in m {
            vs.append(v)
        }
        return vs
    }
}
