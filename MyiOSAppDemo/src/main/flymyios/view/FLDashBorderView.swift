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
        self.isMultipleTouchEnabled = true

    }
    //--

    private func ne() -> UIResponder? {
        return self.next; // = superview...
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        onBegin(touches, event)
        wqe("_ t(\(touches.count)) = \(touches)\ne = \(event)")
        lg()
        ne()?.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        onMove(touches, event)
        wqe("~ t(\(touches.count)) = \(touches)\ne = \(event)")
        lg()
        ne()?.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        onUp(touches, event)
        wqe("^ t(\(touches.count)) = \(touches)\ne = \(event)")
        lg()
        ne()?.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        onCancel(touches, event)
        wqe("x t(\(touches.count)) = \(touches)\ne = \(event)")
        lg()
        ne()?.touchesCancelled(touches, with: event)
    }

    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        super.touchesEstimatedPropertiesUpdated(touches)
        wqe("$ t(\(touches.count)) = \(touches)")
        lg()
        ne()?.touchesEstimatedPropertiesUpdated(touches)
    }

    private var pointOrder :[Int] = []
    // for fetch the source UITouch
    private var srcEvent : UIEvent? = nil
    private var sendingMe : MotionEvent?
    private var empty = FLSimple2DTransformGesture()

    private func onBegin(_ touches: Set<UITouch>, _ event: UIEvent?) {
        let me = MotionEvent.init(touches, event!, empty)
        sendingMe = me
        setSource(event)
        joinHash(touches)
    }

    private func onMove(_ touches: Set<UITouch>, _ event: UIEvent?) {
        let me = sendingMe?.sets(touches, event!)
    }

    private func onUp(_ touches: Set<UITouch>, _ event: UIEvent?) {
        let me = sendingMe!.sets(touches, event!)
        leaveHash(touches)
    }

    private func onCancel(_ touches: Set<UITouch>, _ event: UIEvent?) {
        onUp(touches, event)
    }


    private func setSource(_ e:UIEvent?) {
        //if (srcEvent == nil) {
            srcEvent = e
        //}
    }

    private func keyOf(_ t:UITouch?) -> Int {
        return t?.hashValue ?? 0
    }

    private func joinHash(_ it: Set<UITouch>) {
        // pointOrder += {it}
        let n = pointOrder.count
        for x in it {
            let k = keyOf(x)
            for i in 0..<n {
                if (pointOrder[i] == k) {
                    //print("X_X exist for po[\(i)] = 0x\(k.hex()) = \(x)")
                }
            }
            pointOrder.append(k)
        }
    }

    private func leaveHash(_ it: Set<UITouch>) {
        // next = pointOrder - {it}
        var next : [Int] = []
        var omit = Set<Int>()
        for x in it {
            omit.insert(keyOf(x))
        }
        let n = pointOrder.count
        for i in 0..<n {
            let k = pointOrder[i]
            if (omit.contains(k)) {
            } else {
                next.append(k)
            }
        }
        pointOrder = next
    }

    // MARK: Internal
    private func point(_ at:Int, _ raw:Bool = false) -> CGPoint {
        let tch = touch(at)
        if let t = tch {
            let p = t.location(in: t.view) // this makes scale be in wrong one
            let q = t.location(in: nil) // from left-top of device
            //wqe("p = \(p.f2()), q = \(q.f2())")
            return raw ? q : p
        }
        return .zero
    }

    private func touch(_ at:Int) -> UITouch? {
        if (inBound(at, pointOrder)) {
            let k = pointOrder[at]
            if let src = srcEvent?.allTouches {
                for x in src {
                    if (keyOf(x) == k) {
                        return x
                    }
                }
            }
        }
        return nil
    }
    // Deprecated, uses point(at)
    // return touch point[at]
    private func pointOld(_ at:Int) -> CGPoint {
//        let v : UIView? = self.view
//        //let r : UIGestureRecognizer = self
//        let n = 0//r.numberOfTouches
//        let p = makeInBound(at, 0, n - 1)
//        if let v = v {
//            // This method is not stable for touch index value, since it may have
//            // (p0, p1) = (0, 10) & (50, 90) but set<Touch> = (p1, p0)...
//            // but if get the touch by its int, it may put back as (p1, p0), ...
//            // when perform down0, move0, down1, move1, up0, move1...
//            //return r.location(ofTouch: p, in: v)
//        }
        return .zero
    }

    // MARK: Loggings
    private func lg() {
        print("now = \(self.strPO())")
        print("pxy = \(self.strPxy())")
        //UIWindow.sendEvent()
        //print("src = \(srcEvent)")
    }

    private func strPO() -> String {
        var s = "["
        for i in 0..<pointOrder.count {
            let x = pointOrder[i]
            if (i > 0) {
                s += ", "
            }
            s += String.init(format:"0x%08x", x)
        }
        s += "]"
        return s
    }

    private func strPxy() -> String {
        var s = "["
        for i in 0..<pointOrder.count {
            let x = pointOrder[i]
            if (i > 0) {
                s += ", "
            }
            let p = point(i)
            s += p.f2()
        }
        s += "]"
        return s
    }

    private func a(_ t:Set<UITouch>, _ e: UIEvent?) {
        print("e = \(e)")
        let ee = e?.allTouches
        if let ee = ee {
            var i = 0
            print("e.allTouches (\(ee.count)) = ")
            for x in ee {
                print("#\(i) = \(x.location(in: x.view).f2()), hash = \(x.hash.hex()), \(x.hashValue.hex()), \(x)")
                i++
            }
        }
        let n = t.count
        print("Set<UITouches> (\(n)) =")
        var i = 0
        for x in t {
            print("#\(i) = \(x.location(in: x.view).f2()), \(x.hashValue.hex()), \(x)")
            i++
        }
        print("-----")
    }
}

// https://stackoverflow.com/questions/3046813/how-can-i-click-a-button-behind-a-transparent-uiview
class PassThroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        //return super.point(inside: point, with: event)
        for subview in self.subviews {
            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                wqe("inside \(point.f2())")
                return true
            }
        }
        wqe("Not inside \(point.f2())")
        return false
    }

// Let parent, [x], and parent.ltrb = (0, 0, 50, 50), x.ltrb = (0, 20, 50, 70)
// then hit test takes y.ltrb = (0, 50, 50, 70) as not inside, so y is no touch
// while point(inside:with) as yes, so y has touch

//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        //return super.hitTest(point, with: event)
//        let v = super.hitTest(point, with: event)
//        wqe("v == self = \(v == self)")
//        return v == self ? nil : v
//    }

}
