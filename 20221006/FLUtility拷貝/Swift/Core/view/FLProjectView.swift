//
// Created by Eric Chen on 2021/4/11.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

// View that draws same content as source view, just source view's projector
class FLProjectView : UIView {
    private var sourceView : UIView?
    private var clk = FLTicTac()
    private var log = 0 > 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        clk.enable = log
        clk.log = false
    }

    func setSourceView(_ v:UIView?) {
        sourceView = v
    }

    func getSourceView() -> UIView? {
        return sourceView
    }

//    override func layoutSubviews() {
//        super.layoutSubviews()
//    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //clk.tic()
        let c = UIGraphicsGetCurrentContext()
        if let c = c {
            //clk.tic()
            c.clear(rect) // < 1ms
            //clk.tacS("clear")
            if let v = sourceView {
                let f = self.frame
                let sz = CGRect(x: 0, y: 0, width: f.width, height: f.height)
                // ~= 5ms if it is 5x
                var impl = 0
                // ok if drawHierarchy // ng when v.layer.render(in: c)
                // ok if drawHierarchy // ok when v.layer.render(in: c)
                if (impl == 1) {
                    //clk.tic()
                    v.layer.render(in: c)
                    //clk.tacS("v.layer.render(in: c)")
                } else {
                    //clk.tic()
                    let b = v.drawHierarchy(in: sz, afterScreenUpdates: false) // ok
                    // [Snapshotting] View (0x10d726260, GPUImageView) drawing with afterScreenUpdates:YES inside CoreAnimation commit is not supported.
                    //let b = v.drawHierarchy(in: sz, afterScreenUpdates: true) // not for gpuimageview
                    //clk.tacS("v.drawHierarchy = \(b) in \(sz)")
                }
            }
        }
        //clk.tacS("draw OK")
        //wqe("")
    }

    deinit {
        wqe("deinit src = \(sourceView)")
        sourceView = nil
    }
}