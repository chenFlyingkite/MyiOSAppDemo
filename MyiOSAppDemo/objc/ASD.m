//
// Created by Eric Chen on 2021/3/7.
//

#import <MyiOSAppDemo-Swift.h>
#import "ASD.h"

@class ViewController;


@implementation ASD {

}

- (instancetype)init {
    self = [super init];
    //FLError
    int x = [ViewController gvc];
    int y = ViewController.vc;
    // System can only see NSLog, never for printf, fprintf...
    NSLog(@"Hello %@ %d", @"Eric Chen", y);
    printf("printf Hello %s, %d\n", "world", y);
    fprintf(stdin, "fprintf.stdin Hello %s, %d\n", "world", x);
    fprintf(stderr, "fprintf.stderr Hello %s, %d\n", "world", x);

    
    return self;
}
@end
