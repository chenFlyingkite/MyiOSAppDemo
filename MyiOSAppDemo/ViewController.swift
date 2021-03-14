//
//  ViewController.swift
//  MyiOSAppDemo
//
//  Created by Eric Chen on 2021/3/6.
//
//

import UIKit


// https://support.apple.com/zh-tw/HT204460
// https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_objective-c_into_swift
// https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_swift_into_objective-c


class ViewController : UIViewController {
    //@objcMembers // @objcMembers may only be used on 'class' declarations
    @objc
    static let vc = 0

    @objc
    static func gvc() -> Int {
        return 0
    }

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        var d1:Double = 3.3
        d1.roundedInt()
        var f1: Float = 2.5
        f1.roundedInt()
        // Do any additional setup after loading the view.
        print("viewDidLoad")
        let x = ASD.init()
        print("ASD.init() OK")
    }
    
    
    override func viewWillLayoutSubviews() {
        
    }
    override func viewDidLayoutSubviews() {
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    // MARK: UI Layouts
    private func setup() -> Void {
        setupRes()
        setupViewTree()
        setupConstraint()
        setupAction()

    }
    
    private func setupRes() {
        
    }
    
    private func setupViewTree() {
        
    }
    
    private func setupConstraint() {
        
    }
    
    private func setupAction() {
        
    }

}
