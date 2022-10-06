//
// Created by Eric Chen on 2021/2/3.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

public class FLURLSessions : NSObject {
    var log = true;

    public func resumeURLTask(_ given: FLURLSessionsParam) -> URLSessionTask? {
        let map = given.params
        let link = given.link
        let body = given.body
        let headers = given.headerFields
        let url = FLURLSessions.buildURL(link, map)
        if let url = url {
            if (log) {
                wqe("resume \n\(url)")
            }
            let session = URLSession.init(configuration: .default)
            var req = URLRequest.init(url: url, cachePolicy: .reloadIgnoringCacheData)
            req.httpMethod = given.httpMethod
            for k in headers.keys {
                if let v = headers[k] {
                    req.setValue(v, forHTTPHeaderField: k.rawValue)
                }
            }
            given.onRequestInit(req)

            if (body.count > 0) {
                req.httpBody = body.data(using: .utf8)
            }

            let task:URLSessionTask = session.dataTask(with: req, completionHandler: {[weak self] (data: Data?, response: URLResponse?, error: Error?) -> () in
                guard let zelf = self else {
                    wqe("missing self")
                    return
                }
                given.endedData = data
                given.endedError = error
                if (zelf.log) {
                    print("data = \(data)")
                    print("response = \(response)")
                    print("error = \(error)")
                    print("now = \(FLStringKit.now()!)")
                    var js = FLJson().toString(data)
                    wqe("json = \(js)")
                }
                let http = response as? HTTPURLResponse
                given.endedResponse = http
                given.onDataComplete(data, http, error)
            })
            given.endedData = nil
            given.endedResponse = nil
            given.endedError = nil
            given.willResume()
            task.resume()
            given.didResume()
            return task
        } else {
            return nil
        }
    }

    private class func buildURL(_ link:String, _ param:[String:String?]) -> URL? {
        var c = URLComponents.init(string: link)
        var q:[URLQueryItem] = []
        var i = 0
        for k in param.keys {
            if let v = param[k] {
                let p = URLQueryItem.init(name:k, value:v)
                q.append(p)
                i++
            }
        }

        c?.queryItems = q
        return c?.url ?? nil
    }
}
