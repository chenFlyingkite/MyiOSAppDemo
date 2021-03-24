//
// Created by Eric Chen on 2021/3/21.
//


import OpenGLES
import Foundation

enum ShaderType : String {
//enum ShaderType : UInt32 {
//enum ShaderType : GLenum {
//    case vertex = GLenum(GL_VERTEX_SHADER)
//    case fragment = GLenum(GL_FRAGMENT_SHADER)
    case vertex// = GL_VERTEX_SHADER
    case fragment// = GL_FRAGMENT_SHADER
//    case vertex(GL_VERTEX_SHADER)
//    case fragment(GL_FRAGMENT_SHADER)
    func glID() -> UInt32 {
        switch (self) {
        case .vertex: return GLenum(GL_VERTEX_SHADER)
        case .fragment: return GLenum(GL_FRAGMENT_SHADER)
        }
    }
}

public class ShaderProgram {
    let program : GLuint
    // TODO
    // At some point, the Swift compiler will be able to deal with the early throw and we can convert these to lets
    var vertex:GLuint!
    var fragment:GLuint!

    public init(vertexCode:String, fragmentCode:String) {
        program = glCreateProgram()
        // EAGL_MINOR_VERSION = 0, EAGL_MAJOR_VERSION = 1
        print("glCreateProgram at = \(program)")
        print("vertex = \n\(vertexCode)")
        print("fragment = \n\(fragmentCode)")
        self.vertex = compileShader(vertexCode, type: .vertex)
        checkGLError()
        self.fragment = compileShader(fragmentCode, type: .fragment)
        checkGLError()

//        self.vertexShader = try compileShader(vertexShader, type:.vertex)
//        self.fragmentShader = try compileShader(fragmentShader, type:.fragment)
//
//        glAttachShader(program, self.vertexShader)
//        glAttachShader(program, self.fragmentShader)
//
//        try link()
    }

    deinit {
        print("deinit")
        glDeleteShader(vertex)
        glDeleteShader(fragment)
        glDeleteProgram(program)
    }

    func compileShader(_ codes:String, type:ShaderType) -> GLuint {
        let shader:GLuint = glCreateShader(type.glID())
        let id = type.glID();
        print("shader = \(shader), glCreateShader(\(id.hex()) = \(type))")
        if (shader == 0) {
            print("glCreateShader failed")
        }

        FLGLs.toGLChars(codes, run: { glString in
            var gls:UnsafePointer<GLchar>? = glString
            glShaderSource(shader, 1, &gls, nil)
            glCompileShader(shader)
        })

        var compileOK = GL_FALSE
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &compileOK)
        //print("glGetShaderiv(\(shader), \(GL_COMPILE_STATUS.hex()), &\(compileOK))")
        var compileLogLength: GLint = 0
        glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &compileLogLength)
        //print("glGetShaderiv(\(shader), \(GL_INFO_LOG_LENGTH.hex()), &\(compileLogLength))")
        if (compileLogLength > 0) {
            var compileLog = [CChar](repeating: 0, count: Int(compileLogLength))
            glGetShaderInfoLog(shader, compileLogLength, &compileLogLength, &compileLog)
            print("Compile \(type) log: \n\(String(cString: compileLog))")
            // let compileLogString = String(bytes:compileLog.map{UInt8($0)}, encoding:NSASCIIStringEncoding)
        } else {
            print("Compile \(type) finished")
        }
        return shader
    }
}
