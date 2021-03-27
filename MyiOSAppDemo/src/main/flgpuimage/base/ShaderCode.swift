//
// Created by Eric Chen on 2021/3/27.
//

import Foundation

#if os(iOS)
import OpenGLES
#elseif os(macOS)
import OpenGL.GL3
#endif

public enum ShaderType : String {
    case vertex
    case fragment
    func glID() -> UInt32 {
        switch (self) {
        case .vertex: return GLenum(GL_VERTEX_SHADER)
        case .fragment: return GLenum(GL_FRAGMENT_SHADER)
        }
    }
}

public class ShaderCode : NSObject {
    private(set) var shaderID: GLuint = 0
    private(set) var type = ShaderType.vertex
    private(set) var codes = ""
    private(set) var message = ""
    private(set) var compileOK = GL_FALSE
    private(set) var compileLog = ""

    public class func compile(_ codes: String, _ type: ShaderType) -> ShaderCode {
        let ans = ShaderCode()
        ans.type = type
        ans.codes = codes
        // create shader
        let id = type.glID()
        let shader: GLuint = glCreateShader(id)
        ans.shaderID = shader
        if (shader == 0) {
            ans.message += "glCreateShader(\(id)) returns 0 => failed\n"
        }

        // Convert codes to GLchar for compile
        let codeCChars = FLGLs.toGLChars(codes)
        var gls = UnsafePointer<GLchar>(codeCChars)
        glShaderSource(shader, 1, &gls, nil)
        glCompileShader(shader)

        // Check compile success or fail, and compile logs
        var isOK = GL_FALSE
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &isOK)
        ans.compileOK = isOK

        var logLen: GLint = 0
        glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logLen)
        if (logLen > 0) {
            var logCStr = [CChar](repeating: 0, count: Int(logLen))
            glGetShaderInfoLog(shader, logLen, &logLen, &logCStr)
            let logs = String(cString: logCStr)
            ans.compileLog = logs
        } else {
            ans.compileLog = ""
        }
        print("Compile \(type) finished")
        print("shader = \(ans)")
        return ans
    }

    public override var description: String {
        return "\(type) #\(shaderID) , OK = \(glOX(compileOK)), \(message), length = \(codes.count), \(compileLog) "
    }
}