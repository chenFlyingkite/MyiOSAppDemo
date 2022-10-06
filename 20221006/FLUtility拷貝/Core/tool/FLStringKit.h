//
// Created by Eric Chen on 2019-08-07.
// Copyright (c) 2019 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLLog.h"
#import "FLMath.h"

@class FLFile;
@interface NSString (Basis)
+ (NSString *) format:(NSString *)format, ...;
- (bool) is:(NSString*)t;
- (bool) isOneOf:(NSArray<NSString*>*)a;
- (NSString*) trim;
- (NSString *) erase:(NSArray<NSString*>*)targets;
- (NSString *) add:(NSString *)s;
- (NSString *) addF:(NSString *)format, ...;
- (NSArray<NSString*>*) split:(NSString *)delim;
- (NSDictionary<NSString*,NSString*>*) splitByDelim1:(NSString *)d1 delim2:(NSString *)d2;

#pragma mark - URI
/// Encode string like javascript's encodeURI() method
/// converts |m t?a=1&b="2"| -> |m%20t?a=1&b=%222%22|
- (NSString*) encodeURI;
/// backs of |m t?a=1&b="2"| <- |m%20t?a=1&b=%222%22|
- (NSString*) decodeURI;


#pragma mark - Convert to other classes
- (NSURL *) asURL;
- (NSURL *) asFileURL;
- (FLFile *) asFLFile;
- (NSURLRequest *) asRequest;
- (NSDictionary*) toJson;

#pragma mark - Path extension
- (bool) extensionIs:(NSString *)ext;
@end


#pragma mark -
@interface FLStringKit : NSObject
+ (NSString *) now;
+ (NSString *) now:(NSString *)format;
+ (NSString *) join:(NSArray<NSObject*> *)array pre:(NSString *)pre delim:(NSString *)delim post:(NSString *)post;
+ (NSString *) joins:(NSArray<NSObject*> *)array;
/// reverse of - (NSDictionary<NSString*,NSString*>*) splitByDelim1:(NSString *)d1 delim2:(NSString *)d2;
+ (NSString*) join:(NSDictionary*)map pre:(NSString *)pre delimKV:(NSString *)d1 delimEntry:(NSString*)d2 post:(NSString *)post;
+ (NSString*) joinAsUrlParameter:(NSDictionary*)map;


+ (int) compareVersion:(NSString*)v1 and:(NSString*)v2 delim:(NSString*)de;
@end