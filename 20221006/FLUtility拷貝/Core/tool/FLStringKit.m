//
// Created by Eric Chen on 2019-08-07.
// Copyright (c) 2019 CyberLink. All rights reserved.
//

#import "FLStringKit.h"
#import "FLFile.h"
//#import "FLCGUtil.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wimplicit-int-conversion"
#pragma clang diagnostic ignored "-Wsign-conversion"

@implementation NSString (Basis)
+ (NSString *) format:(NSString *)format, ...{
    // Or should we uses [@"" addF:format, args] ?
    NSString *s;
    va_list args;
    va_start(args, format);
    //s = [NSString stringWithFormat:format, args]; // EXC_BAD_ACCESS (code=1, address=0x10)
    s = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return s;
}

#pragma mark - Basic methods / method abbreviations
- (bool) is:(NSString*)t {
    return [self isEqualToString:t];
}

- (bool) isOneOf:(NSArray<NSString*>*)a {
    for (int i = 0; i < a.count; i++) {
        if ([self is:a[i]]) {
            return true;
        }
    }
    return false;
}

- (NSString *) trim {
    NSCharacterSet *w = NSCharacterSet.whitespaceCharacterSet;
    return [self stringByTrimmingCharactersInSet:w];
}

- (NSString *) erase:(NSArray<NSString*>*)a {
    NSString *s = self;
    for (int i = 0; i < a.count; ++i) {
        s = [s stringByReplacingOccurrencesOfString:a[i] withString:@""];
    }
    return s;
}

- (NSString *) add:(NSString *)s {
    NSMutableString *z = [NSMutableString new];
    [z setString:self];
    [z appendString:s];
    return z;
}

- (NSString *) addF:(NSString *)format, ... {
    NSString *s;
    va_list args;
    va_start(args, format);
    //s = [NSString stringWithFormat:format, args]; // EXC_BAD_ACCESS (code=1, address=0x10)
    s = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [self add:s];
}

- (NSArray<NSString*>*) split:(NSString *)delim {
    return [self componentsSeparatedByString:delim];
}

- (NSDictionary<NSString*, NSString*>*) splitByDelim1:(NSString *)d1 delim2:(NSString *)d2 {
    NSMutableDictionary<NSString*,NSString*> *d = [NSMutableDictionary new];
    NSArray<NSString*> *a = [self componentsSeparatedByString:d1];
    for (int i = 0; i < a.count; i++) {
        NSString *ai = a[i];
        NSArray<NSString*> *p = [ai componentsSeparatedByString:d2];
        NSString *k = ai;
        NSString *v = ai;
        if (p.count == 2) {
            k = p[0];
            v = p[1];
        }
        d[k] = v;
    }
    return d;
}

#pragma mark - URI
- (NSString*) encodeURI {
    return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (NSString*) decodeURI {
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Convert to other classes
- (NSURL *) asURL {
    return [NSURL URLWithString:self];
}
- (NSURL *) asFileURL {
    return [NSURL fileURLWithPath:self];
}
- (FLFile *) asFLFile {
    return [FLFile of:self];
}
- (NSURLRequest *) asRequest {
    return [NSURLRequest requestWithURL:[self asURL]];
}
- (NSDictionary*) toJson {
    NSData *d = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *j = [NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingMutableContainers error:nil];
    return j;
}

#pragma mark - Path extension
- (bool) extensionIs:(NSString *)ext {
    return [ext is:self.pathExtension.lowercaseString];
}
@end

#pragma mark -

@implementation FLStringKit

static NSDateFormatter *fmt = nil;

+ (NSString *) now {
    //return [FLStringKit now:@"yyyy-MMdd HH:mm:ss.SSS"];
    return [FLStringKit now:@"MM-dd HH:mm:ss.SSS"];
}

+ (NSString *) now:(NSString *)format {
    NSDate *d = [NSDate new];
    if (fmt == nil) {
        fmt = [NSDateFormatter new];
    }
    fmt.dateFormat = format;
    return [fmt stringFromDate:d];
}

+ (NSString *) join:(NSArray<NSObject*> *)array pre:(NSString *)pre delim:(NSString *)delim post:(NSString *)post {
    NSMutableString *s = [NSMutableString new];
    // Pre
    [s setString:pre];
    // array
    for (int i = 0; i < array.count; i++) {
        NSObject *ai = array[i];
        if (i != 0) {
            [s appendString:delim];
        }
        [s appendString:ai.description];
    }
    // Post
    [s appendString:post];
    return s;
}

+ (NSString*) join:(NSDictionary*)map pre:(NSString *)pre delimKV:(NSString *)d1 delimEntry:(NSString*)d2 post:(NSString *)post {
    NSMutableString *s = [NSMutableString new];
    // Pre
    [s setString:pre];
    // array
    NSArray *keys = map.allKeys;
    for (int i = 0; i < keys.count; i++) {
        NSObject *k = keys[i];
        NSObject *v = map[k];
        if (i != 0) {
            [s appendString:d2];
        }
        [s appendFormat:@"%@%@%@", k, d1, v];
    }
    // Post
    [s appendString:post];
    return s;
}

+ (NSString*) joinAsUrlParameter:(NSDictionary*)map {
    return [FLStringKit join:map pre:@"" delimKV:@"=" delimEntry:@"&" post:@""];
}

+ (NSString *) joins:(NSArray<NSObject*> *)array {
    return [FLStringKit join:array pre:@"" delim:@"" post:@""];
}

/**
 * #165
 * Compares version codes with delimiter
 * Version code is like int([.]int)* with num = integer numbers
 * let v1, v2 are two strings split by dot, then
 * return | v1        | v2
 *  -1    | "7.2.5.3" | "7.2.6"
 *  0     | "1.0.0"   | "1"
 *  0     | "1.01"    | "1.001"
 *  -1    | "0.1"     | "1.1"
 *   1    | "1.0.1"   | "1.0"
 */
+ (int) compareVersion:(NSString*)v1 and:(NSString*)v2 delim:(NSString*)de {
    NSArray<NSString*>* v1s = [v1 componentsSeparatedByString:de];
    NSArray<NSString*>* v2s = [v2 componentsSeparatedByString:de];

    int n1 = v1s.count;
    int n2 = v2s.count;
    int max = maxl(n1, n2);
    for (int i = 0; i < max; i++) {
        int x = 0, y = 0;
        if (i < n1) {
            x = v1s[i].intValue;
        }
        if (i < n2) {
            y = v2s[i].intValue;
        }
        if (x < y) {
            return -1;
        } else if (x > y) {
            return 1;
        }
    }
    return 0;
}

@end

#pragma clang diagnostic pop