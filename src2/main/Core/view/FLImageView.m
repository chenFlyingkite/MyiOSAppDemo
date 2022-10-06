//
// Created by Eric Chen on 2020/12/22.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import "FLImageView.h"
#import "FLRes.h"
#import "UIColor+Hex.h"

@implementation FLImageView {
    NSDictionary<NSString*, UIColor*>* bgColors;
    NSDictionary<NSString*, UIColor*>* bdColors;
}

- (instancetype)initWithFrame:(CGRect)frame {
    //qwe("~ initWithFrame(%s), self.frame = %s", ssCGRect(frame), ssCGRect(self.frame));
    self = [super initWithFrame:frame];
    //qwe("v initWithFrame(..), self.frame = %s", ssCGRect(self.frame));
    [self setup];
    return self;
}

// From Storyboard...
- (instancetype)initWithCoder:(NSCoder *)coder {
    //qwe("~ initWithCoder(coder) self.frame = %s", ssCGRect(self.frame));
    self = [super initWithCoder:coder];
    //qwe("v initWithCoder(..), self.frame = %s, coder = %s", ssCGRect(self.frame), ssString(coder));
    [self setup];
    return self;
}

- (void) setup {
    // Should also apply self.buttonType = UIButtonTypeCustom in Storyboard...
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.titleLabel.adjustsFontSizeToFitWidth = true;
}

#pragma mark - Set background state
- (void)setBGColors:(FLRes *)res {
    //qwe("set bg %s", ssString(res));
    _BGColors = res;
    if (res) {
        bgColors = res.hexColor;
    }
    [self updateBGColor];
}

- (void)setBDColors:(FLRes *)res {
    //qwe("set bd %s", ssString(res));
    _BDColors = res;
    if (res) {
        bdColors = res.hexColor;
    }
    [self updateBDColor];
}

#pragma mark - press state
- (void)setSelected:(BOOL)selected {
    //qwe("%s", "s");
    bool changed = self.isSelected != selected;
    [super setSelected:selected];
    if (changed) {
        [self updateColors];
    }
}

//  TODO click has no highlighted???
- (void)setHighlighted:(BOOL)highlighted {
    //qwe("%s", "p");
    // or use ^ ?
    // bool changed = self.isHighlighted ^ highlighted;
    bool changed = self.isHighlighted != highlighted;
    [super setHighlighted:highlighted];
    if (changed) {
        [self updateColors];
    }
}

- (void)setEnabled:(BOOL)enabled {
    //qwe("%s", "e");
    bool changed = self.isEnabled != enabled;
    [super setEnabled:enabled];
    if (changed) {
        [self updateColors];
    }
}

- (void) updateColors {
    [self updateBGColor];
    [self updateBDColor];
}

// failed...
//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    qwe("drawRect %s", ssCGRect(rect));
//    [self updateBGColor];
//}

// We have to set it in states, since the set selected states will not calls needsDisplay
- (void) updateBGColor {
    if (bgColors && _BGColors) {
        UIControlState s = self.state;
        NSString *k = [_BGColors keyOf:s];
        CGColorRef c = bgColors[k].CGColor;
        //qwe("set color %s = %s", ssString(k), ssString(bgColors[k]));
        self.layer.backgroundColor = c;
    } else {
        // should we ?
        //self.layer.backgroundColor = nil;
    }
}

// We have to set it in states, since the set selected states will not calls needsDisplay
- (void) updateBDColor {
    if (bdColors && _BDColors) {
        UIControlState s = self.state;
        NSString *k = [_BDColors keyOf:s];
        CGColorRef c = bdColors[k].CGColor;
        //qwe("set color %s = %s", ssString(k), ssString(bgColors[k]));
        self.layer.borderColor = c;
    } else {
        // should we ?
        //self.layer.backgroundColor = nil;
    }
}

#pragma mark - testing
//- (void)drawRect:(CGRect)rect {
//    self.layer.backgroundColor;
//}

- (void)setBackXyz:(UIColor *)color {
    self.layer.backgroundColor = color.CGColor;
}

- (void)drawRectX:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // Start drawing
    CGContextSaveGState(ctx);
//    NSArray<double> *a = [self.backXyz getRgba];
//    CGContextSetRGBFillColor(ctx, a[0], a[1], a[2], a[3]);
//    CGContextSetRGBStrokeColor(ctx, a[0], a[1], a[2], a[3]);
    CGContextFillRect(ctx, rect);
    CGContextRestoreGState(ctx);
}
#pragma mark - testing parent open method
/*
- (CGRect)backgroundRectForBounds:(CGRect)bounds {
    CGRect r = [super backgroundRectForBounds:bounds];
    return r;
}

- (CGRect)contentRectForBounds:(CGRect)bounds {
    CGRect r = [super contentRectForBounds:bounds];
    return r;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect r = [super titleRectForContentRect:contentRect];
    return r;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGRect r = [super imageRectForContentRect:contentRect];
    return r;
}
*/



@end
