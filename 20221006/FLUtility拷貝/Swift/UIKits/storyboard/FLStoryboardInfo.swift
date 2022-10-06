//
// Created by Eric Chen on 2021/2/1.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class FLStoryboardInfo : NSObject {
    var segue: UIStoryboardSegue?
    var didSetSegue: (_ seg:UIStoryboardSegue) -> () = { segue in  }
    // UIStoryboardSegue.init(_,_,_,performHandler)
    //                              ^^^^^^^^^^^^^^
    var performHandler : ()->() = {}
    // willPerformSegue(segue) // can be src.prepare(for: segue, sender: sender)
    // segue.perform()
    // didPerformSegue(segue)
    var willPerformSegue : (_ seg:UIStoryboardSegue)->() = { segue in  }
    var didPerformSegue : (_ seg:UIStoryboardSegue)->() = { segue in  }
    // src.present(dst, animated:_, completion)
    //                              ^^^^^^^^^^
    var presentCompletion : ()->() = {}
    var style = UIModalPresentationStyle.fullScreen//.automatic

    override init() {
        super.init()
        performHandler = { [unowned self] in
            if let sg = self.segue {
                sg.source.present(sg.destination, animated: true, completion: self.presentCompletion)
            }
        }
    }

    @objc
    class func presentFullScreen() -> FLStoryboardInfo {
        let it = FLStoryboardInfo.init()
        it.didSetSegue = { [unowned it] segue in
            let dst = segue.destination
            dst.modalPresentationStyle = .fullScreen
        }
        return it
    }

    @objc
    class func presentPageMode() -> FLStoryboardInfo {
        let it = FLStoryboardInfo.init()
        it.didSetSegue = { [unowned it] segue in
            let dst = segue.destination
            dst.modalPresentationStyle = .fullScreen
            dst.modalTransitionStyle = .crossDissolve
        }
        return it
    }
}
