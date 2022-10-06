//
// Created by Eric Chen on 2021/2/3.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

// https://en.wikipedia.org/wiki/List_of_HTTP_header_fields
public enum HTTPRequestFields : String {
    case Accept_Encoding = "Accept-Encoding"
    case Content_Type = "Content-Type"
    case If_None_Match = "If-None-Match"
    case User_Agent = "User-Agent"

    var name:String { return self.rawValue }
}

// https://en.wikipedia.org/wiki/HTTP_compression
public enum HTTPFieldValues : String {
    case gzipDeflate = "gzip, deflate"

    var name:String { return self.rawValue }
}

// https://en.wikipedia.org/wiki/Media_type
public enum MIMEType : String {
    case application_Json = "application/json"
    case application_UrlEncoded = "application/x-www-form-urlencoded"

    case image_WebP = "image/webp"
    case image_Png = "image/png"
    case image_jpeg = "image/jpeg"

    case text_plain = "text/plain"
    case text_xml = "text/xml"

    var name:String { return self.rawValue }
}