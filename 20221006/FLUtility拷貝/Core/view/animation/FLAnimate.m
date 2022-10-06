//
// Created by Eric Chen on 2020/12/30.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import "FLAnimate.h"

#pragma mark - Animation Parameter
@implementation FLAnimate {

}

- (instancetype) init {
    self = [super init];
    _duration = 1;
    _animate = nil;
    _completion = nil;
    return self;
}
@end