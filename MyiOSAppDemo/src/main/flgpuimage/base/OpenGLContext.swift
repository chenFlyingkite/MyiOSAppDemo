//
// Created by Eric Chen on 2021/3/28.
//

import Foundation

#if os(iOS)
import OpenGLES
#elseif os(macOS)
//import OpenGL.GL3
//import OpenGL
//import AppKit.NSOpenGL
import AppKit
#endif

public class OpenGLContext : NSObject {
    public override init() {
        super.init()
        Self.usingOpenGL()
        Self.get()
    }

    private class func usingOpenGL() {
        #if os(iOS)
        let context = EAGLContext(api: .openGLES3)
        if let ctx = context {
            EAGLContext.setCurrent(ctx)
        }
        #elseif os(macOS)

        // OpenGLContext-OpenGL.swift
        // https://en.wikipedia.org/wiki/Multiple_buffering
        let pixelFormatAttributes: [NSOpenGLPixelFormatAttribute] = [
            //NSOpenGLPixelFormatAttribute(NSOpenGLPFADoubleBuffer),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFATripleBuffer),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAAccelerated), 0,
            0
        ]

        guard let pixelFormat = NSOpenGLPixelFormat(attributes: pixelFormatAttributes) else {
            fatalError("No appropriate pixel format found when creating OpenGL context.")
        }
        // TODO: Take into account the sharegroup
        guard let generatedContext = NSOpenGLContext(format: pixelFormat, share: nil) else {
            fatalError("Unable to create an OpenGL context. The GPUImage framework requires OpenGL support to work.")
        }
        generatedContext.makeCurrentContext()
        let gls = NSOpenGLContext.current
        print("openGL now = \(gls), \(String(describing: gls))")

        #endif
    }

    private class func get() {
        // In iPhone 12 (MGJ53TA/A)
//        #0 : GL_VENDOR => Apple Inc.
//        #1 : GL_RENDERER => Apple A14 GPU
//        #2 : GL_VERSION => OpenGL ES 3.0 Metal - 68.8
//        #3 : GL_SHADING_LANGUAGE_VERSION => OpenGL ES GLSL ES 3.00
//        #4 : GL_EXTENSIONS => GL_OES_standard_derivatives ... more

    // In Mac
//        #0 : GL_VENDOR => Intel Inc.
//        #1 : GL_RENDERER => Intel(R) UHD Graphics 630
//        #2 : GL_VERSION => 2.1 INTEL-16.1.11
//        #3 : GL_SHADING_LANGUAGE_VERSION => 1.20
//        #4 : GL_EXTENSIONS => GL_ARB_color_buffer_float ... more
        let fs = [GL_VENDOR, GL_RENDERER, GL_VERSION, GL_SHADING_LANGUAGE_VERSION, GL_EXTENSIONS]
        let ns = ["GL_VENDOR", "GL_RENDERER", "GL_VERSION", "GL_SHADING_LANGUAGE_VERSION", "GL_EXTENSIONS"]
        let n = fs.count
        for i in 0..<n {
            let fi = fs[i]
            let ni = ns[i]
            let x = glGetString(GLenum(fi))

            var s = ""
            if let x = x {
                s = String(cString: x)
            } else {
                s = "\(x)"
            }
            print("#\(i) : \(ni) => \(s)")
        }

    }

}
