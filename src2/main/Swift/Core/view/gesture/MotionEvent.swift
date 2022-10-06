//
// Created by Eric Chen on 2021/2/10.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class MotionEvent : NSObject {
    var touches : Set<UITouch>
    var event : UIEvent

    init(_ touches: Set<UITouch>, _ event: UIEvent) {
        self.touches = touches
        self.event = event
    }

    override var description: String {
        return "e = " + event.description + "\n, t = " + touches.description
    }

    // Unused
    private enum Action : Int {
        // From UIGestureRecognizer.State
        private static let z = Array("fxecbp_^~-oDU")
        // let x = UIGestureRecognizer.State
        // iOS = -x-1
        case failed = -6
        case cancelled = -5
        case ended = -4
        case changed = -3
        case began = -2
        case possible = -1

        //Defined in Android, y >= 0
        case down = 0
        case up = 1
        case move = 2
        case cancel = 3
        case outside = 4
        case pointerDown = 5
        case pointerUp = 6
        // Rare used in Android

        // case hoverMove     = 7
        // case scroll        = 8
        // case hoverEnter    = 9
        // case hoverExit     = 10
        // case buttonPress   = 11
        // case buttonRelease = 12

        func abbr() -> Character {
            let x = rawValue - Self.failed.rawValue
            return Self.z[x]
        }
    }
}
