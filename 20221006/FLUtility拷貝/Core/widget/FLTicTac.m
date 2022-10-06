//
//  FLTicTac.m
//  PhotoDirector
//
//  Created by Eric Chen on 2019/6/4.
//  Copyright © 2019 CyberLink. All rights reserved.
//

#import "FLTicTac.h"
#import <memory.h>
#import <sys/time.h>


// value of N/A = Not Applicable
const int NA = 0;
// MAX time records
const int MAX = 100;
long nowTime(bool ms);

@implementation FLTicTac {
    // instance variables
    // Top of stack, we have data of [0:top-1], new data put in stack[top]
    long top;
    // Time records stack
    long stack[MAX];
}

- (instancetype)init {
    self = [super init];
    [self reset];
    _log = true;
    _enable = true;
    _tag = @"Hi";
    _ms = true;
    top = 0;
    return self;
}

- (long) tic {
    if (!_enable) return NA;
    
    return [self push];
}

- (long) tacS: (NSString*)msg {
    long t = [self tacL];
    // Printing logs
    if (_log) {
        printf("%s:", _tag.UTF8String);
        for (int i = 0; i < top; i++) {
            printf(" ");
        }
        printf("[%ld] : %s", t, msg.UTF8String);
        printf("\n");
    }
    return t;
}

// https://www.cocoawithlove.com/2009/05/variable-argument-lists-in-cocoa.html
- (long) tac: (NSString*)msg, ... {
    long t = [self tacL];
    // Printing logs
    if (_log) {
        printf("%s:", _tag.UTF8String);
        for (int i = 0; i < top; i++) {
            printf(" ");
        }
        // ----
        // Passing variable arguments to NSString init
        va_list args;
        va_start(args, msg);
        printf("[%ld] : %s", t, [[NSString alloc] initWithFormat:msg arguments:args].UTF8String);
        va_end(args);
        // ----
        printf("\n");
    }
    return t;
}

- (long) tacL {
    if (!_enable) return NA;
    
    long tac = nowTime(_ms);
    long tic = [self pop];
    if (tic == NA) {
        if (_log) {
            NSLog(@"%@: TicTac.X_X tic = %ld, tac = %ld, top = %ld", _tag, tic, tac, top);
        }
        return NA;
    }
    return tac - tic;
}

- (void) reset {
    memset(stack, NA, MAX);
    top = 0;
}

- (long) push {
    long now = nowTime(_ms);
    if (0 <= top && top < MAX - 1) {
        stack[top] = now;
        top++;
    }
    return now;
}

- (long) pop {
    long t = NA;
    if (top > 0) {
        t = stack[top - 1];
        top--;
    }
    return t;
}

long nowTime(bool ms) {
    // We want second -> #import <time.h>
    //return time(NULL);
    // We want milli-second,  -> #import <sys/time.h>
    struct timeval t;
    gettimeofday(&t, NULL);
    long us = t.tv_sec * 1000000 + t.tv_usec;
    if (ms) {
        return us / 1000;
    } else { // ms
        return us;
    }
}

@end
