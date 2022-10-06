//
// Created by Eric Chen on 2021/1/14.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLResKit.h"

@interface FLSeekbar : UISlider

//@property (strong, nonatomic) UIButton *trackView;
//@property (strong, nonatomic) UIButton *progressView;
@property (nonatomic, strong) UIView *trackView;
@property (nonatomic, strong) UIView *progressView;

@property (nonatomic, assign) double trackHeight;

// For anchor point
@property (nonatomic, assign) bool showAnchor;
@property (nonatomic, assign) double anchorValue;
@property (nonatomic, assign) double anchorWidth;
@property (nonatomic, assign) double anchorHeight;
@property (nonatomic, strong) UIView *anchorView;

//----
@property (nonatomic, strong) FLRes* thumbRes;
+ (FLRes*) myDefaultThumb;

@end
