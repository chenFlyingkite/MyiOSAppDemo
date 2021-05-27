//
// Created by Eric Chen on 2021/3/1.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

protocol FLConsole : NSObjectProtocol {
    func isKeepAtEnd() -> Bool
    func scrollToEnd() -> Void
    func setTexts(_ s:String)
    func addText(_ s:String)
    func clearAllText()
    // --
    func checkScroll()
}

extension FLConsole {
    func checkScroll() {
        if (isKeepAtEnd()) {
            scrollToEnd()
        }
    }
}
