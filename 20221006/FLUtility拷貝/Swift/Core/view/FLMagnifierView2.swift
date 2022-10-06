//
// Created by Eric Chen on 2021/4/27.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

// Magnifier for holding a GPUImageView inside
class FLMagnifierView2: UIView {
    let gpuView = GPUImageView()
    private let clk = FLTicTac()
    var gpuTopLC: NSLayoutConstraint?
    var gpuLeftLC: NSLayoutConstraint?
    var gpuWidthLC: NSLayoutConstraint?
    var gpuHeightLC: NSLayoutConstraint?
    // of left top, so the view's left-top is this value
    private var focusOfLeftTop = CGPoint.zero // (0, 0) ~ reflectSize
    private var scale = CGPoint(x: 1, y: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
        self.clipsToBounds = true
    }

    private func setupViewTree() {
        let vs = [gpuView,]
        FLLayouts.addView(to: self, child: vs)
    }

    private func setupConstraint() {
        let parent = self
        gpuTopLC = FLLayouts.view(gpuView, align: .top, to: parent, offset: 0)
        gpuLeftLC = FLLayouts.view(gpuView, align: .left, to: parent, offset: 0)
        gpuWidthLC = FLLayouts.view(gpuView, set: .width, to: 100)
        gpuHeightLC = FLLayouts.view(gpuView, set: .height, to: 100)
        let a:[Any?] = [
            gpuLeftLC, gpuTopLC, gpuWidthLC, gpuHeightLC
        ]
        FLLayouts.activate(parent, forConstraint: a)
    }

    private func setupAction() {

    }

    // MARK: public methods
    func setReflectSize(_ z:CGSize, _ s:CGPoint) {
        let w = z.width
        let h = z.height
        self.frame = CGRect(x: 0, y: 0, width: w, height: h)
        setScale(s)
    }

    func getFocus() -> CGPoint {
        return focusOfLeftTop
    }

    func setFocusLeftTop(_ p:CGPoint) {
        focusOfLeftTop = p
        gpuLeftLC?.constant = -p.x
        gpuTopLC?.constant = -p.y
        update()
    }

    func getScale() -> CGPoint {
        return scale
    }

    func setScale(_ p:CGPoint) {
        scale = p
        let zw = self.frame.width
        let zh = self.frame.height
        let w = zw * p.x
        let h = zh * p.y
        gpuWidthLC?.constant = w
        gpuHeightLC?.constant = h
        update()
    }

    private func update() {
        setNeedsLayout()
    }
}
