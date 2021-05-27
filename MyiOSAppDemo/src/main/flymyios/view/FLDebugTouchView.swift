//
// Created by Eric Chen on 2021/4/11.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

// todo complete me
class FLDebugTouchView : UIView {
    let bar = UIView()
    let pointers = UILabel()
    let pointerX = UILabel() // X : , dX
    let pointerY = UILabel() // Y : , dY
    let pointerXv = UILabel()
    let pointerYv = UILabel()
    let barHeight = 14.0

    //let bar = UIView()
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
        //let re = self.resignFirstResponder() // x
        bar.backgroundColor = UIColor.init(hex: "#4fff")
        let txs = labels()
        let n = txs.count
        for i in 0..<n {
            let b = txs[i]
            b.textColor = UIColor.black
            b.textAlignment = .left
            //b.adjustsFontSizeToFitWidth = true
            let f = CGFloat(barHeight - 2.0 * (i)) //-4 or -6 is good
            b.font = .systemFont(ofSize: f)
        }
        FLUIStyles.applyBorder(pointers, "#f00", 1)
        FLUIStyles.applyBorder(pointerX, "#0f0", 1)
        FLUIStyles.applyBorder(pointerY, "#00f", 1)
        FLUIStyles.applyBorder(pointerXv, "#ff0", 1)
        FLUIStyles.applyBorder(pointerYv, "#0ff", 1)
        pointers.text = "P: 0 / 0"
        pointerX.text = "X: 123.4"
        pointerY.text = "Y: 456.7"
        pointerXv.text = "Xv: 6.0"
        pointerYv.text = "Yv: -7.8"
    }

    private func labels() -> [UILabel] {
        return [pointers, pointerX, pointerY, pointerXv, pointerYv]
    }

    private func getViewTree() -> [Any] {
        return [bar, labels(),]
    }

    private func setupViewTree() {
        let vx = getViewTree()
        FLLayouts.addView(to: self, child: vx)
    }

    private func setupConstraint() {
        let parent = self
        let ch = labels()
        let a:[Any?] = [
            FLLayouts.view(bar, drawer: .top, to: parent, depth: barHeight),
            FLLayouts.view(bar, layout: ch, axis: .leftToRight, gravity: .matchParent),
            FLLayouts.views(ch, same: .widthHeight),
        ]
        FLLayouts.activate(self, forConstraint: a)
    }

    private func setupAction() {

    }

    // MARK : touches pass
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        wqe("pass began to \(self.next)")
        self.next?.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        wqe("pass moved to \(self.next)")
        self.next?.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        wqe("pass ended to \(self.next)")
        self.next?.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        wqe("pass cancel to \(self.next)")
        self.next?.touchesCancelled(touches, with: event)
    }

    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        super.touchesEstimatedPropertiesUpdated(touches)
        wqe("pass began to \(self.next)")
        self.next?.touchesEstimatedPropertiesUpdated(touches)
    }
}
