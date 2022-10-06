//
// Created by Eric Chen on 2021/2/4.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

public class FLFileKit {
    public typealias PathKind = FileManager.SearchPathDirectory

    // mark: #pragma mark - File system
    public class func getDirectory(_ dir: PathKind, _ at:Int = 0) -> String {
        let dirs = NSSearchPathForDirectoriesInDomains(dir, .userDomainMask, true)
        return dirs[at]
    }

    public class func createDirectory(_ dir: PathKind, _ child:String, _ at:Int = 0) -> FLFile? {
        let parent = Self.getDirectory(dir, at)
        let f = FLFile.of(parent, name: child)
        if let f = f {
            if (!f.exist) {
                f.mkdirs()
            }
        }
        return f
    }
}
