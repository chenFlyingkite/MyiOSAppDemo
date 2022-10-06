//
// Created by Eric Chen on 2019-10-23.
// Copyright (c) 2019 CyberLink. All rights reserved.
//

#import "FLTelescopicSight.h"
#import "FLStringKit.h"

//-- For point array

@implementation FLPoint
+ (FLPoint *)of:(double)x y:(double)y {
    FLPoint *p = [FLPoint new];
    p.x = x;
    p.y = y;
    return p;
}
+ (FLPoint *)of:(CGPoint)p {
    return [FLPoint of:p.x y:p.y];
}

- (instancetype)init {
    self = [super init];
    _x = 0;
    _y = 0;
    return self;
}

- (NSString *)description {
    return [@"" addF:@"(%.1f, %.1f)", _x, _y];
}

@end

//--
@interface FLTelescopicSight() {}

@property (nonatomic, strong) NSMutableArray<FLPoint*> *boxes;
@end

@implementation FLTelescopicSight {
}

- (instancetype)init {
    self = [super init];
    [self reset];
    return self;
}

- (void) reset {
    _boxes = [NSMutableArray new];
    _aim = -1;
    _enable = true;
}

- (void) setPoint:(FLPoint *)p at:(long)index {
    if (index < 0) return;

    // Add empty slot
    long extra = index - _boxes.count + 1;
    for (int i = 0; i < extra; i++) {
        [_boxes addObject:[FLPoint new]];
    }

    _boxes[index] = p;
}

- (long) aimAt:(FLPoint *)p {
    // Keep stationary if not enabled
    if (!_enable) return _aim;

    long oldAim = _aim;
    long newAim = [self findAim:p];
    if (oldAim != newAim) {
        _aim = newAim;
        [_onAimListener onNewAim:newAim oldAim:oldAim];
    }
    return newAim;
}

- (long) findAim:(FLPoint *)p {
    long n = _boxes.count;
    long k = _aim;
    long a = _aim;

    // Test if in aim
    if ([self isInBox:a point:p]) {
        k = a; // Aim hits
    } else if ([self isInBox:a-1 point:p]) {
        k = a - 1; // Aim - 1 hits
    } else if ([self isInBox:a+1 point:p]) {
        k = a + 1; // Aim + 1 hits
    } else {
        // Failed for caches [aim-1, aim, aim+1], use linear search
        for (int i = 0; i < n; i++) {
            if ([self isInBox:i point:p]) {
                k = i;
            }
        }
    }
    return k;
}

- (bool) isInBox:(long)i point:(FLPoint *)p {
    long n = _boxes.count;
    if (n == 0) return false;

    FLPoint *a, *b;
    if (i < 0) { // At left most
        // => i in (-Inf, -1] , true if p is in (-Inf, box_0)
        a = _boxes[0];
        return p.x < a.x;
    } else if (n-1 <= i) { // At right most
        // => i in [n-1, +Inf) , true if p is in [box_(n-1), +Inf)
        a = _boxes[n-1];
        return a.x <= p.x;
    } else { // i is in [0, n-2]
        a = _boxes[i];
        b = _boxes[i+1];
        return inBound3F(p.x, a.x, b.x);
    }
}

@end
