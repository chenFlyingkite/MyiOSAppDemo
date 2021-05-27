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
    // <Touch hash : Touch>
    private var pointMap = Dictionary<Int,UITouch>()
    // Visual feedback for touch
    private var cursors : [UIView] = []
    // Visual feedback colors
    // red, yellow, green, cyan, blue, magenta, and darker
    private let colors = [
        "#80ff0000", "#80ffff00", "#8000ff00", "#8000ffff", "#800000ff", "#80ff00ff",
        //"#80800000", "#80808000", "#80008000", "#80008080", "#80000080", "#80800080",
    ]
    private let clock = FLTicTac()
    private var debug = false

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
        if (!show) {
            for v in cursors {
                v.isHidden = true
            }
            pointOrder = []
            pointMap.removeAll()
        }
    }

    //--
    private func addCursors() {
        let n = colors.count // most 5 fingers
        for i in 0..<n {
            let t = createHint(i)
            let c = UIColor.init(hex: colors[i])
            t.layer.borderColor = c.cgColor
            t.layer.borderWidth = 5
            cursors.append(t)
            self.addSubview(t)
        }
    }

    // create hint view
    private func createHint(_ p:Int) -> UILabel {
        let t = UILabel()
        let r = 25
        t.frame = CGRect(x: 0, y: 10 * p, width: 2*r, height: 2*r)
        t.isHidden = false
        t.text = "#\(p)"
        t.textAlignment = .left// not center
        t.layer.cornerRadius = 10//CGFloat(r)
        t.isUserInteractionEnabled = false
        t.textColor = UIColor.init(hex: "#fff")
        return t
    }

    // O(|K|), if K touches
    private func setSource(_ e:UIEvent?) {
        srcEvent = e
        // rebuild pointMap from touches
        if let tch = e?.allTouches {
            pointMap.removeAll()
            for t in tch {
                let k = keyOf(t)
                pointMap[k] = t
            }
        }
    }

    private func keyOf(_ t:UITouch?) -> Int {
        return t?.hashValue ?? 0
    }

    private func joinHash(_ it: UITouch) {
        let k = keyOf(it)
        pointOrder.append(k)
    }

    private func leaveHash(_ it: UITouch) {
        // next = pointOrder - {it}
        // navigate all and omit it
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
    }

    private func showHint(_ event: UIEvent) {
        if (!showTaps) {
            return
        }

        setSource(event)
        if let tch = event.allTouches {
            // O(|K|)
            // Making pointOrder and hashes
            for t in tch {
                let p = t.phase
                if (p == .began) {
                    joinHash(t)
                } else if (p == .ended || p == .cancelled) {
                    leaveHash(t)
                }
            }
            // O(|K|)
            // move to position
            let pn = cursors.count
            let n = pointOrder.count
            for i in 0..<pn {
                var x = 0
                if (i < pointOrder.count) {
                    x = pointOrder[i]
                }
                let ci = cursors[i]
                if (x == 0) {
                    ci.center = CGPoint(x: 30, y: 10 * i)
                    ci.isHidden = true
                } else {
                    if let pt = pointMap[x] {
                        var c = CGPoint.zero
                        //c = pt.location(in: pt.view) // NG since not view added
                        c = pt.location(in: nil) // add by window
                        ci.isHidden = false
                        ci.center = c
                    }
                }
                ci.bringToFront()
            }
        }
    }

    private func lg() {
        let s = strPO()
        print("pointOrder = \(s)")
        print("map = \(pointMap)")
        let n = cursors.count
        print("\(n) cursors")
        for i in 0..<n {
            let v = cursors[i]
            print("#\(i) : \(v.center.f2()) \(v)")
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

