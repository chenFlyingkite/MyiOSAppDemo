//
// Created by Eric Chen on 2021/1/13.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

class FLSUIKits {
        //FLUIKit.addView(to: self, child: x);
    class func addView(root:UIView, child:[Any]) -> UIView {
        for i in 0..<child.count {
            let v = child[i];
            var w:UIView? = nil;
            /*
            if let v = v as? [Any] {
                if (i > 0) {
                    if let rt = child[i-1] as? UIView {
                        w = dfs(root: rt, child: v);
                    }
                } else {
                    print("Wrong for child[%d]", i-1);
                }
            } else if let v = v as? UIView {
                w = v;
            }
            */
            if (v is Array<Any>) {
                var vs = v as! [Any];
                if (i < 1) {
                    wqe("Wrong for child[%d]", i-1);
                } else {
                    if (child[i-1] is UIView) {
                        var rt = child[i-1] as! UIView;
                        w = addView(root: rt, child: vs);
                    }
                }
            } else if (v is UIView) {
                w = v as! UIView;
            }
            if (w != nil) {
                root.addSubview(w!);
            }
        }
        return root;
    }

}
