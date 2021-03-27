//
// Created by Eric Chen on 2021/3/22.
//

import Foundation

#if os(iOS)
import OpenGLES
#elseif os(macOS)
import OpenGL.GL3
#endif

public class FLGLs {
    public class func toGLChars(_ s:String) -> [CChar]? {
        return s.cString(using: String.Encoding.utf8)
    }

    public class func toString(_ s:UnsafePointer<GLchar>) -> String {
        //public typealias GLchar = Int8
        return String(cString: s)
    }

    public class func join(_ a: [String], delim d: String = "\n") -> String {
        var ans = ""
        for i in 0..<a.count {
            ans += a[i] + d
        }
        return ans
    }

}

// https://www.khronos.org/registry/OpenGL-Refpages/es3.0/html/glGetError.xhtml
public func checkGLError() {
    let e:GLenum = glGetError()
    var msg = ""
    if (e == GL_NO_ERROR) {
        msg += "No Error"
//        No error has been recorded. The value of this symbolic constant is guaranteed to be 0.
    } else if (e == GL_INVALID_ENUM) {
        msg += "Invalid Enum"
//        An unacceptable value is specified for an enumerated argument. The offending command is ignored and has no other side effect than to set the error flag.
    } else if (e == GL_INVALID_VALUE) {
        msg += "Invalid Value"
//        A numeric argument is out of range. The offending command is ignored and has no other side effect than to set the error flag.
    } else if (e == GL_INVALID_OPERATION) {
        msg += "Invalid Operation"
//        The specified operation is not allowed in the current state. The offending command is ignored and has no other side effect than to set the error flag.
    } else if (e == GL_INVALID_FRAMEBUFFER_OPERATION) {
        msg += "Invalid FrameBuffer Operation"
//        The framebuffer object is not complete. The offending command is ignored and has no other side effect than to set the error flag.
    } else if (e == GL_OUT_OF_MEMORY) {
        msg += "Out Of Memory"
//        There is not enough memory left to execute the command. The state of the GL is undefined, except for the state of the error flags, after this error is recorded.
    } else {
    }

    print("GL : \(msg)")
}

public func glOX(_ b:Int32) -> String {
    return b == GL_TRUE ? "o" : "x"
}

