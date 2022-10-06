//
// Created by Eric Chen on 2021/3/5.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class FLSDevMainUI : NSObject {
    private var main : UIView?
    let topArea = UIView()
    let keyFNS = UIScrollView()
    let keyFN = BoardFn()
    let editArea = UIView()
    let editBG = UIView()
    let gpuView = GPUImageView()
    let demo = UIView()

    //####################################################
    // MARK: UI Basic
    //####################################################
    func inflate(_ root: UIView) {
        main = root
        FLSLog.recording = 1 > 0//seeConsole
        setup()
    }

    // MARK: UI Layouts
    private func setup() -> Void {
        setupRes()
        setupViewTree()
        setupConstraint()
        setupAction()
    }

    private func setupRes() {
        topArea.backgroundColor = UIColor.init(hex: "#200")
        editArea.backgroundColor = UIColor.init(hex: "#220")
        keyFN.backgroundColor = UIColor.init(hex: "#222")
        editBG.backgroundColor = UIColor.init(hex:"#040")
        gpuView.backgroundColor = UIColor.init(hex:"#004")
    }

    private func setupViewTree() {
        let v:[Any?] = [
            topArea,
                [keyFNS,
                 [keyFN,]
                ],
            editArea,
                [editBG, gpuView, demo,],

        ]
        FLSUIKits.addView(root: main!, child: v)
    }

    private func setupConstraint() {
        let vs = [topArea, editArea]
        let z = keyFN.getMeasuredSize()
        let w = z.width.lf()
        let h = z.height.lf()
        let parent = main
        var a:[Any?] = [
            FLLayouts.view(parent, layout: vs, axis: .topToBottom, gravity: .matchParent),
            FLLayouts.view(topArea, set: .height, to: h + 10.0),
            FLLayouts.view(keyFNS, sameTo: topArea),
            FLLayouts.view(keyFN, width: w, height: h),
            FLLayouts.view(editBG, sameTo: editArea),
            FLLayouts.view(gpuView, sameTo: editArea, offset: UIEdgeInsets.init(4)),
            FLLayouts.view(demo, drawer:.top, to: editArea, depth: 200, offset: UIEdgeInsets.init(2)),
        ]
        FLLayouts.activate(main, forConstraint: a)

        keyFNS.contentSize = z
    }

    private func setupAction() {

    }

}
