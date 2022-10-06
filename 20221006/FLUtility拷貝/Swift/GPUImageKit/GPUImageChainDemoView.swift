//
// Created by Eric Chen on 2021/4/4.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class GPUImageChainDemoView : UIScrollView, UIScrollViewDelegate {
    // only parent in ScrollView
    private let root = UIView()

    var log = false

    private func reset() {
        root.removeAllSubviews()
    }

    // init method
    func visualize(_ gpuKit:FLGPUImageKit, _ tileSide:Int = 75, _ lineBreak:Int = 4) -> Self {
        reset()
        // 1. Build configs
        let w = tileSide; // image demo size
        let h = 40; // label name height
        let ln = lineBreak
        // margin x & margin y
        let mgx = 5
        let mgy = 5
        // each tile place
        let dx = w + mgx;
        let dy = w + h + mgy;

        //
        let ret = self
        let ans = root
        var maxR = 0.0
        var maxB = 0.0

        let source = gpuKit.getAllSource()
        let sourceUIImage = gpuKit.getAllSourceUIImage()
        let filter = gpuKit.getAllFilter()

        // 1. Add sources demo
        var ks = source.keyArray()
        ks.sort()
        var n = ks.count;
        var row = 0
        if (log) {
            wqe("sources = \(ks.toString())")
        }
        for i in 0..<n {
            // take key, image of source
            // let i = row * ln + col
            row = i / ln
            let col = i % ln
            let k = ks[i]
            let img = sourceUIImage[k]
            let sx = dx * col;
            let sy = dy * row;

            // Build source demo
            // - Image
            let r = CGRect.init(x: sx, y: sy, width: w, height: w)
            let v = UIImageView.init(frame: r)
            baseView(v)
            v.image = img

            // - Label
            let tr = CGRect.init(x: sx, y: sy + Int(r.height), width: w, height: h)
            let t = UILabel.init(frame: tr)
            baseText(t)
            var txt = (img?.size.wxh() ?? "-x-") + "\n" + k
            if let msg = gpuKit.messageOf(k) {
                txt += "\n" + msg
            }
            t.text = txt

            // add to scrollview
            ans.addSubview(v)
            ans.addSubview(t)
            maxR = max(maxR, r.right)
            maxB = max(maxB, tr.bottom)
        }

        row = Int(ceil(1.0 * n / ln))
        // 2. add filter demo
        ks = filter.keyArray()
        ks.sort()
        if (log) {
            wqe("filters = \(ks.toString())")
        }
        n = ks.count
        for i in 0..<n {
            let rkn = i / ln
            let cn = i % ln
            let k = ks[i]
            let rn = row + rkn
            let sx = dx * cn;
            let sy = dy * rn;
            let f = filter[k]
            if let f = f {
                let r = CGRect.init(x: sx, y: sy, width: w, height: w)
                let v = GPUImageView.init(frame: r)
                baseView(v, UIColor.green)
                f.addTarget(v)

                let tr = CGRect.init(x: sx, y:sy + Int(r.height), width: w, height: h)
                let t = UILabel.init(frame: tr)
                baseText(t)

                t.text = f.outputFrameSize().wxh() + "\n" + k

                // add to scroll view
                ans.addSubview(v)
                ans.addSubview(t)
                maxR = max(maxR, r.right)
                maxB = max(maxB, tr.bottom)
            }
        }
        // addStatusBar
        let addBar = true
        if (addBar) {
            let r = CGRect.init(x: 0, y: maxB + mgy, width: maxR, height: 200)
            let edges = UITextView.init(frame: r)
            let s = gpuKit.seeTargets()
            edges.text = s
            edges.noPadding()
            FLUIStyles.applyBorder(edges, "#008", 1)
            edges.backgroundColor = UIColor.init(hex: "#8fff");
            edges.font = UIFont.systemFont(ofSize: 14)
            edges.isEditable = false

            ans.addSubview(edges)
            maxR = max(maxR, r.right)
            maxB = max(maxB, r.bottom)
        }

        // 3. Get images
        gpuKit.processSource()

        // 4. setup demo
        ans.backgroundColor = UIColor.init(hex: "#4fff");
        ret.addSubview(ans)
        let sz = CGSize(width: maxR, height: maxB)
        ans.frame = CGRect(x: 0, y:0, width: sz.width, height: sz.height);
        ret.contentSize = sz
        // zoom delegate
        ret.delegate = self
        ret.minimumZoomScale = 0.2
        ret.maximumZoomScale = 10.0
        ret.zoomScale = 1
        return self
    }

    // -- UIScrollViewDelegate
    var allowZoom = true
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return allowZoom ? root : nil
    }

    // -- Internal methods
    private func baseView(_ v:UIView, _ c:UIColor = .red, _ bw:Double = 1) {
        v.contentMode = .scaleAspectFit
        v.layer.borderColor = c.cgColor
        v.layer.borderWidth = CGFloat(bw)
    }

    private func baseText(_ t:UILabel, _ bgc:UIColor = .init(hex: "#4000"), _ txtc:UIColor = .init(hex:"#FFF")) {
        t.backgroundColor = bgc
        t.textAlignment = .center
        t.textColor = txtc
        t.adjustsFontSizeToFitWidth = true
        //t.font = UIFont.systemFont(ofSize: 12)
        t.numberOfLines = 4
    }
}
