//
// Created by Eric Chen on 2020/12/30.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import "FLUIKit.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wsign-conversion"
#pragma clang diagnostic ignored "-Wimplicit-int-conversion"
@interface FLUIKit()
@end
@implementation FLUIKit {
}
static NSArray<UIColor*>* sColor_12;

//+ (void)initialize {
//
//    qwe("FLUIKit %s", "init");
//}

// https://en.wikipedia.org/wiki/RGB_color_model in zh
+ (NSArray<UIColor*>*) color12 {
    if (sColor_12) {
        return sColor_12;
    }
    // Building the color12
    NSArray<NSString*> *cs = @[
        @"#FF0000", @"#FFFF00", @"#00FF00", @"#00FFFF", @"#0000FF", @"#FF00FF",
        @"#800000", @"#808000", @"#008000", @"#008080", @"#000080", @"#800080",
    ];
    // By ints
//    NSArray* cs = @[
//        @(0xFFFF0000), @(0xFFFFFF00), @(0xFF00FF00), @(0xFF00FFFF), @(0xFF0000FF), @(0xFFFF00FF),
//        @(0xFF800000), @(0xFF808000), @(0xFF008000), @(0xFF008080), @(0xFF000080), @(0xFF800080),
//    ];
    NSMutableArray<UIColor*>* c = [NSMutableArray new];
    for (int i = 0; i < cs.count; i++) {
        UIColor *x = [UIColor colorWithHex:cs[i]];
        //UIColor *x = [UIColor colorWithInt:[cs[i] intValue]];//calls intValue...
        [c add:x];
    }
    sColor_12 = c;
    return c;
}

#pragma mark - test area
// + (int) addAbaSeD:(NSString*) s and:(NSString*)t
// => FLUIKit.addAbaSeD(, and: )
//+ (int) addAbaSed:(NSString*) s and:(NSString*)t {
// + (int) addAbaTo:(NSString*) s and:(NSString*)t {
// => .addAba(to: , and: )
+ (int) addAba_to:(NSString*) s and:(NSString*)t {
    return 0;
}


#pragma mark - NSIndexPath

NSIndexPath* indexPathOf(long r) {
    return indexPathOf2(r, 0);
}

NSIndexPath* indexPathOf2(long r, long s) {
    return [NSIndexPath indexPathForRow:r inSection:s];
}

//--
+ (CGRect) objcMeasureWrapWidth:(UILabel*) t {
    double h = t.frame.size.height;
    return [FLUIKit objcMeasureWrapContent:t atMostHeight:h];
}

+ (CGRect) objcMeasureWrapHeight:(UILabel*) t {
    double w = t.frame.size.width;
    return [FLUIKit objcMeasureWrapContent:t atMostWidth:w];
}

+ (CGRect) objcMeasureWrapContent:(UILabel*)t atMostWidth:(double)w {
    NSString *s = t.text ?: @"";
    return [FLUIKit objcMeasureSize:s font:t.font width:w];
}

+ (CGRect) objcMeasureWrapContent:(UILabel*)t atMostHeight:(double)h {
    NSString *s = t.text ?: @"";
    return [FLUIKit objcMeasureSize:s font:t.font height:h];
}

+ (CGRect) objcMeasureSize:(NSString*)str font:(UIFont*)font width:(double)width {
    CGSize z = CGSizeMake(width, INT_MAX);
    NSStringDrawingOptions opt = NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary<NSAttributedStringKey, id> *dict = @{
        NSFontAttributeName : font,
            //@"font" : font,
    };
    CGRect r = [str boundingRectWithSize:z options:opt attributes:dict context:nil];

    CGRect ans = CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height + 1);
    return ans;
}


+ (CGRect) objcMeasureSize:(NSString*)str font:(UIFont*)font height:(double)height {
    CGSize z = CGSizeMake(INT_MAX, height);
    NSStringDrawingOptions opt = NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary<NSAttributedStringKey, id> *dict = @{
            NSFontAttributeName : font,
            //@"font" : font,
    };
    CGRect r = [str boundingRectWithSize:z options:opt attributes:dict context:nil];

    CGRect ans = CGRectMake(r.origin.x, r.origin.y, r.size.width + 1, r.size.height);
    return ans;
}
// right + 1 is to make additional space for it, too compact may make text still truncated
//class func measureSize(_ str: String, _ font:UIFont, height: Double) -> CGRect {
//    let r = NSString(string: str).boundingRect(with: CGSize(width: 1.0 * Int.max, height: height),
//    options: .usesLineFragmentOrigin,
//            attributes: [.font: font],
//    context: nil)
//    let ans = CGRect(l: r.left, t: r.top, r: r.right + 1, b: r.bottom)
//    return ans
//}
@end


