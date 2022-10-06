//
// Created by Eric Chen on 2019-08-30.
// Copyright (c) 2019 CyberLink. All rights reserved.
//

#import "FLZipArchive.h"
#import "SSZipArchive.h"
#import "FLFile.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wsign-conversion"

#pragma mark - Data sent from SSZipArchive completion handler

@interface FLZipArchiveCompleteData : NSObject
@property (nonatomic, strong) NSString *path;
@property (nonatomic) BOOL succeeded;
@property (nonatomic, strong) NSError * _Nullable error;
+ (FLZipArchiveCompleteData *)of:(NSString *)p success:(BOOL)s error:(NSError *)e;
@end

@implementation FLZipArchiveCompleteData
+ (FLZipArchiveCompleteData *) of:(NSString *)p success:(BOOL)s error:(NSError *)e {
    FLZipArchiveCompleteData *d = [FLZipArchiveCompleteData new];
    d.path = p;
    d.succeeded = s;
    if (e.code) {
        d.error = [NSError errorWithDomain:e.domain code:e.code userInfo:e.userInfo];
    } else {
        d.error = nil;
    }
    return d;
}
@end

#pragma mark - Parameters for SSZipArchive

@implementation FLZipArchiveParam
- (instancetype)init {
    self = [super init];
    [self basic];
    return self;
}
- (void) basic {
    _path = @"";
    _destination = @"";
    _preserveAttributes = true;
    _overwrite = true;
    _nestedZipLevel = 0;
    _password = nil;
    _error = nil;
    _delegate = nil;
    _progressHandler = nil;
    _completionHandler = nil;
}
- (FLZipArchiveParam *) deepCopy {
    FLZipArchiveParam *n = [FLZipArchiveParam new];
    n.path = _path;
    n.destination = _destination;
    n.preserveAttributes = _preserveAttributes;
    n.overwrite = _overwrite;
    n.nestedZipLevel = _nestedZipLevel;
    n.password = _password;
    n.error = _error;
    n.delegate = _delegate;
    n.progressHandler = _progressHandler;
    n.completionHandler = _completionHandler;
    return n;
}
@end

#pragma mark - Main body
@implementation FLZipArchive
+ (BOOL) unzip:(FLZipArchiveParam *)p {
    //qw("Unzip : %s\n   to : %s", ssString(p.path), ssString(p.destination));
    FLFile *pp = [FLFile of:p.path];
    if (!pp.exist) {
        return NO;
    }

    [[FLFile of:p.destination] mkdirs];
    NSMutableArray<NSString*>* nest = [NSMutableArray new];
    NSError *e;
    __block FLZipArchiveCompleteData *cmp = nil;
    BOOL result = [SSZipArchive unzipFileAtPath:p.path
                                  toDestination:p.destination
                             preserveAttributes:p.preserveAttributes
                                      overwrite:p.overwrite
                                 nestedZipLevel:p.nestedZipLevel
                                       password:p.password
                                          error:&e // Cannot use &(p.error)
                                       delegate:p.delegate
                                progressHandler:^(NSString *entry, unz_file_info zipInfo, long entryNumber, long total) {
        if ([entry extensionIs:@"zip"]) {
            [nest addObject:entry];
        }
        if (p.progressHandler) {
            p.progressHandler(entry, zipInfo, entryNumber, total);
        }
    }
                              completionHandler:^(NSString *path, BOOL succeeded, NSError * _Nullable error) {
        //qw("  $Eating OK path %s", path.UTF8String);
        cmp = [FLZipArchiveCompleteData of:path success:succeeded error:error];
    }];
    p.error = e;
    for (int i = 0; i < nest.count; ++i) {
        NSString *fzip = nest[i];
        NSString *f = [fzip stringByDeletingPathExtension];
        NSString *pd = p.destination;

        FLFile *np = [FLFile of:pd name:fzip];
        FLFile *nd = [FLFile of:pd name:f];
        FLZipArchiveParam *q = [p deepCopy];
        q.path = np.path;
        q.destination = nd.path;
        __block NSString * ndp = nd.path;
        //qw("#%2d : n.p = %s\n      n.d = %s", i, [np toString].UTF8String, [nd toString].UTF8String);
        q.progressHandler = ^(NSString *entry, unz_file_info zipInfo, long entryNumber, long total) {
            FLFile *qe = [FLFile of:ndp name:entry];
            //qw("   =~~ unzip  %s", [qe toString].UTF8String);
            NSString *newEntry = [qe.path erase:@[pd]];
            if (p.progressHandler) {
                p.progressHandler(newEntry, zipInfo, entryNumber, total);
            }
        };
        q.completionHandler = ^(NSString *path, BOOL succeeded, NSError * _Nullable error) {
            FLFile *qcp = [FLFile of:path];
            //qw("   =~~ unzip OK %s", [qcp toString].UTF8String);
            // Nested complete, should we notify?
            //if (p.completionHandler) {
            //    p.completionHandler(path, succeeded, error);
            //}
            [qcp delete];
        };
        result = [FLZipArchive unzip:q] || result;
    }
    //qw("# unzip loop Ended %s", cmp.path.UTF8String);

    if (p.completionHandler) {
        p.completionHandler(cmp.path, cmp.succeeded, cmp.error);
    }
    return result;
}
@end


#pragma clang diagnostic pop