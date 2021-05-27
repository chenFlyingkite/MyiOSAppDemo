//
// Created by Eric Chen on 2021/2/2.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

protocol CellFromClass : CellBinder {
    func cellClassAt(_ path:IndexPath) -> Int;
    func cellClasses() -> Array<AnyClass>;
}
