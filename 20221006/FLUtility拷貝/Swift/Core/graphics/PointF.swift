//
// Created by Eric Chen on 2021/2/10.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

public class PointF : NSObject {
    public var x : Double = 0.0
    public var y : Double = 0.0
    public static let zero = PointF()

    // (13, 21) Designated initializer for 'PointF' cannot delegate (with 'self.init'); did you mean this to be a convenience initializer?
    public convenience override init() {
        self.init(0, 0)
    }

    public convenience init(_ p:CGPoint) {
        self.init(p.x.lf(), p.y.lf())
    }

    public convenience init(_ p:CGSize) {
        self.init(p.width.lf(), p.height.lf())
    }

    public init(_ px:Double, _ py:Double) {
        super.init()
        x = px
        y = py
    }

    func wxh() -> String {
        return String.init(format: "%dx%d", Int(self.x), Int(self.y));
    }

    func isNonPositive() -> Bool {
        return x <= 0 || y <= 0
    }

    public override var description: String {
        return String.init(format:"(%8.3f, %8.3f)", self.x, self.y)
        //return "(\(x), \(y))"
    }
}
