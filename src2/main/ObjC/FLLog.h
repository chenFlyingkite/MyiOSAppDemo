//
// Created by Eric Chen on 2020/12/30.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#ifndef PHOTODIRECTOR_FLLOG_H
#define PHOTODIRECTOR_FLLOG_H

#import <Foundation/Foundation.h>
#import "FLStringKit.h"

NS_ASSUME_NONNULL_BEGIN
#pragma mark - printf method abbreviations
//              0        1         2         3         4         5         6         7         8
//              12345678901234567890123456789012345678901234567890123456789012345678901234567890
#define Spaces "                                                                                "
#define qq(Format) printf("" Format "\n")
#define qw(Format, ...) printf("" Format "\n", __VA_ARGS__)
// __FILE__ gives full path from /Users/ericchen/Desktop/SVNs/PHD_iOS/....
#define qwe(Format, ...) printf("" Format"\n" Spaces "L #%u %s\n", __VA_ARGS__, __LINE__, __func__)
//#define we() printf("#%u %s\n", __LINE__, __func__)


#pragma mark - toString() for Struct, NSObject and more types
const char* ssCGRect(CGRect r);
const char* ssCGSize(CGSize s);
const char* ssCGPoint(CGPoint p);
const char* ssCGAffineTransform(CGAffineTransform f);
const char* ssString(NSObject *n);
const char* ox(bool b);

@interface FLLog : NSObject


@end


NS_ASSUME_NONNULL_END

#endif //PHOTODIRECTOR_FLLOG_H