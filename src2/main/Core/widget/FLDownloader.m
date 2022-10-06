//
// Created by Eric Chen on 2019-08-28.
// Copyright (c) 2019 CyberLink. All rights reserved.
//

#import "FLDownloader.h"

@interface FLDownloader()
@end

@implementation FLDownloader {
}

#pragma mark - Initialization
- (instancetype)init {
    self = [super init];
    [self basic];
    return self;
}

- (void) basic {
    _queue = [NSOperationQueue new];
    _allTasks = [NSMutableDictionary new];

    NSString *path = [FLFile getDirectoryOf:NSCachesDirectory at:0];
    path = [path stringByAppendingPathComponent:@"Base"];
    [self setTargetFolder:path];
}

- (void) setTargetFolder:(NSString *)path {
    _targetFolder = path;
    if (path) {
        FLFile *f = [FLFile of:path];
        [f mkdirs];
    }
}

#pragma mark - Public methods

- (void) download:(NSString *)url listener:(FLDownloadListener *)listener {
    NSString *name = [url lastPathComponent];
    NSString *path = [_targetFolder stringByAppendingPathComponent:name];
#if DEBUG
    qw("Download url = %s\n=> name = %s\n=> path = %s", url.UTF8String, name.UTF8String, path.UTF8String);
#endif
    [self download:url saveTo:path taskKey:path listener:listener];
}

- (void) download:(NSString *)url saveTo:(NSString *)path taskKey:(NSString *)key listener:(FLDownloadListener *)listener {
    if (path == nil || url == nil) {
        return;
    }
#if DEBUG
    qw("Download %s\n  to  = %s\n  key = %s\n  lis = 0x%x", url.UTF8String, path.UTF8String, key.UTF8String, listener);
#endif
    NSURL *x = [[url encodeURI] asURL];
    NSURLRequest *req = [NSURLRequest requestWithURL:x cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    NSOutputStream *saveTo = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    FLDownloadListener *li = listener;

    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    op.outputStream = saveTo;
    [op setCompletionBlockWithSuccess: ^(AFHTTPRequestOperation *operation, id responseObject) {
        [self remove:key];
        if (li && li.onComplete) {
            li.responseObject = responseObject;
            li.onComplete(operation, responseObject);
        }
    }
                              failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self remove:key];
        if (li && li.onFail) {
            li.error = error;
            li.onFail(operation, error);
        }
    }];
    [op setDownloadProgressBlock: ^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (li && li.onProgress) {
            li.bytesRead = bytesRead;
            li.totalBytesRead = totalBytesRead;
            li.totalBytesExpectedToRead = totalBytesExpectedToRead;
            li.onProgress(bytesRead, totalBytesRead, totalBytesExpectedToRead);
        }
    }];
    if (key) {
        @synchronized (_allTasks) {
            _allTasks[key] = op;
        }
    }
    if (li && li.onPreExecute) {
        // restart
        li.operation = op;
        li.taskKey = key;
        li.bytesRead = 0;
        li.totalBytesRead = -1;
        li.totalBytesExpectedToRead = -1;
        li.responseObject = nil;
        li.error = nil;
        li.onPreExecute(op, key);
    }
    [_queue addOperation:op];
}

- (bool) existTask:(NSString *)key {
    if (!key) {
        return false;
    }
    @synchronized (_allTasks) {
        return _allTasks[key] != NULL;
    }
}

- (void) cancel:(NSString *)key {
    [self remove:key cancel:true];
}

- (void) remove:(NSString *)key {
    [self remove:key cancel:false];
}

- (void) remove:(NSString *)key cancel:(bool)cancel {
    if (!key) {
        return;
    }
    
    @synchronized (_allTasks) {
        if (cancel) {
            AFHTTPRequestOperation *op = _allTasks[key];
            if (op) {
                [op cancel];
            }
        }
        _allTasks[key] = nil;
    }
}

- (void) cancelAll {
    @synchronized (_allTasks) {
        NSArray<NSString*> *keys = _allTasks.allKeys;
        for (NSString *k in keys) {
            [self cancel:k];
        }
    }
}
@end

#pragma mark - Listener
@implementation FLDownloadListener

- (instancetype)init {
    self = [super init];
    self.statistics = [FLDownloadStatistics new];
    return self;
}

- (NSString *) getState {
    return [@"" addF:@"%u %lld/%lld, e = %s, key = %s, op = %s, res = %s"
            , _bytesRead, _totalBytesRead, _totalBytesExpectedToRead, ssString(_error)
            , ssString(_taskKey), ssString(_operation), ssString(_responseObject)
    ];
}

@end

#pragma mark - Statistics
@implementation FLDownloadStatistics

- (instancetype)init {
    self = [super init];
    self.link = @"";
    self.spentTime = 0;
    return self;
}

@end
