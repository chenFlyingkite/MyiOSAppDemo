//
// Created by Eric Chen on 2019-09-23.
// Copyright (c) 2019 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLDrawPen.h"

@interface FLCartesianPaperView : UIView
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize tile;
@property (nonatomic) bool tileCentered;
@property (nonatomic, strong) FLDrawPen *border;
@property (nonatomic, strong) FLDrawPen *vertical;
@property (nonatomic, strong) FLDrawPen *horizontal;

- (void) centerTile;
@end