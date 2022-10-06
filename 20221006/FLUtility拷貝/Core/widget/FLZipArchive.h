//
// Created by Eric Chen on 2019-08-30.
// Copyright (c) 2019 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSZipCommon.h"

@protocol SSZipArchiveDelegate;

@interface FLZipArchiveParam : NSObject
@property (nonatomic, strong) NSString * _Nonnull path;
@property (nonatomic, strong) NSString * _Nonnull destination;
@property (nonatomic) bool preserveAttributes;
@property (nonatomic) bool overwrite;
@property (nonatomic) long nestedZipLevel;
@property (nonatomic, strong) NSString * _Nullable password;
@property (nonatomic, strong) NSError * _Nullable error;
@property (nonatomic, strong) id<SSZipArchiveDelegate> _Nullable delegate;
@property (nonatomic, copy) void (^_Nullable progressHandler) (NSString *entry, unz_file_info zipInfo, long entryNumber, long total);
@property (nonatomic, copy) void (^_Nullable completionHandler) (NSString *path, BOOL succeeded, NSError * _Nullable error);

- (FLZipArchiveParam *)deepCopy;
@end

@interface FLZipArchive : NSObject
/// Since SSZipArchive's behavior of unzip nested is to expand all content
/// So we use this method to create folder for nested zip and unzip inside the folder
/// See SSZipArchive's parameter nestedZipLevel
+ (BOOL) unzip:(FLZipArchiveParam *)param;
@end