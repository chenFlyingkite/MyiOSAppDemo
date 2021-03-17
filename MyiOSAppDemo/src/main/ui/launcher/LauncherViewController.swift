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

    override func setupViewTree() {
        let vt = [lbl1, lbl2]
//
//        let safe = self.view
//        let t = [content]
//        FLLayouts.addView(to: safe, child: t)
    }

    override func setupConstraint() {


//        let parent = self.view
//        let main = content
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
