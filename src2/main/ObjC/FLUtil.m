//
//  FLUtil.m
//  PhotoDirector
//
//  Created by Eric Chen on 2019/6/10.
//  Copyright © 2019 CyberLink. All rights reserved.
//

#import "FLUtil.h"

@implementation FLUtil

#pragma mark - Copy array values
void copyTo(long *dst, long *src, int n) {
    for (int i = 0; i < n; i++) {
        dst[i] = src[i];
    }
}


#pragma mark - toString() for Struct, NSObject and more types

const char* ssString(NSObject *n) {
    return n.description.UTF8String;
}

const char* ox(bool b) {
    return b ? "o" : "x";
}

#pragma mark - Radian (0 ~ 2*pi) <-> Drgree (0 ~ 360)

double radToDeg(double r) {
    return r * 180.0 / M_PI;
}

double degToRad(double d) {
    return d / 180.0 * M_PI;
}

#pragma mark - Grand Central Dispatch for run async

// (returnType (^)(parameterTypes)) blockName
// (void(^)(void))myRun -> myRun();
void runOnWorker(dispatch_block_t run) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), run);
}

void runOnMain(dispatch_block_t run) {
    if (NSThread.isMainThread) {
        run();
    } else {
        dispatch_async(dispatch_get_main_queue(), run);
    }
}

@end


//Layout notations : ViewController
//viewDidLoad
//viewWillAppear
//  viewWillLayoutSubviews
//  viewDidLayoutSubviews
//viewDidAppear


// For class property, it it is newed from method, need to set it as strong or it will be release
//
// using weak makes content be nil and released

// To add the view in XCode,
// Create from nib and make sures
// FLImageView.h, FLImageView.m, FLImageView.xib
// FLImageView.xib :
// 1. Placeholder's File's Owner = NSObject (No setting)
// 2. Only one view in xib, no other second views
// 3. View's CustomClass = xib's target UIView (= FLImageView.h)
// 4. Links views in storyboard into *.h (= FLImageView.h)
// 5. Links view's click behaviors in *.m (= FLImageView.m)

// UIView inheritances:
// NSObject<NSObject>
// UIResponder : NSObject
// UIView : UIResponder
// UIControl : UIView
// UIButton : UIControl
// UIStackView : UIView
// UIImageView : UIView
// UILabel : UIView
// UITextField : UIControl
// UISlider : UIControl
// UISwitch : UIControl
// UIProgressView : UIView
// UICollectionView : UIScrollView
// UIScrollView : UIView
// UICollectionReusableView : UIView
// UICollectionViewCell : UICollectionReusableView
// UITableView : UIScrollView
// UITableViewCell : UIView
// UISegmentedControl : UIControl
// UIStepper : UIControl
// UITextView : UIScrollView


// Let F extends from UIView, and created by code
// ' class F : UIView
// ' F *f = [F new];
// And its behavior if defines
// | -init | -initWithFrame: |
// |   o   |      o          | = f.init() and given f.frame = Zero
// |   x   |      o          | = f.initWithFrame(Zero)
// From Storyboard = f.initWithCoder()



// TODO: Make a view with easy background color of FLRes
// = normal, highlight, pressed, selected

/*
https://docs.swift.org/swift-book/LanguageGuide/Protocols.html
// Protocol 'Listener' cannot be nested inside another declaration
class LightHitItemsArea : UIView {
    protocol Listener {
    }
}
---
Also cannot define the default values in protocol's methods
Swift did not have default interface implementation, must use extension to achieve...
Can only achieve by

protocol Listener2 {
    func m1() -> Void;
}
extension Listener2 {
    func m1() {
        print("Hello m1")
    }
}
---
*/
/*


https://davedelong.com/blog/2018/12/15/silencing-specific-build-warnings/
https://clang.llvm.org/docs/UsersManual.html#options-to-control-error-and-warning-messages
https://clang.llvm.org/docs/DiagnosticsReference.html
https://davedelong.com/blog/2018/12/15/silencing-specific-build-warnings/
Finding the compiler flags:
Report navigator, its file,
... : warning ... [-Wunused-variable]

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
//[-Wunused-variable]
- (int) colorInt {
    double argb[4] = {0};
    // ok is unused
    bool ok = [self getRed:&argb[1] green:&argb[2] blue:&argb[3] alpha:&argb[0]];
    int ans = 0;
    for (int i = 0; i < 4; i++) {
        int x = (int) round(argb[i] * 255);
        ans |= (0xFF & x) << (24 - i*8);
    }
    return ans;
}
#pragma clang diagnostic pop
*/
