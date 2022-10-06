//
// Created by Eric Chen on 2019-08-29.
// Copyright (c) 2019 CyberLink. All rights reserved.
//

#import "FLFile.h"
#import "FLNSKit.h"
#import "FLTicTac.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wsign-conversion"

@implementation FLFile
+ (FLFile *) of:(NSString *)parent name:(NSString *)name {
    NSString *s = [NSString stringWithFormat:@"%@/%@", parent, name];
    return [FLFile of:s];
}
+ (FLFile *) ofFile:(FLFile *)parent name:(NSString *)name {
    return [FLFile of:parent.path name:name];
}
+ (FLFile *) of:(NSString *)path {
    return [[FLFile alloc] initBy:path];
}
+ (FLFile *) ofResource:(NSString*) path {
    NSBundle *m = NSBundle.mainBundle;
    return [FLFile of:m.bundlePath name:path];
}

- (instancetype) initBy:(NSString *)path {
    self = [super init];
    _path = path;
    _name = [path split:@"/"].lastObject;
    [self refresh];
    return self;
}

- (void) refresh {
    NSFileManager *fm = NSFileManager.defaultManager;
    NSString *p = _path;
    NSError *e;
    _exist = [fm fileExistsAtPath:p isDirectory:&_isDirectory];
    _readable = [fm isReadableFileAtPath:p];
    _writable = [fm isWritableFileAtPath:p];
    _deletable = [fm isDeletableFileAtPath:p];
    _executable = [fm isExecutableFileAtPath:p];

    NSDictionary<NSFileAttributeKey, id> *d = [fm attributesOfItemAtPath:p error:&e];
    _error = [FLError ofError:e from:@"NSFileManager.attributesOfItemAtPath"];
    _attributes = d;
    _filesize = [d[NSFileSize] longLongValue];
}

#pragma mark - Public methods
- (NSString *) description {
    return [FLStringKit joins:@[
            _exist       ? @"-" : @"?",
            _isDirectory ? @"D" : @"-", @" ",
            _readable    ? @"r" : @"-",
            _writable    ? @"w" : @"-",
            _executable  ? @"x" : @"-",
            _deletable   ? @"d" : @"-", @" ",
            [NSString stringWithFormat:@"%12lld", _filesize],
            @" ", _name,
            @" ", _path,
    ]];
}

- (void) delete {
    NSFileManager *fm = NSFileManager.defaultManager;
    NSString *p = _path;
    NSError *e;
    [fm removeItemAtPath:p error:&e];
    [_error set:e from:@"NSFileManager.removeItemAtPath"];
    return;
}

- (BOOL) mkdirs {
    NSFileManager *fm = NSFileManager.defaultManager;
    NSString *p = _path;
    NSError *e;
    BOOL r = [fm createDirectoryAtPath:p withIntermediateDirectories:YES attributes:nil error:&e];
    [_error set:e from:@"NSFileManager.createDirectoryAtPath"];
    return r;
}
#pragma mark - List files
- (NSArray<NSString*>*) list {
    NSFileManager *fm = NSFileManager.defaultManager;
    NSString *p = _path;
    NSError *e;
    // - list contents and append parent path
    NSMutableArray<NSString*> *fs = [[fm contentsOfDirectoryAtPath:p error:&e] mutableCopy];
    [_error set:e from:@"NSFileManager.contentsOfDirectoryAtPath"];
    for (int i = 0; i < fs.count; ++i) {
        fs[i] = [p addF:@"/%@", fs[i]];
    }
    return fs;
}
- (NSArray<FLFile*>*) listFiles {
    NSMutableArray<FLFile*> *g = [NSMutableArray new];
    NSArray<NSString*> *f = [self list];
    for (int i = 0; i < f.count; ++i) {
        [g addObject:[FLFile of:f[i]]];
    }
    return g;
}
#pragma mark - Files in NSString form

- (NSArray<NSString*> *) listAll {
    return [self listDepth:2147483647];
}

- (NSArray<NSString*>*) listDepth:(int)depth {
    FLFile *parent = self;
    NSArray<NSString*>* src = [parent list];

    NSMutableArray<NSString*>* pool = [NSMutableArray new];
    NSMutableArray<NSString*>* scan = [NSMutableArray new];
    if ([src isNotEmpty]) {
        [pool addObjectsFromArray:src];
    }
    while ([pool isNotEmpty]) {
        NSString *f = pool[0];
        FLFile *ff = [FLFile of:f];
        NSArray<NSString*>* fs = [ff list];
        if ([fs isNotEmpty]) {
            [pool addObjectsFromArray:fs];
        }
        NSString *local = [f erase:@[[parent.path add:@"/"]]];
        if (depth >= local.pathComponents.count) {
            [scan addObject:f];
        }
        [pool removeObjectAtIndex:0];
    }
    return scan;
}

- (UIImage*) asUIImage {
    if (!_exist) { return nil; }
    UIImage *m;
    //FLTicTac *t = [FLTicTac new];
    //[t tic];
    m = [UIImage imageWithContentsOfFile:_path];
    //[t tac:@"asUIImage %s", ssString(_path)];
    return m;
}

#pragma mark - File system
+ (NSString*) getDirectoryOf:(NSSearchPathDirectory)dir at:(int)index {
    NSArray<NSString*>* dirs = NSSearchPathForDirectoriesInDomains(dir, NSUserDomainMask, YES);
    return dirs[index];
}

+ (FLFile*) createDirectoryOf:(NSSearchPathDirectory)dir at:(int)index subfolder:(NSString *)child {
    NSString *parent = [FLFile getDirectoryOf:dir at:index];
    FLFile *f = [[parent addF:child] asFLFile];
    if (!f.exist) {
        [f mkdirs];
    }
    return f;
}

@end

#pragma clang diagnostic pop