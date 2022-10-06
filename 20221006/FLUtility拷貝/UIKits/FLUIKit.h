//
// Created by Eric Chen on 2020/12/30.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLAnimate.h"
#import "UIColor+Hex.h"
#import "FLLog.h"
#import "FLNSKit.h"

@interface FLUIKit : NSObject

///       Red,     Yellow,      Green,       Cyan,       Blue,    Magenta,
///@"#FF0000", @"#FFFF00", @"#00FF00", @"#00FFFF", @"#0000FF", @"#FF00FF",
/// (Darker of above)
///@"#800000", @"#808000", @"#008000", @"#008080", @"#000080", @"#800080",
+ (NSArray<UIColor*>*) color12;

#pragma mark - test area

/**
 * @return indexPathOf2(r, 0)
 */
NSIndexPath* indexPathOf(long r);

/**
 * Index path's row = r, section = s
 * @return [NSIndexPath indexPathForRow:r inSection:s]
 */
NSIndexPath* indexPathOf2(long r, long s);


+ (CGRect) objcMeasureWrapWidth:(UILabel*) t;
+ (CGRect) objcMeasureWrapHeight:(UILabel*) t;
+ (CGRect) objcMeasureWrapContent:(UILabel*)t atMostWidth:(double)w;
+ (CGRect) objcMeasureWrapContent:(UILabel*)t atMostHeight:(double)h;
+ (CGRect) objcMeasureSize:(NSString*)str font:(UIFont*)font width:(double)width;
+ (CGRect) objcMeasureSize:(NSString*)str font:(UIFont*)font height:(double)height;
@end



#pragma mark - Caterory

@interface UICollectionView (Changed)
- (void) notifyItemChanged:(long)r;
- (void) notifyItemChanged2:(long)r section:(long)s;
@end

@interface UICollectionView (Nibs)
- (void) useNib:(NSString*) nibName cellId:(NSString*)id;
- (void) useNibCellId:(NSString*) nibName;
- (void) useClass:(Class)clazz cellId:(NSString*)id;
@end

@interface UICollectionViewCell (Color)

- (void) useSelectedBackgroundColor;
- (void) setSelectedBackgroundColor:(UIColor*)c;
- (NSString*) allState;
@end

@interface UIStackView (Child)

- (void) hideAllChildren:(bool)hidden;

@end

@interface UIView (Display)
- (void) bringToFront;
- (void) showThenHide:(bool)hide;
- (void) showThenHide:(bool)hide hideDuration:(NSTimeInterval)second;
- (void) showThenHide:(bool)hide data:(FLAnimate *)data;
@end

@interface UIView (Point)
- (CGRect) getLocationOnScreen;
- (void) logChild;
@end

@interface UIView (Log)
- (NSString*) flState;
@end

@interface UIControl (SendEvent)
- (void) callOnClick;
@end

@interface UITextView (Basis)

/// No extra inner text padding
- (void) noPadding;

/// Scroll to last character by UITextView#scrollRangeToVisible(Range(last, 0))
- (void) scrollsToBottom;
@end

@interface UIApplication (Finder)
+ (__kindof UIViewController *) topViewController;
@end


@interface UIView (Animation)
- (void) moveUp;
@end

@interface UIView (BFS)
/**
 * Returns all subviews added in self, of course includes children's subviews
 */
- (NSArray<UIView*> *) allSubviews;

- (void) removeAllSubviews;
- (void) hideAllSubviews;
- (void) showAllSubviews;
- (void) runAllSubviews:(void(^)(UIView*))run;
@end

//-- Test
// yes = 1, 0.5, 0.3, 0.1
// no = 0, 0.01,
//self.resetButton.alpha = 0; // strange that 0.01 = no click?
