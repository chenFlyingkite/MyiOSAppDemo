//
//  FLAlertData.h
//  PhotoDirector
//
//  Created by Eric Chen on 2019/7/3.
//  Copyright © 2019 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Encapsulates parameters for [UIAlertAction actionWithTitle:style:handler:]
@interface FLAlertParam : NSObject
@property (nonatomic, weak) NSString * title;
@property (nonatomic) UIAlertActionStyle style;
@property (nonatomic, copy) void(^handler)(UIAlertAction *action);
+ (FLAlertParam *) ofTitle:(NSString *)title handler:(void(^ __nullable)(UIAlertAction *action))handler;
@end

/// Easy class for [UIAlertController alertControllerWithTitle:message:preferredStyle:];
@interface FLAlertData : NSObject
- (instancetype) initWithButtons:(NSArray<FLAlertParam*>*)buttons;

// -- Parameters for creating UIAlertController --
@property (nonatomic, weak) NSString* title;
@property (nonatomic, weak) NSString* message;
@property (nonatomic) UIAlertControllerStyle style;
@property (nonatomic, strong) NSMutableArray<FLAlertParam*>* actions;

// -- Easy actions provided --

/// Easy action of OK
@property (nonatomic, strong) FLAlertParam* ok;
/// Easy action of Cancel
@property (nonatomic, strong) FLAlertParam* cancel;

- (UIAlertController*) get;
- (UIAlertController*) show:(UIViewController*)vc;
@end

NS_ASSUME_NONNULL_END
