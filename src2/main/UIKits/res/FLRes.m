//
// Created by Eric Chen on 2020/12/31.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import "FLRes.h"
#import "UIColor+Hex.h"
#import "FLImageView.h"
#import "FLImageUtil.h"

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCSimplifyInspectionLegacy"
// Class for entry into { "n", UIControlStateNormal, values["n"] }
@interface KVC : NSObject
@property (nonatomic, weak) NSString *k;
@property (nonatomic, weak) NSString *v;
@property (nonatomic) UIControlState c;
@end
@implementation KVC

@end

@implementation FLRes {

}

+ (instancetype)all:(NSString *)all {
    return [FLRes normal:all disable:all pressed:all selected:all];
}

+ (instancetype)normal:(NSString *)n disable:(NSString *)d pressed:(NSString *)p selected:(NSString*) s {
    FLRes *r = [FLRes new];
    r.values = @{
            @"n" : n ?: @"",//UIControlStateNormal : n,
            @"d" : d ?: @"",//UIControlStateDisabled : d,
            @"p" : p ?: @"",//UIControlStateHighlighted : p,
            @"s" : s ?: @"",//UIControlStateSelected : s,
    };
    return r;
}

- (instancetype) deepCopy {
    return [FLRes normal:self.values[@"n"]
                 disable:self.values[@"d"]
                 pressed:self.values[@"p"]
                selected:self.values[@"s"]];
}

- (UIControlState) to:(NSString*) s {
    if ([s is:@"n"]) return UIControlStateNormal;
    if ([s is:@"d"]) return UIControlStateDisabled;
    if ([s is:@"p"]) return UIControlStateHighlighted;
    if ([s is:@"s"]) return UIControlStateSelected;
    return UIControlStateNormal;
}

- (NSArray<KVC*>*) allEntry {
    NSMutableArray *a = [NSMutableArray new];
    for (NSString* k in self.values.allKeys) {
        UIControlState c = [self to:k];
        NSString *v = self.values[k];
        KVC *z = [KVC new];
        z.k = k;
        z.v = v;
        z.c = c;
        [a addObject:z];
    }
    return a;
}

- (NSString* )description {
    return self.values.description;
}

- (NSDictionary<NSString*, UIColor*>*) hexColor {
    NSMutableDictionary<NSString*, UIColor*>* d = [NSMutableDictionary new];
    for (NSString *k in self.values.allKeys) {
        NSString *v = self.values[k];
        UIColor *c = [UIColor colorWithHex:v];
        d[k] = c;
    }
    return d;
}

- (bool) hasState:(UIControlState)s on:(UIControlState)src {
    return (src & s) == s;
}

- (NSString *) keyOf:(UIControlState)s {
    bool sel = [self hasState:UIControlStateSelected on:s];
    bool hig = [self hasState:UIControlStateHighlighted on:s];
    bool ena = ! [self hasState:UIControlStateDisabled on:s];
    if (ena) {
        if (hig) {
            return @"p";
        } else if (sel) {
            return @"s";
        }
        return @"n";
    } else {
        return @"d";
    }
}

#pragma mark - Internal Methods

- (__kindof UIView*) applyImageTo:(__kindof UIView*) b run:(void(^)(__kindof UIView*, UIImage*, UIControlState))run {
    for (KVC* z in self.allEntry) {
        NSString *k = z.k;
        NSString *v = z.v;
        UIControlState c = z.c;

        if (v.length > 0) {
            UIImage *m = [UIImage imageNamed:v];
            if (!m) {
                qwe("Image not found for : %s", ssString(v));
            }

            run(b, m, c);
        }
    }
    return b;
}

- (__kindof UIView*) applyTitleTo:(__kindof UIView*)b run:(void(^)(__kindof UIView*, NSString *, UIControlState))run{
    for (KVC* z in self.allEntry) {
        NSString *k = z.k;
        NSString *v = z.v;
        UIControlState c = z.c;

        run(b, v, c);
    }
    return b;
}

