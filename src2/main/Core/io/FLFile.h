//
// Created by Eric Chen on 2019-08-29.
// Copyright (c) 2019 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLError.h"
#import "FLComparators.h"
#import "FLStringKit.h"

@interface FLFile : NSObject
@property (nonatomic, readonly, strong) NSString *path;
@property (nonatomic, readonly, strong) NSString *name;
@property (nonatomic, readonly) bool isDirectory;
@property (nonatomic, readonly) bool exist;
@property (nonatomic, readonly) bool readable;
@property (nonatomic, readonly) bool writable;
@property (nonatomic, readonly) bool executable;
@property (nonatomic, readonly) bool deletable;
@property (nonatomic, readonly) NSDictionary<NSFileAttributeKey, id> *attributes;
@property (nonatomic, readonly) long long filesize;

@property (nonatomic, strong) FLError *error;

- (FLFile *) initBy:(NSString *)path;
+ (FLFile *) of:(NSString *)path;
+ (FLFile *) of:(NSString *)parent name:(NSString *)name;
+ (FLFile *) ofFile:(FLFile *)parent name:(NSString *)name;
/// For listing file in PhotoDirector/Resource/myItem
/// uses [FLFile ofResoource:@"myItem"]
+ (FLFile *) ofResource:(NSString*) path;
- (void) refresh;
- (void) delete;
- (BOOL) mkdirs;
#pragma mark - Files in NSString form
/// Sorting uses FLComparators
- (NSArray<NSString*>*) list;
- (NSArray<NSString*>*) listAll;
/// Depth >= 1, /A/B/C is depth 2 of /A, listing path component count >= depth
- (NSArray<NSString*>*) listDepth:(int)depth;
- (NSArray<FLFile*>*) listFiles;
- (UIImage*) asUIImage;

+ (NSString*) getDirectoryOf:(NSSearchPathDirectory)dir at:(int)index;
+ (FLFile*) createDirectoryOf:(NSSearchPathDirectory)dir at:(int)index subfolder:(NSString *)child;

@end
