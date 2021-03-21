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

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        var d1:Double = 3.3
        d1.roundedInt()
        var f1: Float = 2.5
        f1.roundedInt()
        // Do any additional setup after loading the view.
        print("viewDidLoad")
        let x = ASD.init()
        print("ASD.init() OK")
//        tr = 0.393R + 0.769G + 0.189B
//        tg = 0.349R + 0.686G + 0.168B
//        tb = 0.272R + 0.534G + 0.131B
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
//
//        let t = [content]
//        FLLayouts.addView(to: safe, child: t)
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

//        var a:[Any?] = [
//            //FLLayouts.view(content, sameTo: parent),
//            //content.leftAnchor.constraint(equalTo: parent?.safeAreaLayoutGuide)
//        ]
//        if let g = parent?.safeAreaLayoutGuide {
//            a += [
//                main.leftAnchor.constraint(equalTo: g.leftAnchor),
//                main.topAnchor .constraint(equalTo: g.topAnchor),
//                main.rightAnchor.constraint(equalTo: g.rightAnchor),
//                main.bottomAnchor.constraint(equalTo: g.bottomAnchor),
//            ]
//        }
//        FLLayouts.activate(parent, forConstraint: a)
    }
}
