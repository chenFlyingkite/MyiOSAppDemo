//
// Created by Eric Chen on 2021/1/22.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class MirrorLR : GPUImageFilter {
    // A = flip vertex, same color, this is from vertex & shader reference
    // B = same vertex, flip color, this is from vertex & shader reference
    // screen (x, y) = (0, 0) ~ (1, 1)
    private let vertex = [
        "attribute vec4 position;",
        "attribute vec4 inputTextureCoordinate;",
        "",
        "varying highp vec2 textureCoordinate;",
        "",
        "void main() {",
        "    gl_Position = position;",
        "    highp vec2 a = inputTextureCoordinate.xy;",
        "    highp vec2 s = vec2(1.0 - a.x, a.y);", // s = flip
        //"    textureCoordinate = a;", // B
        "    textureCoordinate = s;", // A
        //"    textureCoordinate = inputTextureCoordinate.xy;", // No
        "}",
    ];

    private let fragment = [
        "varying highp vec2 textureCoordinate;",
        "",
        "uniform sampler2D inputImageTexture;",
        "",
        "void main() {",
        "    highp vec2 a = textureCoordinate;",
        "    highp vec2 s = vec2(1.0 - a.x, a.y);", // s = flip
        "    gl_FragColor = texture2D(inputImageTexture, a);", // A
        //"    gl_FragColor = texture2D(inputImageTexture, s);", // B
        //"    gl_FragColor = texture2D(inputImageTexture, textureCoordinate);", // No
        "}",
    ];

    public override
    init() {
        super.init(vertexShaderFrom: A.sb(vertex), fragmentShaderFrom: A.sb(fragment))
    }
}

fileprivate class A {
    class func sb(_ a: [String], delim d: String = "\n") -> String {
        //let delim = "\n"
        var ans = ""
        for i in 0..<a.count {
            ans += a[i] + d
        }
        return ans
    }
}
