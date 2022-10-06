//
// Created by Eric Chen on 2021/1/7.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

#import "FLLibCell.h"
#import "FLUtil.h"
#import "FLLayouts.h"
#import "FLCGUtil.h"

@implementation FLLibCell {
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    qwe("self + frame = %s, %s", ssCGRect(frame), ssString(self));
    [self setup];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    qwe("self + coder = %s, %s", ssCGRect(self.frame), ssString(self));
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void) setup {
    qwe("%s", "setup");
    //self.backgroundColor = [UIColor colorWithHex:@"#4FFF"];
    //self.dataSource = self;
//    <UICollectionViewDelegate> d
//            <UICollectionViewDataSource>
    //[self setD];
    [self setupRes];
    [self setupConstraint];
}

- (void) setupTree {
//    self.myImg = [UIImageView new];
//    self.myText = [UILabel new];
}

- (void) setupRes {
    self.myImg.contentMode = UIViewContentModeScaleAspectFit;
    self.myText.backgroundColor = [UIColor colorWithHex:@"#4080"];
    self.myText.textColor = UIColor.whiteColor;
    self.myText.adjustsFontSizeToFitWidth = true;
    self.myText.numberOfLines = 4;
    self.myText.textAlignment = NSTextAlignmentCenter;
}

- (void) setupConstraint {
    NSArray * a = @[
            [FLLayouts view:self.myImg sameTo:self offset:edgeAll(2)],
        [FLLayouts view:self.myText align:NSLayoutAttributeLeft to:self offset:5],
        [FLLayouts view:self.myText align:NSLayoutAttributeRight to:self offset:-5],
        [FLLayouts view:self.myText align:NSLayoutAttributeBottom to:self offset:-5],
        //[FLLayouts view:self.myText corner:FLCornerCenterXBottom to:self],
        [FLLayouts view:self.myText set:NSLayoutAttributeHeight to:30],
    ];
    [FLLayouts activate:self forConstraint:a];
}
@end