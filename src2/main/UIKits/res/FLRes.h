//
// Created by Eric Chen on 2020/12/31.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIControl.h>
#import "FLStringKit.h"

@class FLImageView;


@interface FLRes : NSObject
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>* values;
+ (instancetype)all:(NSString *)all;

/**
 * Should also apply in Storyboard... : Button type = Custom
 * buttonType = UIButtonTypeCustom
 */
+ (instancetype)normal:(NSString *)n disable:(NSString *)d pressed:(NSString *)p selected:(NSString*) s;
- (NSDictionary<NSString*, UIColor*>*) hexColor;
- (NSString *) keyOf:(UIControlState)s;

#pragma mark - apply to UIButton and return itself
+ (__kindof UIButton*) applyAllTitle:(NSString*)s to:(__kindof UIButton*) b;

- (__kindof UIView*) applyImageTo:(__kindof UIView*) b;

- (__kindof UIButton*) applyTitleTo:(__kindof UIButton*) b;
- (__kindof UIButton*) applyTitleColorTo:(__kindof UIButton*) b;
- (__kindof UIButton*) applyBackgroundImageTo:(__kindof UIButton*) b;
- (__kindof UIView*) applyBackgroundColorTo:(__kindof UIView*) b;
#pragma mark - Apply image
- (__kindof UISlider*) applyThumbImageTo:(__kindof UISlider*) s;
@end