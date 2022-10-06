//
// Created by Eric Chen on 2019-10-29.
// Copyright (c) 2019 CyberLink. All rights reserved.
//

#import "FLComparators.h"
#import "FLFile.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wimplicit-int-conversion"

@implementation FLComparators

#pragma mark - Comparators
+ (NSComparator) create:(NSComparator)comparator asc:(bool)asc {
    return ^NSComparisonResult (id a, id b) {
        if (asc) {
            return comparator(a, b);
        } else {
            return comparator(b, a);
        }
    };
}
+ (NSComparator) comparatorOfASCII {
    return ^NSComparisonResult (NSString *a, NSString *b) {
        return [a compare:b];
    };
}
+ (NSComparator) comparatorOfASCIIDesc {
    return [FLComparators create:self.comparatorOfASCII asc:false];
}

+ (NSComparator)comparatorOfLengthASCII {
    return ^NSComparisonResult (NSString *a, NSString *b) {
        int n = a.length;
        int m = b.length;
        if (n > m) {
            return NSOrderedDescending;
        } else if (n < m) {
            return NSOrderedAscending;
        } else { // n = m
            return [a compare:b];
        }
    };
}

+ (NSComparator)comparatorOfLengthASCIIDesc {
    return [FLComparators create:self.comparatorOfLengthASCII asc:false];
}

/// Sort for file
+ (NSComparator) comparatorOfModificationDate {
    return ^NSComparisonResult (NSString *a, NSString *b) {
        NSFileAttributeKey key = NSFileModificationDate;//NSFileCreationDate;
        FLFile *fa = [FLFile of:a];
        FLFile *fb = [FLFile of:b];
        NSDate *da = fa.attributes[key];
        NSDate *db = fb.attributes[key];
        return [da compare:db];
    };
}

+ (NSComparator) comparatorOfModificationDateDesc {
    return [FLComparators create:self.comparatorOfModificationDate asc:false];
}
@end

#pragma clang diagnostic pop
