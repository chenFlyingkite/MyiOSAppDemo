//
// Created by Eric Chen on 2021/2/2.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

protocol CellFromNib : CellBinder {
    func cellNibIndex(for path:IndexPath) -> Int;
    func cellNibNames() -> [String];
}
