//
// Created by Eric Chen on 2020/12/30.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import "FLNSKit.h"


@implementation FLNSKit {

}

@end

@implementation NSURL (DeepCopy)
- (NSURL *) deepCopy {
    return [NSURL URLWithString:self.absoluteString];
}
@end


// TODO Extract NSArray to single class
// x?:y https://en.wikipedia.org/wiki/Elvis_operator
@implementation NSArray (Logging)
- (BOOL) isEmpty {
    return self.count == 0;
}
- (BOOL) isNotEmpty {
    return ![self isEmpty];
}

- (void) printAll {
    long n = self.count;
    qw("%lu items", self.count);
    for (int i = 0; i < n; ++i) {
        qw("#%4d : %s", i, ssString(self[i]));
    }
}

- (NSString *) toString {
    return [FLStringKit join:self pre:@"[" delim:@", " post:@"]"];
}
@end


@implementation NSArray (Access)
- (NSArray*) addsAll:(NSArray*)end {
    return [self arrayByAddingObjectsFromArray:end];
}

- (NSArray*) adds:(__kindof NSObject *)item {
//- (NSArray*) add:(T *)item {
    return [self arrayByAddingObject:item];
}
@end

@implementation NSMutableArray (Access2)
- (void) addAll:(NSArray*)end {
    [self addObjectsFromArray:end];
}

- (void) add:(__kindof NSObject *)item {
    [self addObject:item];
}
@end