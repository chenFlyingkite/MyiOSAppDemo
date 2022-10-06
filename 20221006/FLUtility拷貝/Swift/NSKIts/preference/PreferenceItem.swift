//
// Created by Eric Chen on 2021/2/5.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

//protocol PreferenceData : NSObjectProtocol {
//    associatedtype T
//    func get() -> T?
//    func set(_ v:T?) -> Void
//}

//
//class StandardImpl<M> : NSObject {
//    fileprivate(set) var key = ""
//    fileprivate(set) var def : M?
//    init(_ k:String, _ v:M?) { key = k; def = v; }
//    func impl() -> UserDefaults { return UserDefaults.standard }
//}

class IntPreference : NSObject {
    func get() -> Int  { return impl().integer(forKey: key) }
    func set(_ v: Int) { impl().set(v, forKey: key) }
    override var description: String { return key + " -> " + String(get()) }

    // code same
    private(set) var key = ""
    init(_ k:String) { key = k;}
    func impl() -> UserDefaults { return UserDefaults.standard }
}

class BoolPreference : NSObject {
    func get() -> Bool  { return impl().bool(forKey: key) }
    func set(_ v: Bool) { impl().set(v, forKey: key) }
    override var description: String { return key + " -> " + String(get()) }

    // code same
    private(set) var key = ""
    init(_ k:String) { key = k;}
    func impl() -> UserDefaults { return UserDefaults.standard }
}

class StringPreference : NSObject {
    func get() -> String?  { return impl().string(forKey: key) }
    func set(_ v: String?) { impl().set(v, forKey: key) }
    override var description: String { return key + " -> " + (get() ?? "") }

    // code same
    private(set) var key = ""
    init(_ k:String) { key = k;}
    func impl() -> UserDefaults { return UserDefaults.standard }
}
/*
class PreferenceItem : NSObject{
    class OfInt : StandardImpl<Int>, PreferenceData {
        init(_ k:String) { super.init(k, 0) }
        func get() -> Int?  { return UserDefaults.standard.integer(forKey: key) }
        func set(_ v: Int?) { UserDefaults.standard.set(v, forKey: key) }

        override 
        var description: String { return key + " -> " + String(get() ?? def!) }
    }

    class OfString : StandardImpl<String>, PreferenceData {
        init(_ k:String) { super.init(k, "") }
        func get() -> String?  { return UserDefaults.standard.string(forKey: key) }
        func set(_ v: String?) { UserDefaults.standard.set(v, forKey: key) }

        override 
        var description: String { return key + " -> " + String(get() ?? def!) }
    }

    class OfBool : StandardImpl<Bool>, PreferenceData {
        init(_ k:String) { super.init(k, false) }
        func get() -> Bool?  { return UserDefaults.standard.bool(forKey: key) }
        func set(_ v: Bool?) { UserDefaults.standard.set(v, forKey: key) }

        override
        var description: String { return key + " -> " + String(get() ?? def!) }
    }

}
*/
