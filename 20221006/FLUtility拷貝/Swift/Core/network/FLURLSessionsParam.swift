//
// Created by Eric Chen on 2021/2/3.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

public class FLURLSessionsParam : NSObject {
    var link = ""
    var body = ""
    var params :[String:String] = [:]
    var httpMethod = "GET"
    var headerFields : [HTTPRequestFields:String] = [:]
    var onRequestInit : (_ req:URLRequest) -> () = { request in  }
    var onDataComplete: (_ data: Data?, _ response: HTTPURLResponse?, _ error: Error?) -> ()
            = { _, _, _ in}
    var willResume: () -> () = {}
    var didResume: () -> () = {}
    //-- output
    var endedData: Data? = nil
    var endedResponse: HTTPURLResponse? = nil
    var endedError: Error? = nil

    typealias OnCompleteLister = (_ data: Data?, _ response: HTTPURLResponse?, _ error: Error?) -> ()

    public override init() {
        super.init()
        headerFields[HTTPRequestFields.Accept_Encoding] = HTTPFieldValues.gzipDeflate.name
    }

    public func getResponseHeader(_ key:String) -> Any? {
        if let resp = endedResponse {
            return resp.allHeaderFields[key]
        }
        return nil
    }

    public override var description: String {
        return link + ", " + FLStringKit.join(asUrlParameter: params)
                + ", " + httpMethod + ", " + String(describing: onRequestInit) + ", " + String(describing: onDataComplete)
    }
}

