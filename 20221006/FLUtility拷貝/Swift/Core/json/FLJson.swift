//
// Created by Eric Chen on 2021/3/29.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

// Perform easy APIs like Gson
class FLJson : NSObject {
    private let enc = JSONEncoder()
    private let dec = JSONDecoder()
    //open func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
    //func fromJson<T>(path:String, _ classOfT:T.Type) throws -> T? where T : Decodable {
    func fromJson<T : Decodable>(path:String, _ classOfT:T.Type) -> T? {
        // this code loads file as string with no missing?
        let x = NSData(contentsOfFile: path)
        if let x = x as? Data {
            return self.fromJson(data: x, classOfT)
        }
        return nil
    }

    func fromJson<T : Decodable>(string s:String, _ classOfT:T.Type) -> T? {
        var d = toData(s)
        return fromJson(data: d, classOfT)
    }

    func fromJson<T : Decodable>(data d:Data?, _ classOfT:T.Type) -> T? {
        if let d = d {
            do {
                return try dec.decode(classOfT, from: d) as? T
            } catch {
                wqe("Fail to decode as \(classOfT) of \(toString(d))")
            }
        }
        return nil
    }

    func toJson<T : Encodable>(_ x:T) -> String? {
        var s:String? = ""
        do {
            var d:Data = try enc.encode(x)
            s = String(data: d, encoding: .utf8)
        } catch {
            wqe("Fail to encode \(x)")
        }
        return s
    }

    func toString(_ data:Data?) -> String {
        if let d = data {
            return String(data: d, encoding: .utf8) ?? ""
        } else {
            return ""
        }
    }

    func toData(_ s:String) -> Data? {
        return s.data(using: .utf8)
    }

}