#pragma mark - Caterory

@implementation UICollectionView (Changed)

- (void) notifyItemChanged:(long)r {
    [self notifyItemChanged2:r section:0];
}

- (void) notifyItemChanged2:(long)r section:(long)s {
    if (r < 0 || s < 0) return;

    NSMutableArray<NSIndexPath*>* a = [NSMutableArray new];
    [a addObject:indexPathOf2(r, s)];
    [self reloadItemsAtIndexPaths:a];
}
@end

@implementation UICollectionView (Nibs)
- (void) useNib:(NSString*)nibName cellId:(NSString*)id {
    UINib* nib = [UINib nibWithNibName:nibName bundle:nil];
    [self registerNib:nib forCellWithReuseIdentifier:id];
}

- (void) useNibCellId:(NSString*) nibName {
    [self useNib:nibName cellId:nibName];
}

- (void) useClass:(Class)clazz cellId:(NSString*)id {
    [self registerClass:clazz forCellWithReuseIdentifier:id];
}

@end

@implementation UICollectionViewCell (Color)

- (void) useSelectedBackgroundColor {
    // PhotoDirector style blue-green
    UIColor *c = [UIColor colorWithHex:@"#a030e0c8"];
    [self setSelectedBackgroundColor: c];
}

- (void) setSelectedBackgroundColor:(UIColor*) c {
    UIView *v = [[UIView alloc] initWithFrame:self.selectedBackgroundView.frame];
    v.backgroundColor = c;
    self.selectedBackgroundView = v;
}

- (NSString*) allState {
    UIView *bg = self.backgroundView;
    UIView *sbg = self.selectedBackgroundView;
    return [FLStringKit joins:@[
            self.highlighted ? @"P" : @"-",
            self.selected ? @"S" : @"-",
            bg ? @"bn" : @"--",
            bg ? bg.backgroundColor.hex : @"#------",
            sbg ? @"bs" : @"--",
            sbg ? sbg.backgroundColor.hex : @"#------",
    ]];
}

@end

@implementation UIStackView (Child)

- (void) hideAllChildren:(bool)hidden {
    int n = self.subviews.count;
    for (int i = 0; i < n; i++) {
        self.subviews[i].hidden = hidden;
    }
}

@end

@implementation UIView (Display)

- (void) bringToFront {
    UIView *v = self.superview;
    [v bringSubviewToFront:self];
}

- (void) showThenHide:(bool)hide {
    FLAnimate *a = [FLAnimate new];
    [self showThenHide:hide data:a];
}

- (void) showThenHide:(bool)hide hideDuration:(NSTimeInterval)second {
    FLAnimate *a = [FLAnimate new];
    a.duration = second;
    [self showThenHide:hide data:a];
}

- (void) showThenHide:(bool)hide data:(FLAnimate *)data {
    self.alpha = 1;
    self.hidden = false;
    if (hide) {
        // TODO : View will blink if we call method with hide = true then false
        // TODO : Animation did not clear..., Maybe use CAAnimation ?
        [self.layer removeAllAnimations];
        if (data) {
            [UIView animateWithDuration: data.duration
                                  delay: 1.0
                                options: 0
                             animations: ^{
                                 self.alpha = 0;
                                 if (data.animate) {
                                     data.animate();
                                 }
                             }
                             completion:^(BOOL finished) {
                                 self.alpha = 1;
                                 self.hidden = true;
                                 if (data.completion) {
                                     data.completion(finished);
                                 }
                             }];
        }
    }
}

@end

@implementation UIView (Point)
- (CGRect) getLocationOnScreen {
    return [self.superview convertRect:self.frame toView:nil];
}

