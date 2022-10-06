//
// Created by Eric Chen on 2021/1/14.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

#import "FLSeekbar.h"
#import "UIColor+Hex.h"
#import "FLUIKit.h"
#import "FLCGUtil.h"

@interface FLSeekbar()
@end


@implementation FLSeekbar {
    // seekbar     ios : 0 = thumb left = track left, 100 = thumb right = track right
    // seekbar android : 0 = thumb center = track left, 100 = thumb center = track right
    bool android;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    [self setup];
    return self;
}

- (void) setup {
    _trackHeight = 4;
    _showAnchor = false;
    _anchorWidth = 1;
    _anchorHeight = _trackHeight + 8;
    _anchorValue = 0;

    android = 1 > 0;
    bool phd = 1 > 0;
    
    if (android) {
        // Disable all ios's components, since it does not meet what we want
        [super setMaximumTrackImage:[UIImage new] forState:UIControlStateNormal];
        [super setMinimumTrackImage:[UIImage new] forState:UIControlStateNormal];
        // We build views by ourself
        double r = self.trackHeight / 2;
        
        UIView *b;
        b = [self makeBar];
        b.layer.cornerRadius = r;
        b.backgroundColor = [UIColor colorWithHex:@"#444"];
        b.layer.shadowColor = [UIColor colorWithHex:@"#000"].CGColor;
        b.layer.shadowOpacity = 0.4;
        b.layer.shadowRadius = 2;
        self.trackView = b;
        
        b = [self makeBar];
        b.layer.cornerRadius = r;
        b.backgroundColor = [UIColor colorWithHex:@"#2FD"];
        b.layer.shadowColor = [UIColor colorWithHex:@"#2FD"].CGColor;
        b.layer.shadowOpacity = 1;
        b.layer.shadowRadius = 4;
        self.progressView = b;

        b = [self makeBar];
        b.backgroundColor = [UIColor colorWithHex:@"#fff"];
        self.anchorView = b;
        //self.backgroundColor = [UIColor colorWithHex:@"#fff"]; // to see shadow

        [self addSubview:self.trackView];
        [self addSubview:self.anchorView];
        [self addSubview:self.progressView];
        // Line order is z order, this is for thumb
        // top to down = thumb, progress, anchor, track
        [self sendSubviewToBack:self.progressView];
        [self sendSubviewToBack:self.anchorView];
        [self sendSubviewToBack:self.trackView];
    }
    if (phd) {
        self.thumbRes = FLSeekbar.myDefaultThumb;
        self.minimumTrackTintColor = [UIColor colorWithHex:@"#00997a"];
    }
}

- (UIView*) makeBar {
    UIView *b = [UIView new];
    b.userInteractionEnabled = false;
    b.clipsToBounds = false; // for shadow
    b.layer.shadowOffset = CGSizeMake(0, 0);
    return b;
}

- (void)setThumbRes:(FLRes *)r {
    [r applyThumbImageTo:self];
}

- (void) setMaximumTrackImage:(UIImage *)image forState:(UIControlState)state {
    if (android) {
        //[self.trackView setImage:image forState:state];
    } else {
        [super setMaximumTrackImage:image forState:state];
    }
}

- (void)setMinimumTrackImage:(UIImage *)image forState:(UIControlState)state {
    if (android) {
        //[self.progressView setImage:image forState:state];
    } else {
        [super setMinimumTrackImage:image forState:state];
    }
}

- (CGRect)trackRectForBounds:(CGRect)bounds {
    // no override
    return [super trackRectForBounds:bounds];
}

