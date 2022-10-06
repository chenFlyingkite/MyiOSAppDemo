//
// Created by Eric Chen on 2021/2/10.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

protocol FL2DTransformListener : NSObjectProtocol {
    func onDown(_ e:MotionEvent) -> Void
    func onPointerDown(_ e:MotionEvent) -> Void
    func onUp(_ e:MotionEvent) -> Void
    func onPointerUp(_ e:MotionEvent) -> Void
    func onMove(_ e:MotionEvent) -> Void
    func onCancelled(_ e: MotionEvent) -> Void

    func onPan(_ moved:PointF, _ e:MotionEvent) -> Void
    func onZoom(_ scale:Double, _ e:MotionEvent) -> Void
    func onRotate(_ degree:Double, _ e:MotionEvent) -> Void
}

extension FL2DTransformListener {
    func onDown(_ e:MotionEvent) { }
    func onPointerDown(_ e: MotionEvent) { }
    func onUp(_ e: MotionEvent) { }
    func onPointerUp(_ e: MotionEvent) { }
    func onMove(_ e: MotionEvent) { }
    func onCancelled(_ e: MotionEvent) { }

    func onPan(_ moved: PointF, _ e: MotionEvent) { }
    func onZoom(_ scale: Double, _ e: MotionEvent) { }
    func onRotate(_ degree: Double, _ e: MotionEvent) { }
}