- (void) logChild {
    //qw("----%s", "");
    int n = self.subviews.count;
    qw("----.f = %s, %ld child in = %s", ssCGRect(self.frame), n, ssString(self));
    for (int i = 0; i < n; i++) {
        UIView* v = self.subviews[i];
        qw("#%d: .f = %-27s, v = %s", i, ssCGRect(v.frame), ssString(v));
        if ([v isKindOfClass:UIButton.class]) {
            UIButton* b = (UIButton *) v;
            qw("text = %s", ssString(b.currentTitle));
        }
        NSArray *c = v.constraints;
        int k = c.count;
        qw("   has %ld layout constraints", k);
        if (k > 0) {
            [v.constraints printAll];
        }
    }
}
@end


@implementation UIControl (SendEvent)
- (void) callOnClick {
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}
@end

@implementation UITextView (Basis)

- (void) noPadding {
    self.textContainer.lineFragmentPadding = 0;
    self.textContainerInset = UIEdgeInsetsZero;
}

- (void) scrollsToBottom {
    NSRange r = NSMakeRange(self.text.length, 0);
    [self scrollRangeToVisible:r];
}
@end

@implementation UIApplication (Finder)
+ (__kindof UIViewController *) topViewController {
    UIViewController *p = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (p.presentedViewController) {
        p = p.presentedViewController;
    }
    return p;
}
@end

@implementation UIView (Animation)
- (void) moveUp {
    UIView* v = self;
    double second = 0.3;
    double h = v.frame.size.height;
    CGRect b = v.bounds;
    // it is strange that using CGRectOffset(b, 0, h) will be move down...
    // is origin at left bottom?
    CGRect under = CGRectOffset(b, 0, -h); // b.y += h
    v.clipsToBounds = YES; // No drawing outside
    v.bounds = under;
    // Using v.frame will makes view still appear when out of frame

    [UIView animateWithDuration:second delay:0 options:UIViewAnimationOptionCurveEaseOut
                     animations: ^ { v.bounds = b; }
                     completion:nil];
}
@end

@implementation UIView (BFS)
- (NSArray<UIView*> *) allSubviews {
    NSMutableArray<UIView*> *a = [NSMutableArray new];
    [a addAll:self.subviews];
    int at = 0;
    while (at < a.count) {
        UIView* v = a[at];
        if (v && v.subviews.count > 0) {
            [a addAll:v.subviews];
        }
        at++;
    }
    return a;
}

- (void)removeAllSubviews {
    NSArray<UIView*>* v = self.allSubviews;
    for (UIView* x in v) {
        [x removeFromSuperview];
    }
}

- (void)hideAllSubviews {
    [self runAllSubviews:^(UIView* v) {
        v.hidden = true;
    }];
}

- (void)showAllSubviews {
    [self runAllSubviews:^(UIView* v) {
        v.hidden = false;
    }];
}

- (void)runAllSubviews:(void(^)(UIView*))run {
    NSArray<UIView*>* v = self.allSubviews;
    for (UIView* x in v) {
        run(x);
    }
}
@end

@implementation UIView (Log)
- (NSString*) flState {
    CGRect z;
    z = self.frame;
    NSString *f = [@"" addF:@"(%.1f, %.1f)-(%.1f, %.1f)", z.origin.x, z.origin.y, z.origin.x + z.size.width, z.origin.y + z.size.height];
    z = self.bounds;
    NSString *b = [@"" addF:@"(%.1f, %.1f)-(%.1f, %.1f)", z.origin.x, z.origin.y, z.origin.x + z.size.width, z.origin.y + z.size.height];
    int n;
    n = self.subviews.count;
    NSString *c = [@"" addF:@", %d child", n];
    n = self.constraints.count;
    NSString *x = [@"" addF:@", %d limits", n];
    NSString *a = [@"" addF:@", alpha = %.4f", self.alpha];
    NSString *bg = @"#--------";
    if (self.backgroundColor) {
        bg = self.backgroundColor.hex;
    }
    NSString *r = [@"" addF:@"%.1f", self.layer.cornerRadius];

    return [FLStringKit joins:@[
            self.isHidden ? @"H" : @"V",
            self.userInteractionEnabled ? @"E" : @"-",
            //self.isOpaque ? @"O" : @"-",
            //self.clipsToBounds ? @"C" :@"-",
            a, @", bg = ", bg, @", r = ", r,
            @"\n, f = ", f,@", b = ", b,
            @"\n", c, x, @", window=", self.window,@", super=", self.superview
    ]];
}
@end

#pragma clang diagnostic pop