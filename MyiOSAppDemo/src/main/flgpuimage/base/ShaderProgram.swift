//
// Created by Eric Chen on 2021/3/21.
//

import Foundation

#if os(iOS)
import OpenGLES
#elseif os(macOS)
import OpenGL.GL3
#endif

public class ShaderProgram : NSObject {
    private(set) var programID : GLuint = 0
    private(set) var vertexID : ShaderCode?
    private(set) var fragmentID : ShaderCode?
    private(set) var delete : GLint = GL_FALSE
    private(set) var isLinked : GLint = GL_FALSE
    private(set) var linkLog = ""

    public class func from(_ vertexCode:String, _ fragmentCode:String) -> ShaderProgram {
        print("vertex = \n\(vertexCode)")
        print("fragment = \n\(fragmentCode)")

        let vid = ShaderCode.compile(vertexCode, .vertex)
        let fid = ShaderCode.compile(fragmentCode, .fragment)
        return Self.from(vid, fid)
    }

    public class func from(_ vertex:ShaderCode, _ fragment:ShaderCode) -> ShaderProgram {
        let ans = ShaderProgram()

        let pgid = glCreateProgram()
        ans.programID = pgid
        ans.vertexID = vertex
        ans.fragmentID = fragment

        glAttachShader(pgid, vertex.shaderID)
        glAttachShader(pgid, fragment.shaderID)

        glLinkProgram(pgid)

        // https://www.khronos.org/registry/OpenGL-Refpages/es3/html/glLinkProgram.xhtml
        // Link Program

        // https://www.khronos.org/registry/OpenGL-Refpages/es3/html/glGetProgramiv.xhtml
        var del:GLint = 0
        glGetProgramiv(pgid, GLenum(GL_DELETE_STATUS), &del)
        ans.delete = del

        var linked:GLint = 0
        glGetProgramiv(pgid, GLenum(GL_LINK_STATUS), &linked)
        ans.isLinked = linked

        var logLen:GLint = 0
        glGetProgramiv(pgid, GLenum(GL_INFO_LOG_LENGTH), &logLen)
        if (logLen > 0) {
            var logCChar = [CChar](repeating: 0, count: Int(logLen))
            glGetProgramInfoLog(pgid, logLen, &logLen, &logCChar)
            let logs = String(cString: logCChar)
            ans.linkLog = logs
        } else {
            ans.linkLog = ""
        }

        print("program = \(ans)")
        return ans
    }

    public func use() {
        glUseProgram(programID)
    }

    public override var description: String {
        let pid = programID
        let vid = vertexID?.shaderID ?? 0
        let fid = fragmentID?.shaderID ?? 0
        return "#\(pid), v = #\(vid), f = #\(fid), link = \(glOX(isLinked)), del = \(glOX(delete)) log: \n\(linkLog)"
    }

    deinit {
        print("deinit")
        if let v = self.vertexID {
            glDeleteShader(v.shaderID)
        }
        if let f = self.fragmentID {
            glDeleteShader(f.shaderID)
        }
        glDeleteProgram(programID)
    }
}
