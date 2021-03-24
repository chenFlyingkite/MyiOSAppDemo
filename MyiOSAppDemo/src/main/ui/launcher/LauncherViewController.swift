//
//  LauncherViewController.swift
//  MyiOSAppDemo
//
//  Created by Eric Chen on 2021/3/6.
//
//

import UIKit


// https://support.apple.com/zh-tw/HT204460
// https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_objective-c_into_swift
// https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_swift_into_objective-c


class LauncherViewController : BaseViewController {
    //@objcMembers // @objcMembers may only be used on 'class' declarations
    @objc
    static let vc = 0

    @objc
    static func gvc() -> Int {
        return 0
    }

    let content = UIView()
    let lbl1 = UILabel()
    let lbl2 = UILabel()
    let part = UIView()

    private var testPart = true

    // MARK: Life cycle
    override func viewDidLoad() {
        Self.usingOpenGL()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("viewDidLoad")
        let x = ASD.init()
        print("ASD.init() OK")
//        tr = 0.393R + 0.769G + 0.189B
//        tg = 0.349R + 0.686G + 0.168B
//        tb = 0.272R + 0.534G + 0.131B
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        test()
        testSpeed()
    }

    private func testSpeed() {
        print("----")
        // 3.19982740435325 = macOS / my on max=500, i = 10~10^4 on " "
        // 3.21225551594566
//        [123] : End by xn(s, i * 10)
//        [175] : End by String.init(repeating: s, count: i * 10)
//        [842] : End by xn(s, i * 100)
//        [1753] : End by String.init(repeating: s, count: i * 100)
//        [8308] : End by xn(s, i * 1000)
//        [17477] : End by String.init(repeating: s, count: i * 1000)
//        [83393] : End by xn(s, i * 10000)
//        [191587] : End by String.init(repeating: s, count: i * 10000)
        let max = 1000
        let s = "+1"
        var mul = 1
        let clk = TicTac()
        for k in 1..<5 {
            mul *= 10

            clk.tic()
            for i in 1..<max {
                let x = clk.xn(s, i * mul)
                //print("#\(i) \(x.count)")
                //print("#\(i) = |\(x)|")
                if (x.count != i * mul * s.count) {
                    print("X_X Fail 2 on \(i)")
                }
            }
            clk.tac("End by xn(s, i * \(mul))")

            clk.tic()
            for i in 1..<max {
                let x = String.init(repeating: s, count: i * mul)
                //print("#\(i) \(x.count)")
                //print("#\(i) = |\(x)|")
                if (x.count != i * mul * s.count) {
                    print("X_X Fail 1 on \(i)")
                }
            }
            clk.tac("End by String.init(repeating: s, count: i * \(mul))")

        }
        print("----")
    }

    private class func usingOpenGL() {
        let context = EAGLContext(api: .openGLES3)
        if let ctx = context {
            EAGLContext.setCurrent(ctx)
        }
    }

    private func test() {
        print("test")
//        if let shareGroup = imageProcessingShareGroup {
//            generatedContext = EAGLContext(api:.openGLES2, sharegroup:shareGroup)
//        } else {
//            generatedContext = EAGLContext(api:.openGLES2)
//        }


        let sh = ShaderProgram.init(vertexCode: Self.vertex(), fragmentCode: "asd\n\nfff")
        checkGLError()
    }

    // MARK: Shader Vertex
    class func vertex() -> String {
        var v = [
            "attribute vec4 position;",
            "attribute vec4 inputTextureCoordinate;",
            "attribute vec4 inputTextureCoordinate2;",

            "varying vec2 textureCoordinate;",
            "varying vec2 textureCoordinate2;",
            // Main function
            "void main() {",
            "  gl_Position = position;",
            "  textureCoordinate = inputTextureCoordinate.xy;",
            "  textureCoordinate2 = inputTextureCoordinate2.xy;",
            "}",
        ]
        return FLGLs.join(v)
    }

    // MARK: Shader Fragment
    class func fragment() -> String {
        var f = [
            "precision highp float;",
            "varying highp vec2 textureCoordinate;",
            "varying highp vec2 textureCoordinate2;",

            "uniform sampler2D inputImageTexture;",
            "uniform sampler2D inputImageTexture2;",
            // Parameters
            "void main() {",
            "  vec4 source = texture2D(inputImageTexture, textureCoordinate);",
            "  vec4 target = texture2D(inputImageTexture2, textureCoordinate2);",
            "  vec4 d = source - target;",
            //--
            "  vec4 diff = vec4(abs(d.r), abs(d.g), abs(d.b), abs(d.a));",
            //"  vec4 diff = d;",
            //"  float s = 10.0;",
            "  float s = 1.0;",
            //--
            "  gl_FragColor = diff * s;",
            "}",
        ]
        return FLGLs.join(f)
    }

    var lbls:[UILabel] = []
    override func setupRes() {
        lbl1.backgroundColor = UIColor.red
        lbl1.text = "Label 1"
        lbl2.backgroundColor = UIColor.cyan
        lbl2.text = "Label 2"
        part.layer.borderColor = UIColor.yellow.cgColor
        part.layer.borderWidth = 1

        for i in 0..<9 {
            let b = UILabel()
            let c:CGFloat = CGFloat(i / 9.0)
            b.backgroundColor = UIColor.init(red: c, green: c, blue: c, alpha: 1)
            b.layer.borderColor = UIColor.red.cgColor
            b.layer.borderWidth = 2
            lbls.append(b)
        }
    }

    override func setupViewTree() {
        let main = self.view
        let vt:[Any] = [
            content,
                [lbl1, lbl2],
            part,
                lbls,
        ]
        FLLayouts.addViewTo(main!, child: vt)
    }

    override func setupConstraint() {
        let parent = self.view!
        let main = content
        var a:[Any] = [
            FLLayouts.view(main, equalToSafeAreaOf: parent),

            FLLayouts.view(lbl1, corner: .centerXCenterY, to: main),
            FLLayouts.view(lbl1, width: 200, height: 70),

            FLLayouts.view(lbl2, corner: .rightBottom, to:main),
            FLLayouts.view(lbl2, width: 150, height: 100),

            FLLayouts.view(part, corner: .leftBottom, to:main, offsetX: 10, offsetY: -20),
            FLLayouts.view(part, width: 200, height: 200),
        ]
        for i in 0..<9 {
            let vi = lbls[i]
            var cr = FLCorner.of(i+1)
            vi.text = "# " + String(i) + " = " + String(cr.rawValue)
            vi.adjustsFontSizeToFitWidth = true
            a.append(FLLayouts.view(vi, width: 20 + 4*i, height: 20+4*i))
            a.append(FLLayouts.view(vi, corner:cr, to: part))
        }
        FLLayouts.activate(parent, forConstraint: a)
    }
}
