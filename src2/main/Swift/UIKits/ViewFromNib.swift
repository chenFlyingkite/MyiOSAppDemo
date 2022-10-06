//
// Created by Eric Chen on 2021/1/17.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

// failed
protocol ViewFromNib : NSObject {
//    static func nibName() -> String;
//    static func fromNib() -> Self;


    // MARK: Init
//    override
//    func awakeFromNib() {
//        super.awakeFromNib()
//        wqe("+awakeFromNib f  = \(frame)")
//        setup()
//    }

    // MARK: UI Layouts
//    func setup() -> Void {
//        setupRes()
//        setupViewTree()
//        setupConstraint()
//        setupAction()
//    }


    // MARK: Nib resource
    //@objc
    //class
//    func nibName () -> String {
//        return "LightHitItemsArea";
//    }
//    static func fromNib() -> Self {
//        return Bundle.main.loadNibNamed(nibName(), owner: self)?.first as! Self;
//    }

//    override func awakeFromNib() {
//
//    }
//    @objc
//    class func fromNib() -> Self {
//        return Bundle.main.loadNibNamed(nibName(), owner: self)?.first as! Self;
//    }

    func setup() -> Void;
    func setupRes() -> Void;
    func getViewTree() -> [Any];
    //func setupViewTree() -> Void;
    func getConstraints() -> [Any];
    func setupAction() -> Void;

    func addToRoot() -> Bool;
}

//extension ViewFromNib
extension ViewFromNib
{

    // ?
//    static func fromNib() -> Self {
//        return Bundle.main.loadNibNamed(nibName(), owner: self)?.first as! Self;
//    }

//
//    override
//    func awakeFromNib() {
//
//        super.awakeFromNib()
//        wqe("+awakeFromNib f  = \(frame)")
//        setup()
//    }

    // MARK: UI Layouts
    func setup() -> Void {
        setupRes()
        setupViewTree()
        setupConstraint()
        setupAction()
    }

//    func setupViewTree() -> Void;
//
//    func setupConstraint() -> Void;
//
//    func setupAction() -> Void;

    private func getView() -> UIView? { return self as? UIView }

    func addToRoot() -> Bool { return false; }

    func getViewTree() -> [Any] { return [] }

    func getConstraints() -> [Any] { return [] }

    func setupRes() -> Void { }

    // This is from code
    func setupViewTree() -> Void {
        if let v = getView() {
            let t = getViewTree()
            if (addToRoot() && !t.isEmpty) {
                FLLayouts.addView(to: v, child: t)
            }
        }
    }

    func setupConstraint() -> Void {
        if let v = getView() {
            let c = getConstraints();
            FLLayouts.activate(v, forConstraint: c);
        }
    }

    func setupAction() -> Void { }

}

// Default method, like in Java :
//public interface MyInterface {
//    void a() {}
//}
protocol MyProtocol {
    func a() -> Void;
}

extension MyProtocol {
    func a() -> Void {
        wqe("")
    }
}

typealias OnClickListener = (_ control: UIControl) -> ()
class X : NSObject, MyProtocol {
    var onClose: OnClickListener?
    var lis : MyProtocol? = nil;

    func a() {
        wqe("call in X");
    }

    func build () {
        self.onClose = { control in
            wqe("Hello \(control)")
        }
    }
}
