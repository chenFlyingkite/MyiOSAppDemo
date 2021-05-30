//
// Created by Eric Chen on 2021/5/27.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class FLWindow : UIWindow {
    private var showTaps = true
    // from #sendEvent() to get each touch
    private var srcEvent : UIEvent?
    // Touch hash id order
    private var pointOrder :[Int] = []
    // Main touch show on debug touch
    private var pointMain = 0
    // All touch event in {Touch.hash : Touch}
    private var pointMap = Dictionary<Int,UITouch>()
    // parent of cursors and touchInfo
    private var pane = UIView()
    // Visual feedback for touch
    private var cursors : [UILabel] = []
    private var touchInfo = FLDebugTouchView()
    // Visual feedback colors
    // red, yellow, green, cyan, blue, magenta, and darker
    private let colors = [
        "#80ff0000", "#80ffff00", "#8000ff00", "#8000ffff", "#800000ff", "#80ff00ff",
        //"#80800000", "#80808000", "#80008000", "#80008080", "#80000080", "#80800080",
    ]
    private let clock = FLTicTac()
    private var debug = 0 > 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup() // here
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addCursors()
    }

    override func sendEvent(_ event: UIEvent) {
        if (debug) {
            clock.tacS("from iOS system")
            clock.tic()
        }
        showHint(event)
        if (debug) {
            clock.tacS("showHint")
            lg()
        }
        super.sendEvent(event)
        if (debug) {
            clock.tic()
            wqe("")
        }
    }

    func setShowTaps(_ show:Bool) {
        showTaps = show
        pane.isHidden = show
        if (!show) {
            srcEvent = nil
            pointMain = 0
            pointOrder = []
            pointMap.removeAll()
        }
    }

    //--
    private func addCursors() {
        // reset
        self.pane.removeAllSubviews()
        pane.removeFromSuperview()
        cursors.removeAll()
        // build
        let n = colors.count // most 5 fingers
        let bg = UIColor.init(hex: "#8000")
        for i in 0..<n {
            let t = createHint(i)
            let cs = colors[i]
            let c = UIColor.init(hex: cs)
            FLUIStyles.applyBorder(t, cs, 5)
            t.backgroundColor = bg
            // location line, vh & vv
            addLocationLine(t, c)
            // add to cursor
            cursors.append(t)
            pane.addSubview(t)
        }
        pane.addSubview(touchInfo)
        self.addSubview(pane)
        self.pane.disableTouch()

        let c:[Any?] = [
            FLLayouts.view(pane, sameTo: self),
            FLLayouts.view(touchInfo, equalToSafeAreaOf: self, side: "LTR"),
            FLLayouts.view(touchInfo, set: .height, to: touchInfo.barHeight),
        ]
        FLLayouts.activate(self, forConstraint: c)
    }

    // create hint view
    private func createHint(_ p:Int) -> UILabel {
        let t = UILabel()
        let r = 25
        t.frame = CGRect(x: 0, y: 10 * p, width: 2*r, height: 2*r)
        t.isHidden = false
        t.text = "#\(p)"
        t.adjustsFontSizeToFitWidth = true
        //t.font = UIFont.systemFont(ofSize: 15)
        t.textAlignment = .left
        t.layer.cornerRadius = 10//CGFloat(r)
        t.textColor = UIColor.init(hex: "#fff")
        return t
    }

    private func addLocationLine(_ v:UIView, _ c:UIColor) {
        // location line, vh & vv
        let vh = UIView()
        let vv = UIView()
        vh.backgroundColor = c
        vv.backgroundColor = c
        let length = 2.0 * 1000 // assume 1000 = screenLongSide, may be ok
        let a:[Any?] = [
            FLLayouts.view(vh, width: 1, height: length),
            FLLayouts.view(vv, width: length, height: 1),
            FLLayouts.view(vh, corner: .centerXCenterY, to: v),
            FLLayouts.view(vv, corner: .centerXCenterY, to: v),
        ]
        v.addSubview(vv)
        v.addSubview(vh)
        v.sendSubviewToBack(vv)
        v.sendSubviewToBack(vh)
        FLLayouts.activate(v, forConstraint: a)
    }

    // O(|K|), if K touches
    private func setSource(_ e:UIEvent?) {
        srcEvent = e
        setPointMap(e)
    }

    // Rebuild pointMap from touches
    private func setPointMap(_ e:UIEvent?) {
        if let tch = e?.allTouches {
            pointMap.removeAll()
            let n = tch.count
            if (n == 0) {
                pointMain = 0
            }
            for t in tch {
                let k = keyOf(t)
                pointMap[k] = t
                if (n == 1) {
                    pointMain = k
                }
            }
        }
    }

    // O(|K|)
    // Making pointOrder for touches
    private func updatePointOrder(_ event: UIEvent) {
        if let tch = event.allTouches {
            let tn = tch.count
            let tchs = tch.toArray()
            for i in 0..<tn {
                let t = tchs[i]
                if (t.isAt([.began])) {
                    joinHash(t)
                } else if (t.isAt([.ended, .cancelled])) {
                    leaveHash(t)
                }
            }
        }
    }
    private func keyOf(_ t:UITouch?) -> Int {
        return t?.hashValue ?? 0
    }

    private func joinHash(_ it: UITouch) {
        let k = keyOf(it)
        //print("+hash _ \(k.hex())")
        pointOrder.append(k)
    }

    // O(|K|) for K touches
    private func leaveHash(_ it: UITouch) {
        // next = pointOrder - {it}
        // navigate all and discard it
        var next : [Int] = []
        var omit = keyOf(it)
        let n = pointOrder.count
        for i in 0..<n {
            let k = pointOrder[i]
            if (omit == k) {
            } else {
                next.append(k)
            }
        }
        pointOrder = next
        //print("-hash ^ \(omit.hex())")
    }

    private func showHint(_ event: UIEvent) {
        if (!showTaps) {
            return
        }

        setSource(event)
        updatePointOrder(event)
        showPointers()
        var delta: UITouch? // changed touch, should only have one
        delta = pointMap[pointMain]
        //print("ptrs = \(strPO())")
        //print("delta = \(delta)")
        showLocation(delta, event)
        self.pane.bringToFront()
    }

    // O(|K|)
    // move each cursor to position
    private func showPointers() {
        let pn = cursors.count
        let pon = pointOrder.count
        for i in 0..<pn {
            var x = 0
            if (i < pon) {
                x = pointOrder[i]
            }
            let ci = cursors[i]
            if (x == 0) {
                // stay at home
                ci.center = CGPoint(x: 30, y: 10 * i)
                ci.isHidden = true
            } else {
                // send to work
                if let pt = pointMap[x] {
                    var c = CGPoint.zero
                    c = pt.location(in: nil) // raw location on screen
                    ci.text = String.init(format: "#%d\n%6.1f\n%6.1f", i, c.x, c.y)
                    ci.numberOfLines = 3
                    ci.center = c
                    ci.isHidden = false
                }
            }
            ci.bringToFront()
        }
    }

    private func showLocation(_ delta:UITouch?, _ event: UIEvent) {
        var main :UITouch? = nil
//        if (pointOrder.count > 0) {
//            main = pointMap[pointOrder[0]]
//        } else {
//            main = delta
//        }
        //wqe("send to \(main)\ndelta = \(delta)")
        // not decide when two up, if is
        // _1, _2, ~1, ~2
        // , ^1 => shows ^1 - _1
        // , ^2 => shows ^2 - _1
        main = delta

        if let me = main {
            touchInfo.show(me, event)
        } else {
        }
    }

    private func lg() {
        let s = strPO()
        print("pointOrder = \(s)")
        print("map = \(pointMap)")
        var seeCursor = false
        if (seeCursor) {
            let n = cursors.count
            print("\(n) cursors")
            for i in 0..<n {
                let v = cursors[i]
                print("#\(i) : \(v.center.f2()) \(v)")
            }
        }
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
}

