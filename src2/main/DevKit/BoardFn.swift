//
// Created by Eric Chen on 2021/3/5.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class BoardFn : UIView, UIViewOwner {
    let keyFN:[FLImageView] = [FLImageView(),
        FLImageView(), FLImageView(), FLImageView(), FLImageView(),
        FLImageView(), FLImageView(), FLImageView(), FLImageView(),
        FLImageView(), FLImageView(), FLImageView(), FLImageView(),
    ]
    private let itemSize = CGSize.init(width: 40, height: 40)

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
            if (isEsc) {
                fi = FLRes.all("ESC");
            }
            fi?.applyTitle(to: v)
            v.titleLabel?.textColor = UIColor.init(hex: "#F00")
            v.titleLabel?.textAlignment = .center
            if (isEsc) {
                v.bgColors = FLRes.normal("#444", disable: "#000", pressed: "#222", selected: "#004")
            } else {
                v.bgColors = FLRes.normal("#888", disable: "#222", pressed: "#444", selected: "#008")
            }
            v.bdColors = FLRes.all("#ddd")
            v.layer.borderWidth = 0.5
        }
    }

    private func setupViewTree() {
        let v = keyFN
        FLSUIKits.addView(root: self, child: v)
    }

    func getMeasuredSize() -> CGSize {
        let z = itemSize
        let w = z.width.lf()
        let h = z.height.lf()
        var n = keyFN.count
        return CGSize.init(width: n * w, height: h)
    }

    private func setupConstraint() {
        let z = itemSize
        let w = z.width.lf()
        let h = z.height.lf()
        let parent = self

        var a:[Any?] = [
            FLLayouts.view(parent, layout: keyFN, axis: .leftToRight),
        ]
        let n = keyFN.count
        for i in 0..<n {
            let v = keyFN[i]
            var b:[Any?] = []

            b.append(FLLayouts.view(v, width: w, height: h))

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
