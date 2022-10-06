//
// Created by Eric Chen on 2021/3/4.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class FLSViewController : UIViewController, FLUIListener {

    // debug
    private let logLife = true
    private let clk = FLTicTac.init()

    private let gpuKit = FLGPUImageKit.init()
    private let content = UIView()

    // click
    private let act = FLControlInfo()

    // MARK: Init, Present view controller

    // From here
    required
    init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    required override
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @objc
    class func presentMe(src : UIViewController, args:FLStoryboardInfo = .init()) {
        let file = "LightHitStoryboard"
        let id = "FLSViewController"
        let sid = id + "_segue"
        //var vc = Self.init(nibName: nil, bundle: nil)
        //var vc = super.init(nibName: nil, bundle: .main)
        var vc = Self.init(nibName: nil, bundle: nil)
        //FLStoryboards.go(storyboardFileName: file, viewControllerId: id, source:src, args)
        let segue = UIStoryboardSegue.init(identifier: sid, source: src, destination: vc, performHandler: args.performHandler);
        args.segue = segue
        args.didSetSegue(segue)
        args.willPerformSegue(segue)

        //src.prepare(for: segue, sender: sender)
        segue.perform()

    }

    // Set status bar as light mode
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return UIRectEdge.all
    }

    // MARK: Life cycle
    override
    func viewDidLoad() {
        super.viewDidLoad()
        if (logLife) {
            self.view.logChild()
            wqe("")
        }
        //contentView.backgroundColor = UIColor.init(hex: "#000")

        makeUI()
        makeEngine()
//        provideData();
//        defaultParam();
//        startEngine();
//        setupUndo();
//        setupIAP();
    }

    override
    func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (logLife) {
            self.view.logChild()
            wqe("");
        }
//        if (dismissWhenViewWillAppear) {
//            wqe("called finish")
//            self.finish()
//        }
    }

    // Frequently called, consider less code
    override
    func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if (logLife) {
            self.view.logChild()
            wqe("");
        }
    }

    // Frequently called, consider less code
    override
    func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (logLife) {
            wqe("");
        }
    }

    override
    func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (logLife) {
            self.view.logChild()
            wqe("")
        }
        vis()
        //engine.updatePreview()
    }
    // Now user is ready to use

    override
    func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (logLife) {
            wqe("");
        }
    }

    override
    func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if (logLife) {
            wqe("");
        }
        //trimMemory()
    }

    func onDestroy() {
//        trimMemory()
//        engine.destroy()
//        wqe("")
    }

    // MARK: UI
    private let ui = FLSDevMainUI()
    private func makeUI() {
        setup()
        act.own = self
        ui.inflate(self.content)
        ui.keyFN.setupAction(on: act)

    }

    private func setup() -> Void {
        setupRes()
        setupViewTree()
        setupConstraint()
        setupAction()
    }

    private func setupViewTree() {
        let safe = self.view
        let t = [content]
        FLLayouts.addView(to: safe, child: t)
    }

    private func setupRes() {
    }

    private func setupAction() {
    }
//
//    private func takeSafe() {
//        let safe = self.view
//        let take = self.content
//        self.view.layoutGuides[0]
//
//        self.additionalSafeAreaInsets = safe?.safeAreaInsets ?? UIEdgeInsets.init(0)
//    }

    private func setupConstraint() {
        let parent = self.view
        let main = content
        var a:[Any?] = [
            //FLLayouts.view(content, sameTo: parent),
            //content.leftAnchor.constraint(equalTo: parent?.safeAreaLayoutGuide)
        ]
        if let g = parent?.safeAreaLayoutGuide {
            a += [
                main.leftAnchor.constraint(equalTo: g.leftAnchor),
                main.topAnchor .constraint(equalTo: g.topAnchor),
                main.rightAnchor.constraint(equalTo: g.rightAnchor),
                main.bottomAnchor.constraint(equalTo: g.bottomAnchor),
            ]
        }
        FLLayouts.activate(parent, forConstraint: a)
    }


    // MARK: engine
    private func makeEngine() {
        let s = "LightHit/Sky/1/"
        let f1 = UIImage.init(named: s + "f.png")
        let b1 = UIImage.init(named: s + "b.png")
        let u1 = UIImage.init(named: s + "u.png")
        gpuKit
        .source(name: "f1", image: f1!)
        .source(name: "b1", image: b1!)
        .source(name: "u1", image: u1!)
        .build()

        //gpukit.source(name: "", image: <#T##UIImage##UIKit.UIImage#>)
    }

    private func vis(_ show:Bool = true) {
        let part = ui.demo
        part.removeAllSubviews()
        if (show) {
            let sc = gpuKit.visualize()
            sc.frame = CGRect.init(x: 0, y: 0, width: 300, height: 200)
            part.addSubview(sc)
        }
    }

    //----

    func onClick       (sender:UIControl) -> Void {
        let s = sender
        let fns = ui.keyFN.keyFN
        if (s == fns[0]) {
            dismiss(animated: true)
        } else if (s == fns[1]) {
            vis()
        } else if (s == fns[2]) {
            vis(false)
        }

    }

    func onTouchCancel (sender:UIControl) -> Void {

    }

    func onTouchUp     (sender:UIControl) -> Void {

    }

    func onTouchDown   (sender:UIControl) -> Void {

    }

    func onValueChanged(sender:UIControl) -> Void {

    }
}
