//
// Created by Eric Chen on 2021/4/11.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

//class FLUIViews {
//}


extension UIView {
    func requestLayout() {
        req()
        invalidate()
    }

    func invalidate() {
        inv()
    }

    private func req() {
        var vs = self.subviews
        vs.append(self)
        for v in vs {
            v.setNeedsLayout()
        }
    }

    private func inv() {
        var vs = self.subviews
        vs.append(self)
        for v in vs {
            v.setNeedsDisplay()
        }
    }

    func disableTouch() {
        if let vs = self.allSubviews() {
            for v in vs {
                v.isUserInteractionEnabled = false
            }
        }
        self.isUserInteractionEnabled = false
    }
}
