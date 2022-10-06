//
// Created by Eric Chen on 2020/12/22.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FLResKit.h"

// -- Testing Area --
// Remark 'A': IBInspectable has pitfalls of setting value did not draw when value changed from storyboard
// So we just discard it and always use codes
// IB_DESIGNABLE // A:
// -- Testing Area --

@interface FLImageView : UIButton
// Background colors of FLImageView, supports normal, press, selected, disable state
@property (nonatomic, strong) FLRes* BGColors;
// Border color, ndps
@property (nonatomic, strong) FLRes* BDColors;

// -- Testing Area --
//@interface FLImageView : UIControl
// @property (nonatomic, strong) IBInspectable UIColor* backXyz; // A:
//@property (nonatomic, readonly) UIImageView *imageView; // Or should use UIControl + UIImageView?
// -- Testing Area --

@end