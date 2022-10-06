//
// Created by Eric Chen on 2021/4/12.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class FLDashBorderView: UIView {
    var dashBorderLayer : CAShapeLayer?
    var dashBorderColorHex : String = "#8f80"
    var dashBorderLineWidth : CGFloat = 18
    var dashBorderLineDashPattern : [NSNumber] = [5, 5]
    // anchor lines
    private let vv = UIView()
    private let hh = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.applyDashBorder()
    }

    private func applyDashBorder() {
        self.dashBorderLayer?.removeFromSuperlayer()
        self.dashBorderLayer = FLUIStyles.createDashBorder(self, dashBorderColorHex, dashBorderLineWidth, dashBorderLineDashPattern)
        if let d = self.dashBorderLayer {
            self.layer.addSublayer(d)
        }
    }

    // MARK: UI Layouts
    private func setup() -> Void {
        setupRes()
        setupViewTree()
        setupConstraint()
        setupAction()
    }

    private func setupRes() {
        vv.backgroundColor = UIColor.init(hex: "#0f0")
        hh.backgroundColor = UIColor.init(hex: "#ff0")
        vv.isHidden = true
        hh.isHidden = true
    }

    private func setupViewTree() {
        let vs = [vv, hh]
        FLLayouts.addView(to: self, child: vs)
    }

    private func setupConstraint() {
        let parent = self
        let a:[Any?] = [
            FLLayouts.view(vv, set: .width, to: 1),
            FLLayouts.view(vv, align: .height, to: parent),
            FLLayouts.view(vv, corner: .centerXCenterY, to: parent),
            FLLayouts.view(hh, set: .height, to: 1),
            FLLayouts.view(hh, align: .width, to: parent),
            FLLayouts.view(hh, corner: .centerXCenterY, to: parent),
        ]
        FLLayouts.activate(parent, forConstraint: a)
    }

    private func setupAction() {

    }
}
