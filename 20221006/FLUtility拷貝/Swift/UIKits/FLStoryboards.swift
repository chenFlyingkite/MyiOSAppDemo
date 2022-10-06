//
// Created by Eric Chen on 2021/2/1.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class FLStoryboards : NSObject {
    /**
     Easy-use method for start new view controller with parameters
     Note:
       For status bar's light/dark mode, please implement the method in destination view controller
        Objective-C =
            - (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
        Swift =
            override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

     E.g. run "Story.storyboard"'s where id = "Main" by parent of /launcher/
       => go(storyboardFileName: "Story", viewControllerId: "Main", sourceVC: launcher)
     - Parameters:
       - storyboardFileName: File name of storyboard
       - viewControllerId: Storyboard id in file
       - sourceVC: parent view controller
     - Returns:
      */
     // This is for ObjectiveC with no parameter name
    @objc
    class func go(storyboardFileName name: String, viewControllerId id: String, source: UIViewController) -> Void {
        Self.go(storyboardFileName:name, viewControllerId:id, source:source, .presentFullScreen())
    }
    @objc
    class func go(storyboardFileName: String, viewControllerId: String, source: UIViewController, _ args:FLStoryboardInfo = .init()) -> Void {
        let id = storyboardFileName
        let vcId = viewControllerId
        let sid = id + "_segue"
        let src = source
        let board = UIStoryboard.init(name: id, bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: vcId)
        let segue = UIStoryboardSegue.init(identifier: sid, source: src, destination: vc, performHandler: args.performHandler);
        args.segue = segue
        args.didSetSegue(segue)
        args.willPerformSegue(segue)

        //src.prepare(for: segue, sender: sender)
        segue.perform()

        args.didPerformSegue(segue)
    }

    /**
     Easy-use method for start new view controller with parameters
     Note:
       For status bar's light/dark mode, please implement the method in destination view controller
        Objective-C =
            - (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
        Swift =
            override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

     E.g. run "Story.storyboard"'s where id = "Main" by parent of /launcher/
       => go(storyboardFileName: "Story", viewControllerId: "Main", sourceVC: launcher)
     - Parameters:
       - storyboardFileName: File name of storyboard
       - viewControllerId: Storyboard id in file
       - sourceVC: parent view controller
     - Returns:
      */
    @objc
    class func go(viewController vc: UIViewController, viewControllerId id: String, source: UIViewController) -> Void {
        Self.go(viewController: vc, viewControllerId: id, source: source, .presentFullScreen())
    }
    @objc
    class func go(viewController: UIViewController, viewControllerId: String, source: UIViewController, _ args:FLStoryboardInfo = .init()) -> Void {
        let vcId = viewControllerId
        let sid = vcId + "_segue"
        let src = source
        let vc = viewController
        let segue = UIStoryboardSegue.init(identifier: sid, source: src, destination: vc, performHandler: args.performHandler);
        args.segue = segue
        args.didSetSegue(segue)
        args.willPerformSegue(segue)

        //src.prepare(for: segue, sender: sender)
        segue.perform()

        args.didPerformSegue(segue)
    }
}
