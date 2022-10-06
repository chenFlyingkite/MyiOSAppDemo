//
// Created by Eric Chen on 2019-08-28.
// Copyright (c) 2019 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLUtil.h"
#import "FLFile.h"
#import "FLStringKit.h"
#import "AFHTTPRequestOperation.h"

@class FLDownloadListener;
@class FLDownloadStatistics;

@interface FLDownloader : NSObject
/// Operation queue receives many download AFHTTPRequestOperation
@property (nonatomic, strong) NSOperationQueue *queue;

/// Current running tasks
@property (nonatomic, strong) NSMutableDictionary<NSString*, AFHTTPRequestOperation*> *allTasks;

/// Current running tasks' listeners
@property (nonatomic, strong) NSMutableDictionary<NSString*, FLDownloadListener*> *allListeners;

/// Folder path, mainly used for -(void)download:listener;
@property (nonatomic, weak) NSString *targetFolder;

/// Easy method for -(void)download:saveTo:taskKey:listener;
/// Using <targetFolder> as download destination
- (void) download:(NSString *)url listener:(FLDownloadListener *)listener;
/// Perform download $url, save to $path, find task by identifier of $key, report status by $listener
- (void) download:(NSString *)url saveTo:(NSString *)path taskKey:(NSString *)key listener:(FLDownloadListener *)listener;

/// Exist task
- (bool) existTask:(NSString *)key;
/// Remove the task but did not cancel
///- (void) remove:(NSString *)key;

/// Cancel task
- (void) cancel:(NSString *)key;
/// Cancel all task
- (void) cancelAll;
@end

@interface FLDownloadListener : NSObject
// listeners of lambda block {}
// (operation, response) -> {}
@property (nonatomic, copy) void(^onComplete)   (AFHTTPRequestOperation *operation, id response);
@property (nonatomic, copy) void(^onFail)       (AFHTTPRequestOperation *operation, NSError *error);
@property (nonatomic, copy) void(^onProgress)   (NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);
@property (nonatomic, copy) void(^onPreExecute) (AFHTTPRequestOperation *operation, NSString *taskKey);
// () -> {}
@property (nonatomic, copy) void(^onState) ();

@property (nonatomic, strong) FLDownloadStatistics* statistics;
// states
@property (nonatomic, weak) AFHTTPRequestOperation* operation;
@property (nonatomic, weak) NSString* taskKey;
@property (nonatomic, weak) id responseObject;
@property (nonatomic, assign) NSUInteger bytesRead;
@property (nonatomic, assign) long long totalBytesRead;
@property (nonatomic, assign) long long totalBytesExpectedToRead;
@property (nonatomic, weak) NSError* error;

- (NSString *) getState;
- (double) getProgress;

@end

@interface FLDownloadStatistics : NSObject
@property (nonatomic, weak) NSString* link;
@property (nonatomic, assign) long spentTime; // in millisecond

@end
