//
// Created by Eric Chen on 2020/12/30.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLError : NSObject
@property (nonatomic, strong) NSError *error;
//// Where the error occurs, usually use method string
@property (nonatomic, strong) NSString *errorFrom;
+ (FLError *) ofError:(NSError *)e from:(NSString *)method;
- (void) set:(NSError *)e from:(NSString *)method;

#pragma mark - Error
void printError(NSError* e);

@end