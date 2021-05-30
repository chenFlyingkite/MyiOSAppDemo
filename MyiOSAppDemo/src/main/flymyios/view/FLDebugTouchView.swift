//
// Created by Eric Chen on 2021/4/11.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class FLDebugTouchView : UIView {
    let bar = UIView()
    let pointers = UILabel()
    let pointerX = UILabel() // X : , dX
    let pointerY = UILabel() // Y : , dY
    let pointerXv = UILabel()
    let pointerYv = UILabel()
    let barHeight = 14.0
    private let info = StateInfo()

    private class StateInfo {
        var activeCount = 0
    }

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
        bar.backgroundColor = UIColor.init(hex: "#4fff")
        let txs = labels()
        let n = txs.count
        for i in 0..<n {
            let b = txs[i]
            b.textColor = UIColor.black
            b.textAlignment = .left
            //var f = CGFloat(barHeight - 2.0 * (i)) //-4 or -6 is good
            var f = 0.0
            f = barHeight - 4
            if (i == 3 || i == 4) {
                // 3 = Xv, 4 = Yv
                f = barHeight - 5
            }
            b.font = .systemFont(ofSize: f.cgFloat())
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
        self.disableTouch()
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
            FLLayouts.view(bar, sameTo: parent),
            FLLayouts.view(bar, set: .height, to: barHeight),
            FLLayouts.view(bar, layout: ch, axis: .leftToRight, gravity: .matchParent),
            FLLayouts.views(ch, same: .widthHeight),
        ]
        FLLayouts.activate(self, forConstraint: a)
    }

    private func setupAction() {

    }

    // pointer = P: now/max
    private var ptMax = 0
    private var ptNow = 0
    private var mainDown : UITouch?
    private var prevTime = 0.0 // TimeInterval = Double
    private var prevAt = CGPoint.zero // for X/Yv
    private var ptDown = CGPoint.zero // for dX/Y
    func show(_ main:UITouch, _ event:UIEvent) {
        let ptr = main
//        wqe("main = \(main)")
//        wqe("event = \(event)")
        let isBegan = ptr.isAt([.began])
        let isEnded = ptr.isAt([.ended, .cancelled])

        readState(event)
        ptNow = info.activeCount
        ptMax = maxl(ptMax, ptNow)
        pointers.text = String(format: "P: %d / %d", ptNow, ptMax)
        let nowAt = ptr.location(in: nil) // raw
        if (isBegan) {
            ptDown = nowAt
            mainDown = main
        }
        var reset = false
        if (isEnded) {
            reset = true
            var dx = nowAt.x - ptDown.x
            var dy = nowAt.y - ptDown.y
            pointerX.text = String(format: "dX: %.1f", dx)
            pointerY.text = String(format: "dY: %.1f", dy)
        } else {
            pointerX.text = String(format: "X: %.1f", nowAt.x)
            pointerY.text = String(format: "Y: %.1f", nowAt.y)
        }
        var vx = 0.0, vy = 0.0
        let now = ptr.timestamp
        let prev = prevTime
        let dt = now - prev
        if (dt > 0) {
            var dx = nowAt.x - prevAt.x
            var dy = nowAt.y - prevAt.y
            vx = dx.lf() / dt
            vy = dy.lf() / dt
        }
        pointerXv.text = String(format: "Xv: %.3f", vx)
        pointerYv.text = String(format: "Yv: %.3f", vy)
        // save to state
        prevAt = nowAt
        prevTime = ptr.timestamp
        if (reset) {
            ptMax = 0
            mainDown = nil
        }
    }

    // return touches not ended & cancelled
    private func readState(_ event:UIEvent) {
        var ans = self.info
        ans.activeCount = 0
        if let tch = event.allTouches {
            for t in tch {
                let end = t.isAt([.ended, .cancelled])
                if (end) {
                } else {
                    ans.activeCount++
                }
            }
        }
    }

//    // MARK : touches pass
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        wqe("pass began to \(self.next)")
//        self.next?.touchesBegan(touches, with: event)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesMoved(touches, with: event)
//        wqe("pass moved to \(self.next)")
//        self.next?.touchesMoved(touches, with: event)
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesEnded(touches, with: event)
//        wqe("pass ended to \(self.next)")
//        self.next?.touchesEnded(touches, with: event)
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesCancelled(touches, with: event)
//        wqe("pass cancel to \(self.next)")
//        self.next?.touchesCancelled(touches, with: event)
//    }
//
//    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
//        super.touchesEstimatedPropertiesUpdated(touches)
//        wqe("pass began to \(self.next)")
//        self.next?.touchesEstimatedPropertiesUpdated(touches)
//    }
}
