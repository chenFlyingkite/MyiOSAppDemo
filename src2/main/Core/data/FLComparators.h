//
// Created by Eric Chen on 2019-10-29.
// Copyright (c) 2019 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLComparators : NSObject

#pragma mark - Comparators
/// Make comparator to be ascending or descending
+ (NSComparator) create:(NSComparator)comparator asc:(bool)asc;
/// Static property
+ (NSComparator) comparatorOfASCII;
+ (NSComparator) comparatorOfASCIIDesc;
+ (NSComparator) comparatorOfLengthASCII;
+ (NSComparator) comparatorOfLengthASCIIDesc;
+ (NSComparator) comparatorOfModificationDate;
+ (NSComparator) comparatorOfModificationDateDesc;
@end