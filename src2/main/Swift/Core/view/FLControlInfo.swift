//
// Created by Eric Chen on 2021/1/19.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

public class FLControlInfo: NSObject {
    weak var own : FLUIListener? = nil

    @objc
    func onClick(sender:UIControl) -> Void {
        own?.onClick(sender: sender)
    }

    @objc
    func onTouchCancel(sender:UIControl) -> Void {
        own?.onTouchCancel(sender: sender)
    }

    @objc
    func onTouchUp(sender:UIControl) -> Void {
        own?.onTouchUp(sender: sender)
    }

    @objc
    func onTouchDown(sender:UIControl) -> Void {
        own?.onTouchDown(sender: sender)
    }

    @objc
    func onValueChanged(sender:UIControl) -> Void {
        own?.onValueChanged(sender: sender)
    }

    func targetBy(_ v : UIControl?, for event: UIControl.Event) {
        guard let v = v else { return }
        var s : Selector? = nil;
        switch (event) {
        case .touchDown: s = #selector(FLControlInfo.onTouchDown)
        case .touchUpInside: s = #selector(FLControlInfo.onClick)
        case .touchUpOutside: s = #selector(FLControlInfo.onTouchCancel)
        case .valueChanged: s = #selector(FLControlInfo.onValueChanged)
        default: break
        }
        if (s != nil) {
            v.addTarget(self, action:s!, for: event)
        } else {
            wqe("Did not add for event \(event)")
        }
    }
}

protocol FLUIControlOwner : NSObjectProtocol {
    func getControl() -> FLControlInfo?;
}

protocol UIViewOwner : NSObjectProtocol {
    func setupAction(on con:FLControlInfo?) -> Void;
}

// Receive control's event
protocol FLUIListener : NSObjectProtocol {
    func onClick       (sender:UIControl) -> Void;
    func onTouchCancel (sender:UIControl) -> Void;
    func onTouchUp     (sender:UIControl) -> Void;
    func onTouchDown   (sender:UIControl) -> Void;
    func onValueChanged(sender:UIControl) -> Void;
}

// For default implementation like Java syntax
// public Listener { default void click() {} }
extension FLUIListener {
    func onClick       (sender:UIControl) -> Void { wqe("") }
    func onTouchCancel (sender:UIControl) -> Void { wqe("") }
    func onTouchUp     (sender:UIControl) -> Void { wqe("") }
    func onTouchDown   (sender:UIControl) -> Void { wqe("") }
    func onValueChanged(sender:UIControl) -> Void { wqe("") }
}
