//
// Created by Eric Chen on 2021/2/14.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

public class FLCollections {
}

public typealias HashMap = Dictionary
extension Dictionary {
    public func keySet() -> Set<Key> {
        var ks:Set<Key> = []
        let m = self
        for k in m.keys {
            ks.insert(k)
        }
        return ks
    }

    public func keyArray() -> Array<Key> {
        var ks:Array<Key> = []
        let m = self
        for k in m.keys {
            ks.append(k)
        }
        return ks
    }
}

public typealias HashSet = Set
extension Set {
    public func toArray() -> Array<Element> {
        var a:Array<Element> = []
        let s = self
        for x in s {
            a.append(x)
        }
        return a
    }
}
