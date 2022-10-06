//
// Created by Eric Chen on 2021/1/31.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

/**
 * An History recording system can be used for undo/redoing
 * Here shows usage of undo/redo:
 * let history = FLUndoManager<String>.init()
 * history.push("2021/04/24 22:49")
 * history.push("2021/04/25 00:20")
 * history.push("2021/04/25 01:35")
 * let last = history.undo() // returns now = "2021/04/25 00:20", from = "2021/04/25 01:35"
 * print("last = \(last.nowState)") // last = 2021/04/25 00:20
 * let next = history.redo()
 * print("next = \(next.nowState)") // next = 2021/04/25 01:35
 * history.reset() // remove all history as empty
 */
public class FLUndoManager<T : NSObject> : NSObject {
    public class Info : NSObject {
        var fromState: T?
        var nowState: T?
        var isUndo = false

        public override init() {
            super.init()
        }
    }

    // main engine
    private var alls = [T]()
    private var nowAt = -1

    public func canUndo() -> Bool {
        return nowAt > 0
    }

    public func canRedo() -> Bool {
        return nowAt < alls.count - 1
    }

    public func getDepth() -> Array<Int> {
        return [nowAt, alls.count]
    }

    public func reset() {
        alls.removeAll()
        nowAt = -1
    }

    //    [undo] now [redo],
    // push item
    //    [u1, .., un-1, un], now, [rn, rn-1, ..., r1]
    // -> [u1, .., un-1, un , now], item, []
    public func push(_ item:T) -> Void {
        let nx = removeAllRedo()
        // add current data
        alls.insert(item, at: nx)
        nowAt = nx
    }

    public func removeAllRedo() -> Int {
        let nx = nowAt + 1
        // clear redo stack
        for i in nx..<alls.count {
            alls.remove(at: nx)
        }
        return nx
    }

    //    [undo] now [redo]
    //    [u1, .., un-1, un], now, [rn, rn-1, ..., r1]
    // -> [u1, .., un-1] un, [now,  rn, rn-1, ..., r1]
    // returns [un, now]
    public func undo() -> Info {
        var from :T? = nil
        var to:T? = nil
        if (canUndo()) {
            from = alls[nowAt]
            to = alls[nowAt - 1]
            nowAt--
        }
        let ans = Info()
        ans.isUndo = true
        ans.fromState = from
        ans.nowState = to
        return ans
    }

    //    [undo] now [redo]
    //    [u1, .., un-1, un], now, [rn, rn-1, ..., r1]
    // -> [u1, .., un-1, un,  now]  rn, [rn-1, ..., r1]
    // returns [rn, now], [toState, fromState]
    public func redo() -> Info {
        var from:T? = nil
        var to:T? = nil
        if (canRedo()) {
            from = alls[nowAt]
            to = alls[nowAt + 1]
            nowAt++
        }
        let ans = Info()
        ans.isUndo = false
        ans.nowState = to
        ans.fromState = from
        return ans
    }

    public override var description: String {
        let u = desc(alls)
        var now = ""
        if (inBound(nowAt, alls)) {
            now = alls[nowAt].description
        }
        return u + "\n #\(nowAt) = " + now
    }

    private func desc(_ a:[T]) -> String {
        return FLStringKit.join(a, pre: "[", delim: "\n", post: "]") ?? ""
    }
}

// It cannot have inner protocol...
//public protocol FLUndoListener {
//    associatedtype `Type`
//    func onUndo(_ item:Type)
//    func onRedo(_ item:Type)
//}
