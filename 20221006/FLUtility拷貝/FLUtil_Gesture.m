//
//  FLUtil_Gesture.m
//  PhotoDirector
//
//  Created by Eric Chen on 2019/7/25.
//  Copyright © 2019 CyberLink. All rights reserved.
//

#import "FLUtil_Gesture.h"

@implementation FLUtil_Gesture

#pragma mark - Gestures
/*!
 * Guessing source code of Add/Remove gesture recognizer of r to v
 * -> 1. Remove r from r.view.gestureRecgnizer
 * -> 2. If enable = true  => Add r to v.gestureRecognizer
 * So if two views want to have same recognizer handling
 * -> Please alloc & init two recognizers and add to each view separately
 *
 * if v1 = [r1, r2], v2 = [r3, r4] and
 * Case A : v1.addGestureRecognizer(r2) = unchanged
 * Case B : v2.addGestureRecognizer(r2) -> v1 = [r1], v2 = [r3, r4, r2]
 * Case C : v1.removeGestureRecognizer(r3) = unchanged
 */
void useGesture(bool enable, UIView *v, UIGestureRecognizer *r) {
    if (r == nil) return;

    if (enable) {
        [v addGestureRecognizer:r];
    } else {
        [v removeGestureRecognizer:r];
    }
}

@end

#pragma mark -

@interface FLGestureActor() {}
@property (nonatomic, strong) UIGestureRecognizer *owner;
@end

@implementation FLGestureActor

- (void) setActor:(UIView*)actor {
    _actor = actor;
    [self update];
}

- (void) setActive:(bool)active {
    _active = active;
    [self update];
}

- (void) update {
    useGesture(_active, _actor, _owner);
}

@end


#pragma mark -

@interface FLMoveViewByPan()
@end

@implementation FLMoveViewByPan

- (instancetype) init {
    self = [self initByView:nil];
    return self;
}

- (instancetype) initByView:(UIView*)view {
    self = [self initWithTarget:self action:[self getOnPan]];
    _act = [FLGestureActor new];
    _act.actor = view;
    _act.active = true;
    _act.owner = self;
    [_act update]; // Since previous setters passes method for owner = nil
    return self;
}


- (SEL) getOnPan {
    return @selector(onPan:);
}

- (void) onPan: (UIPanGestureRecognizer*) rec {
    UIView *v = _act.actor; // v = view to move
    
    CGPoint p = [rec translationInView:v];
    CGPoint c = v.center;
    c = offsetPoint(c, p);
    v.center = c;
    
    // We reset to (0, 0) for next onPan to get translation as each change
    // That is, p = p_(t+1) - p_t
    // Or we will get the point directly from p_t
    [rec setTranslation:CGPointZero inView:v];
}

@end

/*
- (void)viewDidRotate:(UIRotationGestureRecognizer*)sender {
    
}
 */

