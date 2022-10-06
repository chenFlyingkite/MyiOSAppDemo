//
//  FLAlertData.m
//  PhotoDirector
//
//  Created by Eric Chen on 2019/7/3.
//  Copyright © 2019 CyberLink. All rights reserved.
//

#import "FLAlertData.h"

@implementation FLAlertParam
- (instancetype)init {
    self = [super init];
    _style = UIAlertActionStyleDefault;
    return self;
}

+ (FLAlertParam *)ofTitle:(NSString *)title handler:(void (^ __nullable)(UIAlertAction *action))handler {
    FLAlertParam *p = [FLAlertParam new];
    p.title = title;
    p.handler = handler;
    return p;
}
@end

@implementation FLAlertData
- (instancetype) init {
    self = [super init];
    _title = @"Title";
    _message = @"Message";
    _style = UIAlertControllerStyleAlert;

    _ok = [FLAlertParam new];
    _ok.title = NSLocalizedString(@"OK", nil);

    _cancel = [FLAlertParam new];
    _cancel.title = NSLocalizedString(@"Cancel", nil);

    _actions = [NSMutableArray new];
    [_actions addObject:_ok];
    [_actions addObject:_cancel];
    return self;
}

- (instancetype) initWithButtons:(NSArray<FLAlertParam*>*)buttons {
    self = [super init];
    _actions = [NSMutableArray new];
    _style = UIAlertControllerStyleAlert;
    for(FLAlertParam *param in buttons) {
        [_actions addObject:param];
    }
    return self; 
}

- (UIAlertController*) get {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:_title message:_message preferredStyle:_style];
    
    long n = _actions.count;
    for (int i = 0; i < n; i++) {
        FLAlertParam *p = _actions[i];
        if (p) {
            UIAlertAction *aa = [UIAlertAction actionWithTitle:p.title style:p.style handler:p.handler];
            [a addAction:aa];
        }
    }
    return a;
}

- (UIAlertController*) show:(UIViewController*)vc {
    UIAlertController *a = [self get];
    [vc presentViewController:a animated:true completion:nil];
    return a;
}
@end
