//
// Created by Eric Chen on 2021/2/17.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class FLUIStyles {
    class func applyShadow(_ view : UIView?, _ color:String = "#000", _ radius:CGFloat = 3) -> Void {
        guard let v = view else { return }
        v.layer.shadowColor = UIColor.init(hex: color).cgColor
        v.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = radius
    }

    class func applyBorder(_ view:UIView?, _ color:String = "#0000", _ width:CGFloat = 1) {
        guard let v = view else { return }
        v.layer.borderColor = UIColor.init(hex: color).cgColor
        v.layer.borderWidth = width
    }

    // Not update as frame...
    class func applyDashBorder(_ view : UIView?, _ color:String = "#000", _ lineWidth:CGFloat = 2, _ lineDashPattern:[NSNumber] = [3, 5]) -> CAShapeLayer? {
        let d = Self.createDashBorder(view, color, lineWidth, lineDashPattern)
        if let v = view, let d = d {
            v.layer.addSublayer(d)
        }
        return d
    }

    class func createDashBorder(_ view : UIView?, _ color:String = "#000", _ lineWidth:CGFloat = 2, _ lineDashPattern:[NSNumber] = [3, 5]) -> CAShapeLayer? {
        guard let v = view else { return nil }
        let cr = v.layer.cornerRadius
        var d = CAShapeLayer()
        let fr = v.bounds
        d.frame = fr
        d.fillColor = nil
        d.lineWidth = lineWidth
        d.strokeColor = UIColor.init(hex: color).cgColor
        d.lineDashPattern = lineDashPattern
        if (cr > 0) {
            d.path = UIBezierPath(roundedRect: fr, cornerRadius: cr).cgPath
        } else {
            d.path = UIBezierPath(rect: fr).cgPath
        }
        return d
    }

    class func applyConsole(_ view:UITextView?) {
        guard let v = view else { return }
        v.noPadding()
        v.textContainerInset = UIEdgeInsets.init(3)
        v.backgroundColor = UIColor.init(hex: "#8000")
        v.textColor = UIColor.init(hex: "#080")
        v.font = UIFont.systemFont(ofSize: 10)
        v.isEditable = false
        v.isSelectable = true
        v.showsVerticalScrollIndicator = true
        v.dataDetectorTypes = .all
        FLUIStyles.applyBorder(v, "#4FFF", 1)
    }
}
