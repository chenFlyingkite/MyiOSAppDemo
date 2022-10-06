//
// Created by Eric Chen on 2020/12/22.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import "FLDrawPen.h"
#import "FLLog.h"
#import "FLStringKit.h"
#import "UIColor+Hex.h"

#pragma mark - Draw Pan

@implementation FLDrawPen{}

- (instancetype) init {
    self = [super init];
    [self basic];
    return self;
}

- (void) basic {
    _width = 1;
    _color = UIColor.whiteColor;

    _enable = true;
}

- (NSString *)description {
    return [@"" addF:@"enable = %s, w = %f, Color = %s, %s"
            , ox(_enable), _width, ssString(_color), ssString([_color hex])
    ];
}
@end
