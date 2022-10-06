//
// Created by Eric Chen on 2021/1/31.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation


public class FLUndoManager<T : NSObject> : NSObject {
    private var undos = [T]()
    private var redos = [T]()
    private var nowIs :T? = nil

    private var way = 1
    private var alls = [T]()
    private var nowAt = -1

    // Method cannot be declared public because its parameter uses an internal type
    //public func setA(_ s : Listener?) { listener = s }

    //var lis : FLUndoListener?
//    var listener : Listener?
//    class Listener : FLUndoListener {
//        typealias `Type` = T
//        func onUndo(_ item: T) { }
//        func onRedo(_ item: T) { }
//    }

    public func canUndo() -> Bool {
        if (way == 1) {
            return nowAt > 0
        } else {
            return undos.count > 0
        }
    }

    public func canRedo() -> Bool {
        if (way == 1) {
            return nowAt < alls.count - 1
        } else {
            return redos.count > 0
        }
    }

    public func reset() {
        undos.removeAll()
        redos.removeAll()
        alls.removeAll()
        nowAt = -1
    }

    public func push(_ item:T) -> Void {
        if (way == 1) {
            let nx = nowAt + 1
            // clear redo stack
            for i in nx..<alls.count {
                alls.remove(at: nx)
            }
            // add current data
            alls.insert(item, at: nx)
            nowAt = nx
        } else {
            if (nowIs != nil) {
                undos.append(nowIs!)
            }
            nowIs = item
            redos.removeAll()
        }
    }

//    public func undo() -> Void {
//        if (canUndo()) {
//            let x = moveOneItem(&undos, &redos)
//            if let x = x {
//                listener?.onUndo(x)
//            }
//        }
//    }
//
//    public func redo() -> Void {
//        if (canRedo()) {
//            let x = moveOneItem(&redos, &undos)
//            if let x = x {
//                listener?.onRedo(x)
//            }
//        }
//    }

    // move from.last() to push in to.back(), returns the moved item
    private func moveOneItem(_ from: inout [T] , _ to: inout [T]) -> T? {
        let x = from.popLast()
        //if (x != nil) {
        if let x = x {
            to.append(x)
        }
        return x
    }

    //    [undo] now [redo]
    //    [u1, .., un-1, un], now, [rn, rn-1, ..., r1]
    // -> [u1, .., un-1] un, [now,  rn, rn-1, ..., r1]
    // returns [un, now]
    public func undo() -> [T?] {
        if (way == 1) {
            var from :T? = nil
            if (canUndo()) {
                from = alls[nowAt]
                nowAt -= 1
            }
            return [alls[nowAt], from]
        } else {
            var from:T? = nil
            if (canUndo()) {
                let un = undos.popLast()
                if (nowIs != nil) {
                    redos.append(nowIs!)
                }
                from = nowIs
                nowIs = un
            }
            return [nowIs, from]
        }
    }

    //    [undo] now [redo]
    //    [u1, .., un-1, un], now, [rn, rn-1, ..., r1]
    // -> [u1, .., un-1, un,  now]  rn, [rn-1, ..., r1]
    // returns [rn, now], [toState, fromState]
    public func redo() -> [T?] {
        if (way == 1) {
            var from:T? = nil
            if (canRedo()) {
                from = alls[nowAt]
                nowAt += 1
            }
            return [alls[nowAt], from]
        } else {
            var from:T? = nil
            if (canRedo()) {
                let rn = redos.popLast()
                if (nowIs != nil) {
                    undos.append(nowIs!)
                }
                from = nowIs
                nowIs = rn
            }
            return [nowIs, from]
        }
    }

    public override var description: String {
        if (way == 1) {
            let u = desc(alls)
            var now = ""
            if (inBound(nowAt, alls)) {
                now = alls[nowAt].description
            }
            return u + "\n #\(nowAt) = " + now
        } else {
            let u = desc(undos)
            let now = nowIs?.description ?? ""
            let r = desc(redos)
            return u + "\n " + now + "\n" + r
        }
    }

    private func desc(_ a:[T]) -> String {
        return FLStringKit.join(a, pre: "[", delim: "\n", post: "]") ?? ""
    }
}

// It cannot have inner protocol...
public protocol FLUndoListener {
    associatedtype `Type`
    func onUndo(_ item:Type)
    func onRedo(_ item:Type)
}
