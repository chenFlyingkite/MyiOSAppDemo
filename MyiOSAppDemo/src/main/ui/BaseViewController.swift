//
// Created by Eric Chen on 2021/3/16.
//

import Foundation
import UIKit

class BaseViewController : UIViewController {
    var logLifeCycle = true

    // Set status bar as light mode
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return UIRectEdge.all
    }

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    // MARK: UI Layouts
    func setup() -> Void {
        setupRes()
        setupViewTree()
        setupConstraint()
        setupAction()
    }

    func setupRes() {

    }

    func setupViewTree() {

    }

    func setupConstraint() {

    }

    func setupAction() {

    }
}
