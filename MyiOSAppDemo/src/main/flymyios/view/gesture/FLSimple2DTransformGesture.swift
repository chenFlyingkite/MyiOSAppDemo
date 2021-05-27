//
// Created by Eric Chen on 2021/2/10.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class FLSimple2DTransformGesture: UIGestureRecognizer {
    private var log = false
    private var logMethod = false // used to see the event dispatch time
    private let clk = FLTicTac()
    var listener : FL2DTransformListener? = nil

    // for pan, by N0 - D0
    // Multiple points N0 = (N1 + N2) / 2, D0 = (D1 + D2) / 2
    private var downP0 = CGPoint.zero
    // for scale + rotate, by |N1 - N2| / |D1 - D2| & atan
    private var downP1 = CGPoint.zero
    private var downP2 = CGPoint.zero

    // -- Internal data structures
    // Point orders, represented by keys
    private var pointOrder :[Int] = []
    // for fetch the source UITouch
    private var srcEvent : UIEvent? = nil
    var singleTouchToRotate = false
    var singleTouchRotateAnchor = CGPoint.zero
    var callPan = true
    var callZoom = true
    var callRotate = true
    // todo 3 more fingers
    //var maximumNumberOfTouches = 2
    // pan one finger, zoom two finger
    var pan1zoom2 = false

    private var sendingMe : MotionEvent?

    // MARK: touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (log) {
            print("_began")
        }
        if (log || logMethod) {
            clk.tic()
            wqe("_began start \(listener)")
        }
        let n = self.numberOfTouches
        let me = MotionEvent.init(touches, event, self)
        sendingMe = me
        setSource(event)
        joinHash(touches)
        if (log) {
            lg()
            print("__down.P\(n)")
        }
        viewPressing(true)
        //clk.tic()
        listener?.onStart(self, n)
        //clk.tacS("listener?.onStart(self, \(n))")
        if (n == 1) {
            downP0 = point(0)
            //clk.tic()
            listener?.onDown(me)
            //clk.tacS("listener?.onDown(me)")
        } else {
            // pointer down
            // n >= 2
            downP1 = point(0)
            downP2 = point(1)
            downP0 = downP1.center(downP2)
            listener?.onPointerDown(me)
        }
        if (singleTouchToRotate) {
            downP1 = singleTouchRotateAnchor
            downP2 = point(0)
            downP0 = downP1.center(downP2)
        }
        if (log) {
            lg()
            print("_ down")
            a(touches, event)
        }
        if (log || logMethod) {
            clk.tacS("in_began")
            wqe("_began end")
            clk.tic()
        }
    }

    private func updatePan1Zoom2(_ pointN:Int) {
        let n = pointN
        if (pan1zoom2) {
            self.callPan = n == 1
            self.callZoom = n == 2
        }
    }

    // ... tap gesture listener did not send the pressed...
    private func viewPressing(_ p:Bool) {
        let m = self.view
        if let m = m as? UIImageView {
            m.isHighlighted = p
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if (log || logMethod) {
            clk.tacS("iOSUI_moved")
            clk.tic()
            wqe("_moved start")
        }
        let n = self.numberOfTouches
        let me = sendingMe!.sets(touches, event)
        if (log) {
            print("~moved")
            lg()
        }
        updatePan1Zoom2(n)
        //clk.tic()
        listener?.onMove(me)
        //clk.tacS("listener?.onMove(me)")
        var now0 = point(0)
        // change move anchor point to vector center
        var dp = downP0.vectorTo(now0)
        if (n > 1 || singleTouchToRotate) {
            var now1 = point(1)
            if (singleTouchToRotate) {
                //clk.tic()
                listener?.onBeginSingleTouchRotate()
                //clk.tacS("listener?.onBeginSingleTouchRotate()")
                now0 = singleTouchRotateAnchor
                now1 = point(0)
            }
            let vec0 = downP1.vectorTo(downP2)
            let vec1 = now0.vectorTo(now1)
            let len0 = vec0.length()
            let len1 = vec1.length()
            let mid0 = now0.center(now1)
            dp = downP0.vectorTo(mid0)
            let deg = vec1.degree() - vec0.degree()
            let scale = (len0 > 0) ? (len1 / len0) : 1
//            if (log) {
//                wqe("down01 = \(vec0.f2()) = \(downP1.f2()), \(downP2.f2())")
//                wqe("now_01 = \(vec1.f2()) = \(now0.f2()), \(now1.f2())")
//                wqe("scale = \(scale) : \(len0) -> \(len1)")
//            }

            if (callRotate) {
                //clk.tic()
                listener?.onRotate(deg, me)
                //clk.tacS("listener?.onRotate(\(deg), me)")
            }
            if (callZoom) {
                //clk.tic()
                let s = Double(scale)
                listener?.onZoom(s, me)
                //clk.tacS("listener?.onZoom(\(s), me)")
            }
            //clk.tic()
            listener?.onEndSingleTouchRotate()
            //clk.tacS("listener?.onEndSingleTouchRotate()")
        }

        if (callPan) {
            //clk.tic()
            listener?.onPan(dp.toPointF(), me)
            //clk.tacS("listener?.onPan(dp.toPointF(), me)")
        }
        if (log) {
            lg()
            print("~Move")
            a(touches, event)
        }
        if (log || logMethod) {
            clk.tacS("in_moved")
            wqe("_moved end")
            clk.tic()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if (log || logMethod) {
            clk.tacS("iOSUI_ended")
            clk.tic()
            wqe("_ended start")
        }
        let n = self.numberOfTouches
        let me = sendingMe!.sets(touches, event)
        leaveHash(touches)
        if (log) {
            print("^ended")
            lg()
            print("^Up.P\(n)")
        }
        viewPressing(false)
        //clk.tic()
        listener?.onFinish(self, n)
        //clk.tacS("listener?.onFinish(self, \(n))")
        if (n == 1) {
            //clk.tic()
            listener?.onUp(me)
            //clk.tacS("listener?.onUp(me)")
        } else {
            // pointer up
            // n >= 2
            downP0 = point(0)
            downP1 = point(0)
            //clk.tic()
            listener?.onPointerUp(me)
            //clk.tacS("listener?.onPointerUp(me)")
        }
        if (log) {
            lg()
            print("^~Up")
            a(touches, event)
        }
        if (log || logMethod) {
            clk.tacS("in_ended end")
            wqe("_up end")
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        if (log || logMethod) {
            clk.tacS("iOSUI_cancel")
            clk.tic()
            wqe("_cancel start")
        }
        let n = self.numberOfTouches
        let me = sendingMe!.sets(touches, event)
        if (log) {
            print("x.Cancel \(n)")
        }
        leaveHash(touches)
        listener?.onCancelled(me)
        if (log) {
            a(touches, event)
        }
        if (log || logMethod) {
            clk.tacS("in_cancel end")
            wqe("_cancel end")
        }
    }

    // MARK: pressed
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        //print("__prs")
        //a(presses, event)
        //wqe("")
    }
    override func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        //print("~~prs")
        //a(presses, event)
        //wqe("")
    }
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        //print("^^prs")
        //a(presses, event)
        //wqe("")
    }

    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        //print("xx_prs")
        //a(presses, event)
        //wqe("")
    }

    // MARK: bool methods
    
    override func reset() {
        //wqe("")
    }
    
    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        //wqe("")
        return false
    }

    override func canBePrevented(by preventingGestureRecognizer: UIGestureRecognizer) -> Bool {
        //wqe("")
        return false
    }

    override func shouldRequireFailure(of otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //wqe("")
        return false
    }

    override func shouldBeRequiredToFail(by otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //wqe("")
        return false
    }

    override func shouldReceive(_ event: UIEvent) -> Bool {
        //wqe("")
        return true
    }

    // MARK: Getting points
    func getRaw(_ n:Int) -> CGPoint {
        return point(n)
    }

    // MARK: Internal
    private func point(_ at:Int) -> CGPoint {
        let tch = touch(at)
        if let t = tch {
            let p = t.location(in: t.view) // this makes scale be in wrong one
            let q = t.location(in: nil) // from left-top of device
            //wqe("p = \(p.f2()), q = \(q.f2())")
            return q
        }
        return .zero
    }

    private func keyOf(_ t:UITouch?) -> Int {
        return t?.hashValue ?? 0
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

    private func setSource(_ e:UIEvent) {
        if (srcEvent == nil) {
            srcEvent = e
        }
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

    // Deprecated, uses point(at)
    // return touch point[at]
    private func pointOld(_ at:Int) -> CGPoint {
        let v : UIView? = self.view
        let r : UIGestureRecognizer = self
        let n = r.numberOfTouches
        let p = makeInBound(at, 0, n - 1)
        if let v = v {
            // This method is not stable for touch index value, since it may have
            // (p0, p1) = (0, 10) & (50, 90) but set<Touch> = (p1, p0)...
            // but if get the touch by its int, it may put back as (p1, p0), ...
            // when perform down0, move0, down1, move1, up0, move1...
            return r.location(ofTouch: p, in: v)
        }
        return .zero
    }

    // MARK: Loggings
    private func lg() {
        print("d0 = \(downP0.f2())          d1 = \(downP1.f2())          d2 = \(downP2.f2())")
        print("now = \(self.strPO())")
        print("src = \(srcEvent)")
    }

    private func strPO() -> String {
        var s = "["
        for i in 0..<pointOrder.count {
            let x = pointOrder[i]
            if (i > 0) {
                s += ", "
            }
            s += String.init(format:"%08x", x)
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
