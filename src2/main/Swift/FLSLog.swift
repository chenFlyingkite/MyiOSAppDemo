//
// Created by Eric Chen on 2021/1/13.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

// MARK : Loggings
/*
#pragma mark - printf method abbreviations
//              0        1         2         3         4         5         6         7         8
//              12345678901234567890123456789012345678901234567890123456789012345678901234567890
#define Spaces "                                                                                "
#define qq(Format) printf("" Format "\n")
#define qw(Format, ...) printf("" Format "\n", __VA_ARGS__)
//__FILE__ gives full path from /Users/ericchen/Desktop/SVNs/PHD_iOS/....
#define qwe(Format, ...) printf("" Format"\n" Spaces "L #%u %s\n", __VA_ARGS__, __LINE__, __func__)
//#define we() printf("#%u %s\n", __LINE__, __func__)
*/
//                    0        1         2         3         4         5         6         7         8
//                    12345678901234567890123456789012345678901234567890123456789012345678901234567890
private let spaces = "                                                                                "
private var toNS = false

func wqe(_ items: Any..., fn:String = #function, ln:Int = #line, f:String = #fileID) -> Void {
    // #fileID = "photodirector/FLSLog.swift"
    // we take file name as ff  ^^^^^^^^^^^^
    let name = f.after("/", -1)

    if (items.count > 0) {
        printLog(items[0])
    }

    //print("0        1         2         3         4         5         6         7         8")
    //print("12345678901234567890123456789012345678901234567890123456789012345678901234567890")
    let m = "\(spaces)L #\(ln) \(fn) \(name) \(FLStringKit.now()!)"
    printLog(m)
}

private func printLog(_ items: Any...) {
    // to String
    var s = ""
    // print each item
    for x in items {
        let z = String.init(describing: x)
        s += z
    }
    printLog(s)
}

private func printLog(_ s:String = "") {
    print(s)
    //-- SaveToNSLog
    if (toNS) {
        toNSLog(s)
    }
    //-- save to FLSLog
    if (FLSLog.recording) {
        FLSLog.log(s)
    }
}

private func toNSLog(_ s:String = "") {
    // narcissism macOS & iOS only receives Objective-C.NSLog(),
    // rejects C/C++.printf() & Swift.print() in SystemMonitorProgram
    NSLog(s)
}

//----
class FLSLog : NSObject {
    static var recording = false
    private static var logLine:[String] = []
    private static var logAll = ""
    private static var texts : [UITextView] = []
    private static var output : [FLConsole] = []

    class func clearAll() {
        logLine = []
        logAll = ""
    }

    class func log(_ s:String) {
        logLine.append(s)
        logAll += s + "\n"
        runOnMain( {
            for x in texts {
                x.text = logAll
                x.scrollsToBottom()
            }

            for x in output {
                x.addText(s)
                x.checkScroll()
            }
        })
    }

    class func join(_ txt:UITextView) {
        runOnMain( {
            texts.append(txt)
            txt.text = logAll
            txt.scrollsToBottom()
        })
    }

    class func join2(_ txt:FLConsole) {
        runOnMain( {
            output.append(txt)
            txt.setTexts(logAll)
            txt.checkScroll()
        })
    }

    class func leave2(_ txt:FLConsole) {
        runOnMain( {
            var newer : [FLConsole] = []
            for x in output {
                if (x.isEqual(txt)) {
                } else {
                    newer.append(x)
                }
            }
        })
    }
}
//----
