//
// Created by Eric Chen on 2021/3/1.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class FLConsoleView : UIView, FLConsole {
    private let console = UITextView()
    private let scrollEnd = FLImageView()
    private let clearAll = FLImageView()
    var keepEnd = true

    override
    init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required
    init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    // MARK: UI Layouts
    private func setup() -> Void {
        setupRes()
        setupViewTree()
        setupConstraint()
        setupAction()
    }

    private func setupRes() -> Void {
        let r = FLRes.normal("#0000", disable: "#0000", pressed: "#444", selected: "#888")

        //
        FLUIStyles.applyConsole(console)
        //
        clearAll.bgColors = r
        clearAll.setTitle("X Clear", for: .normal)
        clearAll.titleLabel?.textColor = UIColor.init(hex: "#0D0")
        //
        scrollEnd.bgColors = r
        scrollEnd.setTitle("_ To End", for: .normal)
        scrollEnd.titleLabel?.textColor = UIColor.init(hex: "#0D0")
        scrollEnd.isSelected = keepEnd
    }

    private func setupViewTree() -> Void {
        let t = self.getTree()
        FLLayouts.addView(to:self, child:t)
    }

    private func getTree() -> [Any] {
        let t:[Any] = [console, scrollEnd, clearAll]
        return t
    }

    private func setupConstraint() -> Void {
        let bw = 50.0, bh = 50.0
        let parent = self
        let a:[Any?] = [
            FLLayouts.view(console, sameXTo: parent),
            FLLayouts.view(console, align: .top, to: parent),
            FLLayouts.view(console, above: clearAll),

            FLLayouts.view(clearAll, width: bw, height: bh),
            FLLayouts.view(clearAll, corner: .rightBottom, to: parent),

            FLLayouts.view(scrollEnd, width: bw, height: bh),
            FLLayouts.view(scrollEnd, align: .bottom, to: clearAll),
            FLLayouts.view(scrollEnd, toLeftOf: clearAll, offset: -10),

        ]
        FLLayouts.activate(self, forConstraint: a);
    }

    private func setupAction() -> Void {
        clearAll.addTarget(self, action: #selector(onClickClear), for: .touchUpInside)
        scrollEnd.addTarget(self, action: #selector(onClickScrollEnd), for: .touchUpInside)
    }

    @objc
    func onClickScrollEnd(_ s:UIView) {
        keepEnd = !keepEnd
        scrollEnd.isSelected = keepEnd
        checkScroll()
    }

    @objc
    func onClickClear(_ s:UIView) {
        FLSLog.clearAll()
        clearAllText()
    }

    // MARK : FLConsole
    func isKeepAtEnd() -> Bool {
        return keepEnd
    }

    func scrollToEnd() -> Void {
        console.scrollsToBottom()
    }

    func setTexts(_ s:String) {
        console.text = s
    }

    func addText(_ s:String) {
        console.text += s
    }

    func clearAllText() {
        self.setTexts("")
    }
}