- (__kindof UIView*) applyColorTo:(__kindof UIView*) b run:(void(^)(__kindof UIView*, UIColor*, UIControlState))run {
    for (KVC* z in self.allEntry) {
        NSString *k = z.k;
        NSString *v = z.v;
        UIControlState c = z.c;

        UIColor *r = [UIColor colorWithHex:v];
        run(b, r, c);
    }
    return b;
}

#pragma mark - apply to UIButton
+ (__kindof UIButton*) applyAllTitle:(NSString*)s to:(__kindof UIButton*) b {
    FLRes *r = [FLRes all:s];
    return [r applyTitleTo:b];
}

- (__kindof UIView*) applyImageTo:(__kindof UIView*) b{
    //qwe("apply image to %s", ssString(b));
    id run;
    if ([b isKindOfClass:UIButton.class]) {
        run = ^(__kindof UIView* b, UIImage* m, UIControlState c) {
            //qwe("is UIButton, %s", ssString(b));
            UIButton* v = b;
            [v setImage:m forState:c];
        };
    } else if ([b isKindOfClass:UIImageView.class]) {
        run = ^(__kindof UIView* b, UIImage* m, UIControlState c) {
            //qwe("is UIImageView %s", ssString(b));
            UIImageView* v = b;
            if (c == UIControlStateNormal) {
                v.image = m;
            } else if (c == UIControlStateDisabled) {
            } else if (c == UIControlStateHighlighted) {
                v.highlightedImage = m;
            } else if (c == UIControlStateSelected) {
            } else {
            }
        };
    } else {
        qwe("Failed to set image for %s", ssString(b));
    }
    if (run) {
        [self applyImageTo:b run:run];
    }
    return b;
}

- (__kindof UIButton*) applyTitleTo:(__kindof UIButton*) b {
    [self applyTitleTo:b run:^(__kindof UIButton* v, NSString *s, UIControlState c) {
        [v setTitle:s forState:c];
    }];
    return b;
}

- (__kindof UIButton*) applyTitleColorTo:(__kindof UIButton*) b {
    [self applyColorTo:b run:^(__kindof UIButton *v, UIColor *r, UIControlState c) {
        [v setTitleColor:r forState:c];
    }];
    return b;
}

- (__kindof UIButton*) applyBackgroundImageTo:(__kindof UIButton*) b {
    [self applyImageTo:b run:^(__kindof UIButton *v, UIImage *m, UIControlState c) {
        [v setBackgroundImage:m forState:c];
    }];
    return b;
}

- (__kindof UIView*) applyBackgroundColorTo:(__kindof UIView*) b {
    //qwe("apply image to %s", ssString(b));
    id run;
    if ([b isKindOfClass:FLImageView.class]) {
        FLImageView* v = b;
        v.BGColors = [self deepCopy];
    } else if ([b isKindOfClass:UIButton.class]) {
        run = ^(__kindof UIView* b, UIColor* r, UIControlState c) {
            //qwe("is UIButton, %s", ssString(b));
            UIButton* v = b;
            UIImage *m = [FLImageUtil ofSolid:r width:1 height:1];
            [v setImage:m forState:c];
        };
    } else if ([b isKindOfClass:UIImageView.class]) {
        run = ^(__kindof UIView* b, UIColor* r, UIControlState c) {
            //qwe("is UIImageView %s", ssString(b));
            UIImageView* v = b;
            if (c == UIControlStateNormal) {
                UIImage *m = [FLImageUtil ofSolid:r width:1 height:1];
                v.image = m;
            } else if (c == UIControlStateDisabled) {
            } else if (c == UIControlStateHighlighted) {
                UIImage *m = [FLImageUtil ofSolid:r width:1 height:1];
                v.highlightedImage = m;
            } else if (c == UIControlStateSelected) {
            } else {
            }
        };
    } else {
        qwe("Failed to set image for %s", ssString(b));
    }
    if (run) {
        [self applyColorTo:b run:run];
    }
    return b;
}

- (__kindof UISlider*) applyThumbImageTo:(__kindof UISlider*) s {
    [self applyImageTo:s run:^(__kindof UISlider* a, UIImage* m, UIControlState c) {
        [a setThumbImage:m forState:c];
    }];
    return s;
}

@end

#pragma clang diagnostic pop