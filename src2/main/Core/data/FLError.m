//
// Created by Eric Chen on 2020/12/30.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import "FLError.h"
#import "FLLog.h"

@implementation FLError {

}

+ (FLError *) ofError:(NSError *)e from:(NSString *)method {
    if (e) {
        FLError *er = [FLError new];
        [er set:e from:method];
        return er;
    } else {
        return nil;
    }
}

- (void)set:(NSError *)e from:(NSString *)method {
    _error = e;
    _errorFrom = e.code ? method : @"";
}

void printError(NSError* e) {
    if (e.code) {
        qw("X_X , e = %s", ssString(e));
    }
}
@end
