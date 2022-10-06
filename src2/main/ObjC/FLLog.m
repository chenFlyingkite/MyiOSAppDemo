//
// Created by Eric Chen on 2020/12/30.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import "FLLog.h"

#pragma mark - toString() for Struct, NSObject and more types
const char* ssCGRect(CGRect r) {
    return NSStringFromCGRect(r).UTF8String;
}

const char* ssCGSize(CGSize s) {
    return NSStringFromCGSize(s).UTF8String;
}

const char* ssCGPoint(CGPoint p) {
    return NSStringFromCGPoint(p).UTF8String;
}

const char* ssCGAffineTransform(CGAffineTransform f) {
    return NSStringFromCGAffineTransform(f).UTF8String;
}

@implementation FLLog {

}
@end