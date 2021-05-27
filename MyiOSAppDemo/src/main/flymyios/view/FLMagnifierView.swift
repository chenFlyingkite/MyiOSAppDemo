//
// Created by Eric Chen on 2021/4/11.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

// This class may be draw slowly for GPU view, 60ms each point, about 16fps
class FLMagnifierView : UIView {
    private var projector = FLProjectView()
    private var focus = CGPoint.zero // (0, 0) ~ projector.frame.size
    private var scale = CGPoint(x: 1, y: 1)
    private var focusOffset = CGPoint.zero
    private let clk = FLTicTac()
    private let cross = UIView()

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
        FLUIStyles.applyBorder(cross, "#40f0", 2)
        cross.isHidden = true
    }

    private func setupViewTree() {
        let vs = [projector, cross]
        FLLayouts.addView(to: self, child: vs)
    }

    private func setupConstraint() {
        let parent = self
        let a:[Any?] = [
            FLLayouts.view(cross, corner: .centerXCenterY, to: parent),
            FLLayouts.view(cross, width: 10, height: 10),
        ]
        FLLayouts.activate(parent, forConstraint: a)
    }

    private func setupAction() {

    }

    // MARK: public methods

    func setSourceView(_ v:UIView?) {
        self.projector.setSourceView(v)
    }

    func getSourceView() -> UIView? {
        return self.projector.getSourceView()
    }

    func getFocus() -> CGPoint {
        return focus
    }

    func setFocus(_ p:CGPoint) {
        focus = p
        update()
    }

    func getScale() -> CGPoint {
        return scale
    }
    func setScale(_ p:CGPoint) {
        scale = p
        update()
    }
    func getFocusOffset() -> CGPoint {
        return focusOffset
    }
    func setFocusOffset(_ p:CGPoint) {
        focusOffset = p
        update()
    }

    func update() {
        setNeedsLayout()
        projector.setNeedsDisplay()
    }

//
//    override func layoutIfNeeded() {
//        super.layoutIfNeeded()
//    }

    override func layoutSubviews() {
        //clk.tacS("Mag.layoutSubs iosUI")
        //clk.tic()
        super.layoutSubviews()
        //clk.tacS("super.layoutSubviews()")
        //clk.tic()
        let f = focus
        let g = focusOffset
        let z = self.frame.size
        let sv = getSourceView()
        if let sv = sv {
            let sf = sv.frame
            let sx = sf.origin.x
            let sy = sf.origin.y
            let sw = sf.size.width
            let sh = sf.size.height
            let w = sw * scale.x
            let h = sh * scale.y
            let l = z.width  / 2 - (f.x + g.x) * scale.x + sx * 0
            let t = z.height / 2 - (f.y + g.y) * scale.y + sy * 0
            let r = CGRect(x: l, y: t, width: w, height: h)
            //print("focus = \(f), offset = \(g), scale = \(scale), sv = \(sv.frame)")
            //wqe("layout projector( \(projector.frame) ) -> r = \(r)")
            projector.frame = r
        }
        //clk.tacS("Mag.layoutSubs")
        //clk.tic()
    }
}