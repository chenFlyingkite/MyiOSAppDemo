//
// Created by Eric Chen on 2021/1/21.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class FLGPUImageKit : NSObject {
    // Edge of u to v with weight w,
    // Visualize : u --(w)--> v
    class Edge : Equatable {
        var u = ""
        var v = ""
        var w = 0
        init(_ head: String, _ tail: String, _ weight: Int) {
            u = head;
            v = tail;
            w = weight;
        }

        func description() -> String {
            return u + " --(" + String(w) + ")--> " + v
        }

        static func == (lhs: FLGPUImageKit.Edge, rhs: FLGPUImageKit.Edge) -> Bool {
            if (lhs.u != rhs.u) { return false }
            if (lhs.v != rhs.v) { return false }
            if (lhs.w != rhs.w) { return false }
            return true;
        }
    }

    //--- Basic getters
    func getAllSource() -> [String:GPUImagePicture] {
        return source
    }

    func sourceOf(_ name:String) -> GPUImagePicture? {
        return source[name] ?? nil
    }

    func getAllFilter() -> [String:GPUImageFilter] {
        return filter
    }

    func filterOf(_ name:String) -> GPUImageFilter? {
        return filter[name] ?? nil
    }

    func getAllTarget() -> [String:Array<Edge>] {
        return target
    }

    func getAllDisplayEdge() -> [String:Array<Edge>] {
        return displayEdge
    }

    func getAllDisplay() -> [String:GPUImageView] {
        return display
    }

    func displayOf(_ name:String) -> GPUImageView? {
        return display[name] ?? nil
    }
    //----


    // Map
    private var sourceUIImage = [String:UIImage]() // vertex of source
    private var source = [String:GPUImagePicture]() // vertex of source
    // Map
    private var filter = [String:GPUImageFilter]() // vertex
    //private var filter = [String:GPUImageOutput]() // vertex
    // Map
    // u : [(u, v, w), ...]
    private var target = [String:Array<Edge>]() // edge
    private var displayEdge = [String:Array<Edge>]() // vertex of display
    private var display = [String:GPUImageView]() // vertex of display

    // debug used
    private let clk = FLTicTac()

    override init() {
        super.init()
        clk.enable = false;
    }

    // @interface GPUImagePicture : GPUImageOutput
    // @interface GPUImageFilter : GPUImageOutput <GPUImageInput>
    // TODO rebuild source cost time
    @discardableResult
    func source(name: String, image: UIImage) -> Self {
        sourceUIImage[name] = image
        clk.tic()
        let gip = GPUImagePicture.init(image: image)
        clk.tacS("source[\(name)] = \(image.size.wxh()), \(gip), ")
        source[name] = gip
        return self
    }

    func hasSource(_ name:String) -> Bool {
        return hasSources([name])
    }

    func hasSources(_ name:[String]) -> Bool {
        for x in name {
            if (source[x] == nil) {
                return false
            }
        }
        return true
    }

    @discardableResult
    func filter(name: String, given: GPUImageFilter) -> Self {
        filter[name] = given
        return self
    }

    @discardableResult
    func target(from: String, to: String, at:Int = 0) -> Self {
        let e = Edge.init(from, to, at)
        if (target[from] == nil) {
            target[from] = [e]
        } else {
            let exist = target[from]?.contains(e) ?? false
            if (!exist) {
                target[from]!.append(e)
            }
        }
        return self
    }

    @discardableResult
    func targetList(_ order:[String]) -> Self {
        let n = order.count
        let at = 0
        for i in 1..<n {
            self.target(from: order[i-1], to: order[i], at: at)
        }
        return self
    }

    @discardableResult
    func display(from:String, into:GPUImageView, name:String) -> Self {
        //wqe("set display \(from) -> \(into)")
        let e = Edge.init(from, name, 0)
        if (displayEdge[from] == nil) {
            displayEdge[from] = [e]
        } else {
            let exist = displayEdge[from]?.contains(e) ?? false
            if (!exist) {
                displayEdge[from]!.append(e)
            }
        }
        display[name] = into
        return self;
    }

    private func clearLinks() {
        // GPUImageOutputs
        clk.tic()
        clk.tic()
        for x in source.values {
            x.removeAllTargets()
        }
        clk.tacS("clears source")
        clk.tic()
        for x in filter.values {
            x.removeAllTargets()
        }
        clk.tacS("clears filter")
        clk.tacS("clear links")
    }

    func build() {
        //clearLinks()
        clk.tic()
        var z = 0
        var msg = ""
        for k in target.keys {
            let edgeK:[Edge] = target[k]!
            var x = getOutput(k) // GPUImageOutput?
            if let x = x { // if x != nil, x = x
                for i in 0..<edgeK.count {
                    let ei = edgeK[i]
                    let eiv = ei.v
                    let at = ei.w
                    // x = named as ei.u,
                    if let y = filter[eiv] {
                        z++
                        //clk.tic()
                        x.addTarget(y, atTextureLocation:at)
                        //clk.tacS("addTarget: \(ei.description())")
                        msg += "\(ei.description()), "
                    }
                }
            }
        }
        clk.tacS("\(z) target are added : \(msg)")
        z = 0
        clk.tic()
        msg = ""
        for k in displayEdge.keys {
            let edgeK:[Edge] = displayEdge[k]!
            var x = getOutput(k) // GPUImageFilter
            if let x = x {
                for i in 0..<edgeK.count {
                    let ei = edgeK[i]
                    let eiv = ei.v
                    //let at = ei.w
                    // x = named as ei.u,
                    if let view = getDisplay(eiv) { // GPUImageView
                        z++
                        //clk.tic()
                        x.addTarget(view)
                        //clk.tacS("addTarget: \(ei.description())")
                        msg += "\(ei.description())"
                    }
                }
            }

        }
        clk.tacS("\(z) Display are attached \(msg)")
    }

    func reset() {
        clearLinks()
        source.removeAll()
        sourceUIImage.removeAll()
        filter.removeAll()
        target.removeAll()
        resetDisplay()
        clk.reset()
    }

    func resetDisplay() {
        displayEdge.removeAll()
        display.removeAll()
    }

    func getImage(_ key:String) -> UIImage? {
        print("getImage(\(key))")
        if (source[key] != nil) {
            return sourceUIImage[key]
        } else if (filter[key] != nil) {
            return getFilterImage(filter[key]!)
        } else {
            return nil
        }
    }

    func processSource() {
        clk.tic()
        for k in source.keys {
            let x = source[k]
            //clk.tic()
            x!.processImage()
            //clk.tacS("process source \(k) -> \(x)")
        }
        clk.tacS("process all source")
    }

    // TODO
