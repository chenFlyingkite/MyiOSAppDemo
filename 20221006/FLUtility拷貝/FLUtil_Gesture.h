//
//  FLUtil_Gesture.h
//  PhotoDirector
//
//  Created by Eric Chen on 2019/7/25.
//  Copyright © 2019 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface FLUtil_Gesture : NSObject

#pragma mark - Gestures
void useGesture(bool enable, UIView *v, UIGestureRecognizer *r);

@end

#pragma mark - Runnable
@protocol Runnable <NSObject>

- (void) run;

@end

#pragma mark - Gesture Actor, helper for our Easy Gestures
@interface FLGestureActor : NSObject

/*!
 * Targeted UIView (of actor) to receive events and respond to
 */
@property (nonatomic, strong) UIView *actor;

/*!
 * True = use gesture to move, False = remove gesture
 * Default = true
 */
@property (nonatomic) bool active;
@end

#pragma mark -

@interface FLMoveViewByPan2 : UIPanGestureRecognizer

/*!
 * Target UIView to receive pan event to move itself
 */
@property (nonatomic, strong) UIView *move;

/*!
 * True = use gesture to move, False = remove gesture
 * Default = true
 */
@property (nonatomic) bool active;

- (instancetype) initWithMove:(nullable UIView*)move;
- (SEL) getOnPan;
@end

#pragma mark - Move by Pan

/*!
 * Easy class to make view having pan to move gesture
 * E.g. We want to make UIView *view to have gesture of pan to move
 *
 * Usage 1 :
 * FLMoveViewByPan *p = [[FLMoveViewByPan alloc] initByView:view];
 *
 * Usage 2 :
 * FLMoveViewByPan *p = [FLMoveViewByPan new]; // or alloc + init
 * p.act.actor = view;
 * p.act.active = true; // Can omit this line since default is true
 */
@interface FLMoveViewByPan : UIPanGestureRecognizer

/*!
 * act.actor :
 *     Target UIView to receive pan event to move itself
 * act.active :
 *     True = use gesture to move, False = remove gesture
 *     Default = true
 */
@property (nonatomic, strong) FLGestureActor *act;

/*!
 * Create gesture by pan to move view
 */
- (instancetype) initByView:(nullable UIView*)view;
- (SEL) getOnPan;
@end

NS_ASSUME_NONNULL_END
