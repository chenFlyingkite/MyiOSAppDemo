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

    //--- Basic getter on fields
    func getAllSource() -> [String:GPUImagePicture] {
        return source
    }

    func getAllSourceUIImage() -> Dictionary<String, UIImage> {
        return sourceUIImage
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

    func getAllMessage() -> [String:String] {
        return message
    }

    func messageOf(_ name:String) -> String? {
        return message[name] ?? nil
    }
    //----

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
    private var message = [String:String]() // message for vertex
    private var displayEdge = [String:Array<Edge>]() // vertex of display
    private var display = [String:GPUImageView]() // vertex of display

    // debug used
    private let clk = FLTicTac()

    override init() {
        super.init()
        clk.log = false // checking performance
    }

    // @interface GPUImagePicture : GPUImageOutput
    // @interface GPUImageFilter : GPUImageOutput <GPUImageInput>
    // TODO rebuild source cost time on GPUImagePicture.init()
    @discardableResult
    func source(name: String, image: UIImage) -> Self {
        sourceUIImage[name] = image
        clk.tic()
        let gip = GPUImagePicture.init(image: image)
        //let gip = GPUImagePicture.init(image: image, smoothlyScaleOutput: false)
        //let gip = GPUImagePicture.init(image: image, smoothlyScaleOutput: true)
        clk.tacS("source[\(name)] = \(image.size.wxh()), \(gip), ")
        source[name] = gip
        return self
    }

    @discardableResult
    func filter(name: String, given: GPUImageFilter, _ render:Bool = true) -> Self {
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

    // link targets linearly
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

    @discardableResult
    func message(name: String, _ msg: String?) -> Self {
        message[name] = msg
        return self
    }

    func build() {
        var z = 0
        var msg = ""
        clk.tic()
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
        clk.tacS("\(z) targets added : \(msg)")

        z = 0
        msg = ""
        clk.tic()
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
                        msg += "\(ei.description()), "
                    }
                }
            }

        }
        clk.tacS("\(z) displays added : \(msg)")
    }

    @discardableResult
    func reset() -> Self {
        // detach targets
        freezeFilters(true)
        detachSources()
        detachFilters()
        detachDisplays()
        // remove nodes
        source.removeAll()
        filter.removeAll()
        target.removeAll()
        message.removeAll()
        display.removeAll()
        displayEdge.removeAll()
        sourceUIImage.removeAll()
        clk.reset()
        return self
    }

    private func removeAllTargets() {
        // GPUImageOutputs
        clk.tic()
        detachDisplays()
        detachFilters()
        detachSources()
        clk.tacS("clear targets")
    }

    func freezeFilters(_ noRender:Bool) -> Self {
        for x in filter.values {
            x.preventRendering = noRender
        }
        return self
    }

    // Remove links to source
    @discardableResult
    func detachSources() -> Self {
        for x in source.values {
            x.removeAllTargets()
        }
        return self
    }

    // Remove filters and display
    @discardableResult
    func detachFilters() -> Self {
        for x in filter.values {
            x.removeAllTargets()
        }
        return self
    }

    // Remove links to display
    @discardableResult
    func detachDisplays() -> Self {
        for k in display.keys {
            let view = display[k]
            getOutput(k)?.removeTarget(view)
        }
        return self
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
            clk.tic()
            x!.processImage()
            clk.tacS("process source \(k) -> \(x)")
        }
        clk.tacS("process all source")
    }

    // TODO : untested api, it may success or crashes
    func processSourceSync() {
        let ks = source.keyArray()
        let n = ks.count
        wqe("processSourceSync")
        clk.tic()
        var ok:[Bool] = Array(repeating: false, count: n)
        for i in 0..<n {
            let k = ks[i]
            let x = source[k]
            //clk.tic()
            x?.processImage(completionHandler: {
                ok[i] = true
                wqe("#\(i) OK on \(k) processImage: \(ok.toString())")
            })
            //clk.tacS("process source \(k) -> \(x)")
        }
        var allOK = false
        while (!allOK) {
            var mk = true
            for i in 0..<n {
                if (!ok[i]) {
                    mk = false
                    break
                }
            }
            //wqe("check allOK \(mk) : \(ok.toString())") // verbose
            allOK = mk
        }
        wqe("check allOK \(allOK) : \(ok.toString())") // verbose

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

    func seeTargets() -> String {
        var s = ""
        var gps = [source.keyArray(), filter.keyArray()]
        var name = ["sources", "filters"]
        var n = 0
        for i in 0..<gps.count {
            var ks = gps[i]
            n = ks.count
            ks.sort()
            s += "\(n) \(name[i]):\n"
            for j in 0..<n {
                let k = ks[j]
                s += "#\(j) : \(k)"
                if let es = target[k] {
                    s += ", (\(es.count) links)       ----> "
                    for e in es {
                        s += "\(e.v) [\(e.w)], "
                    }
                }
                s += "\n"
            }
        }
        n = target.count
        s += "\(n) links in total\n"

        var ks = displayEdge.keyArray()
        ks.sort()
        n = ks.count
        s += "\(n) displays:\n"
        for i in 0..<n {
            let k = ks[i]
            s += "#\(i) : \(k)"
            if let es = displayEdge[k] {
                s += ", (\(es.count) links)       ----> "
                for e in es {
                    s += "\(e.v), "
                }
            }
            s += "\n"
        }
        return s
    }

    override var description: String {
        return "source = \n  \(source)\n" +
                "filter = \n  \(filter)\n" +
                "target = \n  \(target)\n" +
                "displayE = \n  \(displayEdge)\n" +
                "display = \n  \(display)\n"
        ;
    }

    func visualize(_ tileSide:Int = 75, _ lineBreak:Int = 4) -> GPUImageChainDemoView {
        let demo = GPUImageChainDemoView()
        demo.visualize(self, tileSide, lineBreak)
        return demo
    }
}
//class ASD : NSObject, UIScrollViewDelegate {
//    weak var main : UIView?
//    var valid = true
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return valid ? main : nil
//    }
//}
//
//2021-04-01 00:11:59.976065+0800 photodirector[13783:8486886] global exception:Error at CVPixelBufferCreate -6661
//2021-04-01 00:11:59.976093+0800 photodirector[13783:8486886] *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Error at CVPixelBufferCreate -6661'
//*** First throw call stack:
//(0x1aa9fd86c 0x1bfa18c50 0x1aa903000 0x1abc9791c 0x1022191f0 0x1021cbd64 0x102218f64 0x102218b0c 0x1020c4b04 0x1021cbd64 0x1020c48d0 0x1020ebeb8 0x1022561d8 0x1020bd908 0x1024dd7d4 0x1aa5f024c 0x1aa5f1db0 0x1aa5f910c 0x1aa5f9c5c 0x1aa603d78 0x1f64ad814 0x1f64b476c)
//libc++abi.dylib: terminating with uncaught exception of type NSException
//Signal: SIGABRT (signal SIGABRT)
