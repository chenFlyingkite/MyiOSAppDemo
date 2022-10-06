//
// Created by Eric Chen on 2021/3/5.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class BoardFn : UIScrollView, UIViewOwner {
    let track = UIView()
    let keyFN:[FLImageView] = [FLImageView(),
        FLImageView(), FLImageView(), FLImageView(), FLImageView(),
        FLImageView(), FLImageView(), FLImageView(), FLImageView(),
        FLImageView(), FLImageView(), FLImageView(), FLImageView(),
    ]
    private let itemSize = CGSize(width: 40, height: 40)

    override
    init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required
    init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: UI Layouts
    private func setup() -> Void {
        setupRes()
        setupViewTree()
        setupConstraint()
        setupAction()
    }

    private func setupRes() {
        var n = keyFN.count
        for i in 0..<n {
            let v = keyFN[i]
            let isEsc = i == 0
            var fi = FLRes.all("F" + String(i));
            var fbg = FLRes.normal("#888", disable: "#222", pressed: "#444", selected: "#008")
            if (isEsc) {
                fi = FLRes.all("ESC");
                fbg = FLRes.normal("#444", disable: "#000", pressed: "#222", selected: "#004")
            }
            fi?.applyTitle(to: v)
            v.titleLabel?.textColor = UIColor.init(hex: "#F00")
            v.titleLabel?.textAlignment = .center
            v.bgColors = fbg
            v.bdColors = FLRes.all("#ddd")
            v.layer.borderWidth = 0.5
        }
    }

    private func setupViewTree() {
        let v:[Any] = [track, keyFN]
        FLSUIKits.addView(root: self, child: v)
    }

    func getMeasuredSize() -> CGSize {
        let z = itemSize
        let w = z.width.lf()
        let h = z.height.lf()
        var n = keyFN.count
        return CGSize(width: n * w, height: h)
    }

    private func setupConstraint() {
        let z = itemSize
        let w = z.width.lf()
        let h = z.height.lf()
        let zz = getMeasuredSize()
        let parent = self
        self.contentSize = zz

        var a:[Any?] = [
            FLLayouts.view(track, layout: keyFN, axis: .leftToRight),
            FLLayouts.view(track, width: zz.width.lf(), height: zz.height.lf()),
        ]
        let n = keyFN.count
        var b:[Any?] = []
        for i in 0..<n {
            let v = keyFN[i]
            b = [
                FLLayouts.view(v, width: w, height: h),
            ]
            a.append(b)
        }
        FLLayouts.activate(parent, forConstraint: a)
    }

    private func setupAction() {

    }

    func setupAction(on con: FLControlInfo? = nil) -> Void {
        guard let con = con else { return }

        let vs = keyFN
        for v in vs {
            con.targetBy(v, for: .touchUpInside)
        }
    }

}