- (void) setTrackViewFrame:(CGRect)viewRect thumb:(CGSize)thumbSize {
    // parameters
    CGRect v = viewRect;
    double vw = v.size.width, vh = v.size.height;
    CGRect br = [super trackRectForBounds:v];
    CGSize th = thumbSize;

    // margin left
    double mg = br.origin.x;
    double thw = th.width;
    double tkh = self.trackHeight;
    double l = mg + thw / 2;
    double t = vh / 2 - tkh / 2;
    double w = vw - 2 * mg - thw;
    double h = tkh;
    CGRect g = CGRectMake(l, t, w, h);
    //qwe("Eval as give = %s", ssCGRect(g));
    //qwe("now = %s", ssString([FLStringKit now]));
    self.trackView.frame = g;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    if (android) {
        CGRect b = [super thumbRectForBounds:bounds trackRect:rect value:value];
        //qwe("thb : (b = %s, trk = %s, v = %f), super = %s", ssCGRect(bounds), ssCGRect(rect), value, ssCGRect(b));

        // Eval percentage as pq, pp, pa
        double pq = value - _anchorValue;
        double pp = [self percentOf:value];
        double pa = [self percentOf:_anchorValue];
        // If it is from the system default, it will have currentThumbImage.size = zero but super has values....
        CGSize th = self.currentThumbImage.size;
        if (th.width == 0 && th.height == 0) {
            th = b.size;
        }
        double thw = th.width, thh = th.height;

        // Set child frames
        [self setTrackViewFrame:bounds thumb:th];
        [self setAnchorViewFrameAt:pa];
        [self setProgressViewFrameAt:pp - pa];

        // Eval thumb frame
        CGRect f = self.progressView.frame;
        double fx = f.origin.x, fy = f.origin.y;
        double fw = f.size.width, fh = f.size.height;
        double r = fx;
        if (pq > 0) {
            r += fw;
        }

        double l = r - thw / 2;
        double t = bounds.size.height / 2 - thh / 2;
        double w = b.size.width;
        double h = b.size.height;
        CGRect ball = CGRectMake(l, t, w, h);
        //qw("v = %.3f, a = %.3f, %.3f ~ %.3f", value, _anchorValue, self.minimumValue, self.maximumValue);
        //qwe("pq = %.3f, pp = %.3f, pa = %.3f", pq, pp, pa);
        //qwe("now = %s", ssString([FLStringKit now]));
        return ball;
    } else {
        return [super thumbRectForBounds:bounds trackRect:rect value:value];
    }
}

// 0 = min, 1 = max, 0.5 = mid
- (double) percentOf:(double)v {
    double ans = 0;
    double min = self.minimumValue;
    double max = self.maximumValue;
    if (max != min) {
        ans = (v - min) / (max - min);
    }
    return ans;
}

// progress = anchor + diff
- (void) setProgressViewFrameAt:(double)p {
    CGRect f = self.trackView.frame;
    double fx = f.origin.x, fy = f.origin.y;
    double fw = f.size.width, fh = f.size.height;
    CGRect a = self.anchorView.frame;
    double ax = a.origin.x, ay = a.origin.y;
    //double aw = f.size.width, ah = f.size.height;
    double x = ax + _anchorWidth / 2;

    bool less = p < 0;
    double w = fw * fabs(p);
    double h = fh;
    double l = less ? (x - w) : (x);
    double t = fy;
    CGRect g = CGRectMake(l, t, w, h);
    //qwe("now = %s", ssString([FLStringKit now]));
    self.progressView.frame = g;
}

- (void) setAnchorViewFrameAt:(double)p {
    CGRect f = self.trackView.frame;
    double fx = f.origin.x, fy = f.origin.y;
    double fw = f.size.width, fh = f.size.height;

    double w = _anchorWidth;
    double h = _anchorHeight;
    double l = fx + fw * p - w / 2;
    double t = fy + fh / 2 - h / 2;
    CGRect g = CGRectMake(l, t, w, h);
    //qwe("now = %s", ssString([FLStringKit now]));
    self.anchorView.frame = g;
    self.anchorView.hidden = !_showAnchor;
}

+ (FLRes*) myDefaultThumb {
    return [FLRes normal:@"btn_scroll_n.png"
                 disable:@"btn_scroll_g.png"
                 pressed:@"btn_scroll_p.png"
                selected:@"btn_scroll_p.png"];
}

#pragma mark - Resources

+ (NSArray<FLRes*>*) testThumb {
    return @[
            // thumb.width > thumb.height
            [FLRes normal:@"fit_edge_n.png"
                  disable:@"fit_edge_n.png"
                  pressed:@"fit_edge_p.png"
                 selected:@"fit_edge_s.png"],
            // Big thumb
            [FLRes normal:@"add_layer_btn_opacity_n.png"
                  disable:@"add_layer_btn_opacity_n.png"
                  pressed:@"add_layer_btn_opacity_p.png"
                 selected:@"add_layer_btn_opacity_s.png"],
            // Big thumb
            [FLRes normal:@"add_n.png"
                  disable:@"add_g.png"
                  pressed:@"add_p.png"
                 selected:@"add_n.png"],
            // Small thumb, square
            [FLRes normal:@"brush_center_erase.png"
                  disable:@"brush_center_erase.png"
                  pressed:@"brush_center_erase.png"
                 selected:@"brush_center_erase.png"],
            // Small thumb
            [FLRes normal:@"brush_center_edit.png"
                  disable:@"brush_center_edit.png"
                  pressed:@"brush_center_edit.png"
                 selected:@"brush_center_edit.png"],
     ];
}

@end
