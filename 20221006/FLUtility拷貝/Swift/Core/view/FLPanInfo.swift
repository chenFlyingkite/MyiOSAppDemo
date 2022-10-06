//
// Created by Eric Chen on 2021/1/29.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

//----
fileprivate class FLPanInfo : NSObject, UIGestureRecognizerDelegate {

    //var own : FLPanListener?
    // todo UIGestureRecognizerDelegate
    private var prev : Event?
    private var thiz : Event?
    private var me : UIPanGestureRecognizer?
    private var we : UIGestureRecognizer?
    //private var action: MotionEvent = .possible



    @objc
    func onPan2(sender:UIGestureRecognizer) -> Void {
        self.preExec2(sender)
        //own?.onPan(sender, self)

        wqe("\(FLStringKit.now()!) : onPan2 \(sender)")
        let at = sender.numberOfTouches
        let pi = sender.location(in: sender.view)
        print("#\(at), pi = \(pi)")
        for i in 0..<sender.numberOfTouches {
            let p = sender.location(ofTouch: i, in: sender.view)
            print("touches : #\(i)/\(at) : \(p.f2())")
        }
    }


    private func preExec2(_ sender:UIGestureRecognizer) {
        if (we == nil) {
            we = sender
        }
        self.peek2(sender)
    }

    private func peek2(_ sender:UIGestureRecognizer) {
        let now = Event.from(sender)
        if (now.state == .began) {
            thiz = nil
        }
        prev = thiz
        thiz = now
        wqe("p2: prev = \(prev), thiz = \(thiz), action = \(getAction())")
    }

    //-----
    @objc
    func onPan(sender:UIPanGestureRecognizer) -> Void {
        self.preExec(sender)
        //own?.onPan(sender, self)

        wqe("\(FLStringKit.now()!) : onPan \(sender)")
        var at = sender.numberOfTouches
        let pi = sender.location(in: sender.view)
        print("#\(at), pi = \(pi)")
        for i in 0..<sender.numberOfTouches {
            let p = sender.location(ofTouch: i, in: sender.view)
            print("touches : #\(i) : \(p.f2())")
        }
    }

    private func preExec(_ sender:UIPanGestureRecognizer) {
        if (me == nil) {
            me = sender
        }
        self.peek(sender)
    }

    private func peek(_ sender:UIPanGestureRecognizer) {
        let now = Event.from(sender)
        if (now.state == .began) {
            thiz = nil
        }
        prev = thiz
        thiz = now
        //wqe("prev = \(prev), thiz = \(thiz), action = \(getAction())")
    }

    // returns the point for index at, if at >= n, it returns the n-1 one
    public func point(_ at:Int) -> CGPoint {
        if let me = me {
            let n = me.numberOfTouches
            let p = makeInBound(at, 0, n - 1)
            return me.location(ofTouch: p, in: me.view)
        }
        return CGPoint.zero
    }

    public func getAction() -> MotionEvent {
        guard let prev = prev else { return .down } // unhandled multiple touch in and move (1, 2, 3) down + 3 move
        guard let thiz = thiz else { return .possible } // unhandled

        let now = thiz.state
        if (now == .changed) {
            let pp = prev.pointer
            let zp = thiz.pointer
            if (pp > zp) {
                return pp > 1 ? .pointerUp : .up
            } else if (pp < zp) {
                return zp > 1 ? .pointerDown : .down
            } else {
                // same count
                return .move
            }
        } else if (now == .ended) {
            return .up
        } else if (now == .cancelled) {
            return .cancel
        } else if (now == .failed) {
            return .cancel
        }
        return .possible
    }

    //func targetBy(_ v : UIView?) -> UIPanGestureRecognizer? {
    func targetBy(_ v : UIView?) -> UIGestureRecognizer? {
        guard let v = v else { return nil }
        var s : Selector? = nil;
        s = #selector(Self.onPan)
        let p = UIPanGestureRecognizer.init(target: self, action:s)
        //v.addGestureRecognizer(p)
        //let g = UIGestureRecognizer.init(target: self, action:#selector(Self.onPan2))
        let g = UIGestureRecognizer.init(target: self, action:#selector(Self.onPan2))
        g.delegate = self
        //v.addGestureRecognizer(g)
        //let fg = FLG.init(target: self, action: #selector(Self.onPan2))
        //let fg = FLGestureRecognizer.init(target: self, action: #selector(Self.onPan2))
        //v.addGestureRecognizer(fg)
        wqe("Ges rec = \(v.gestureRecognizers?.toString() ?? "?")")
        return p;
    }

    public class Event : NSObject {
        private let s = Array("?_~^xf")
        var pointer = 0
        var state = UIGestureRecognizer.State.possible

        public init(_ p:UIGestureRecognizer) {
            pointer = p.numberOfTouches
            state = p.state
        }

        class func from(_ p: UIGestureRecognizer) -> Event {
            return Event.init(p)
        }

        public override
        var description: String {
            return "(\(pointer), \(s[state.rawValue]))"
        }
    }

    // From UIGestureRecognizer.State
    public enum MotionEvent : Int {
        private static let z = Array("fxecbp_^~-oDU")
        // let x = UIGestureRecognizer.State
        // iOS = -x-1
        case failed    = -6
        case cancelled = -5
        case ended     = -4
        case changed   = -3
        case began     = -2
        case possible  = -1

        //Defined in Android, y >= 0
        case down        =  0
        case up          =  1
        case move        =  2
        case cancel      =  3
        case outside     = 4
        case pointerDown = 5
        case pointerUp   = 6
        // Rare used in Android

        // case hoverMove     = 7
        // case scroll        = 8
        // case hoverEnter    = 9
        // case hoverExit     = 10
        // case buttonPress   = 11
        // case buttonRelease = 12

        func abbr() -> Character {
            let x = rawValue - MotionEvent.failed.rawValue
            return MotionEvent.z[x]
        }
    }

    //--
    public func gestureRecognizerShouldBegin(_ r: UIGestureRecognizer) -> Bool {
        wqe("begin ? \(r)")
        // default yes
        return true
    }

    /*
    public func gestureRecognizer(_ r: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        print("get event?")
        print("r = \(r)")
        print("event = \(event)")
        wqe("")
        // default ?
        return true
    }
    */

    // = pointer down
    public func gestureRecognizer(_ r: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        print("get Touch?")
        print("r = \(r)")
        print("touch = \(touch)")
        wqe("")
        // default yes
        return true
    }

    public func gestureRecognizer(_ r: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        print("get Press?")
        print("r = \(r)")
        print("press = \(press)")
        wqe("")
        // default yes
        return true
    }

    public func gestureRecognizer(_ r1: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith r2: UIGestureRecognizer) -> Bool {
        print("get multi, also for r2?")
        print("r1 = \(r1)")
        print("r2 = \(r2)")
        // default false
        return false
    }

    public func gestureRecognizer(_ r1: UIGestureRecognizer, shouldBeRequiredToFailBy r2: UIGestureRecognizer) -> Bool {
        print("get multi, asked fail by r2?")
        print("r1 = \(r1)")
        print("r2 = \(r2)")
        // default false
        return false
    }

    public func gestureRecognizer(_ r1: UIGestureRecognizer, shouldRequireFailureOf r2: UIGestureRecognizer) -> Bool {
        print("get multi, ask failure of r2?")
        print("r1 = \(r1)")
        print("r2 = \(r2)")
        // default false
        return false
    }
}

// for pan
//protocol UIViewPanOwner {
//    func setupAction(on con:FLPanInfo?) -> Void;
//}
//
//protocol FLPanOwner {
//    func getPanInfo() -> FLPanInfo?;
//}
//
//protocol FLPanListener {
//    func onPan(_ sender:UIPanGestureRecognizer, _ info:FLPanInfo) -> Void
//}
//
//extension FLPanListener {
//    func onPan(_ sender:UIPanGestureRecognizer, _ info:FLPanInfo) -> Void { wqe("") }
//}

//fileprivate func a(_ t:Set<UITouch>, _ e: UIEvent?) {
fileprivate func a(_ t:Set<NSObject>, _ e: UIEvent?) {
    print("e = \(e)")
    let n = t.count
    var i = 0
    for x in t {
        print("#\(i) = \(x)")
        i++
    }
}


class FLView : UIView {
    
    private func seeNexts() {
        //--
        var now = self.next
        var x = 0;
        print("----")
        while (now != nil) {
            print("#\(x) : now next = \(now)");
            x += 1
            now = now?.next
        }
        print("----")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("_ down") // next = parent, so we can passing to parent?
        print("_ self = \(self)")
        print("_ next = \(self.next)")
        a(touches, event)
        wqe("")

        
        //-- send to next
        print("going send to nextUIR");
        if (self.next != nil) {
            print("send to nextUIR GO");
            self.next?.touchesBegan(touches, with: event)
            print("send to nextUIR OK me = \(self)");
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("~ move")
        a(touches, event)
        wqe("")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("^ up")
        a(touches, event)
        wqe("")
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("X_X cancel")
        a(touches, event)
        wqe("")
    }
}