//    func processSource(_ com:OnCon) {
//        clk.tic()
//        com.onBegin()
//        for x in source.values {
//            clk.tic()
//            //com.onBeginAt(<#T##at: Int##Swift.Int#>)
//            x.processImage(completionHandler: {
//                wqe("x is OK \(x)")
//                //com.onEndAt(<#T##at: Int##Swift.Int#>)
//            })
//            clk.tacS("\(x) . processImage")
//        }
//        com.onEnd()
//        clk.tacS("images all ready")
//    }

    private func getFilterImage(_ out: GPUImageFilter) -> UIImage? {
        clk.tic()
        out.useNextFrameForImageCapture()
        clk.tacS(" key.useNextFrame")
        clk.tic()
        let ans = out.imageFromCurrentFramebuffer()
        clk.tacS(" out.imageFB as \(ans)")
        return ans
    }

    private func getDisplay(_ name:String) -> GPUImageView? {
        return display[name] ?? nil
    }

    private func getInput(_ name:String) -> GPUImageInput? {
        return filter[name] ?? display[name] ?? nil
    }

    private func getOutput(_ name:String) -> GPUImageOutput? {
        return source[name] ?? filter[name] ?? nil
    }

    private func noOutput(_ s:String) -> Bool {
        return getOutput(s) == nil;
    }

    func seeTargets() -> Void {
        for k in source.keys {
            let v = source[k] // GPUImagePicture
            wqe("source[\(k)].targets : ")
            s(v?.targets())
        }
        for k in filter.keys {
            let v = filter[k] // GPUImageFilter
            wqe("filter[\(k)].targets : ")
            s(v?.targets())
        }
    }

    override var description: String {
        return "source = \n  \(source)\n" +
                "filter = \n  \(filter)\n" +
                "target = \n  \(target)\n" +
                "displayE = \n  \(displayEdge)\n" +
                "display = \n  \(display)\n"
        ;
    }

    private func s(_ a: Array<Any>?) {
        let n = a?.count ?? 0
        wqe("\(n) items")
        for i in 0..<n {
            let ai = a![i]
            wqe("#\(i) = \(ai)")
        }
    }

    func visualize(_ tileSide:Int = 75, _ lineBreak:Int = 4) -> UIScrollView {
        let w = tileSide; // image demo size
        let h = 40; // label name height
        let ln = lineBreak
        let dx = w + 5;
        let dy = w + h + 5;

        let ans = UIScrollView()
        var maxR = 0.0
        var maxB = 0.0
        // adding sources

        var ks = source.keyArray()
        ks.sort()
        var n = ks.count;
        var row = 0;
        wqe("sources = \(ks.toString())")
        for i in 0..<n {
            // take key and image
            row = i / ln
            let k = ks[i]
            let img = sourceUIImage[k]
            let sx = dx * (i % ln);
            let sy = dy * row;

            // eval rect
            let r = CGRect.init(x: sx, y: sy, width: w, height: w)
            let v = UIImageView.init(frame: r)
            v.contentMode = .scaleAspectFit
            v.layer.borderColor = UIColor.red.cgColor
            v.layer.borderWidth = 1

            let tr = CGRect.init(x: sx, y: sy + Int(r.height), width: w, height: h)
            let t = UILabel.init(frame: tr)
            t.backgroundColor = UIColor.init(hex: "#4000")
            t.textAlignment = .center
            t.textColor = UIColor.init(hex: "#FFF")
            t.adjustsFontSizeToFitWidth = true
            //t.font = UIFont.systemFont(ofSize: 12)
            t.numberOfLines = 4
            t.text = (img?.size.wxh() ?? "-x-") + "\n" + k

            v.image = img
            // add to scrollview
            ans.addSubview(v)
            ans.addSubview(t)
            maxR = max(maxR, r.right)
            maxB = max(maxB, tr.bottom)
        }
        row = Int(ceil(1.0 * n / ln))
        // adding filters
        ks = filter.keyArray()
        ks.sort()
        wqe("filters = \(ks.toString())")
        n = ks.count
        for i in 0..<n {
            let k = ks[i]
            let rn = row + i / ln
            let sx = dx * (i % ln);
            let sy = dy * rn;
            let f = filter[k]
            if let f = f {
                let r = CGRect.init(x: sx, y: sy, width: w, height: w)
                let v = GPUImageView.init(frame: r)
                v.contentMode = .scaleAspectFit
                v.layer.borderColor = UIColor.green.cgColor
                v.layer.borderWidth = 1

                let tr = CGRect.init(x: sx, y:sy + Int(r.height), width: w, height: h)
                let t = UILabel.init(frame: tr)
                t.backgroundColor = UIColor.init(hex: "#4000")
                t.textColor = UIColor.init(hex: "#FFF")
                t.textAlignment = .center
                t.adjustsFontSizeToFitWidth = true
                //t.font = UIFont.systemFont(ofSize: 12)
                t.numberOfLines = 4

                t.text = f.outputFrameSize().wxh() + "\n" + k

                f.addTarget(v)

                ans.addSubview(v)
                ans.addSubview(t)
                maxR = max(maxR, r.right)
                maxB = max(maxB, tr.bottom)
            }
        }
        processSource()
        ans.contentSize = CGSize.init(width: maxR, height: maxB)

        ans.backgroundColor = UIColor.init(hex: "#4fff");
        return ans;
    }
}
