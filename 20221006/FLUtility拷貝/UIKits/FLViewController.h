//
// Created by Eric Chen on 2020/12/22.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <photodirector-Swift.h>
#import "FLUtil.h"
#import "FLImageView.h"
#import "FLLibrary.h"


@interface FLViewController : UIViewController <ImageEditRequester>

// - Fields
@property (nonatomic, strong) ImageEasyEditor* pageEntry;

// - Views
// Main
@property (weak, nonatomic) IBOutlet UIView *main;

@property (nonatomic, weak) IBOutlet FLImageView* close;
@property (weak, nonatomic) IBOutlet UISlider *seek;
@property (weak, nonatomic) IBOutlet UIButton *pressMe;


+ (FLImageView*)addEntry:(__kindof UIViewController*)parent;
+ (void)presentMe:(__kindof UIViewController*)src sender:(id)sender;

@end
