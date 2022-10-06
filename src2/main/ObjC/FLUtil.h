//
//  FLUtil.h
//  PhotoDirector
//
//  Created by Eric Chen on 2019/6/10.
//  Copyright © 2019 CyberLink. All rights reserved.
//

// TODO Makes all the methods to devoted classes and just one entry point to include all
#import <Foundation/Foundation.h>
#import "FLImageUtil.h"
#import "FLTicTac.h"
#import "FLUtil_Gesture.h"
#import "FLUIKit.h"
#import "FLCGUtil.h"
#import "FLLog.h"
#import "FLError.h"
#import "FLStringKit.h"
#import "FLFile.h"
#import "FLMath.h"

NS_ASSUME_NONNULL_BEGIN

@interface FLUtil : NSObject
/**
 * Copy array values from src to dst,
 * dst[0:n-1] <- src[0:n-1]
 */
void copyTo(long *dst, long *src, int n);

#pragma mark - Grand Central Dispatch for run async

/**
 * dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
 */
void runOnWorker(dispatch_block_t run);

/**
 * dispatch_async(dispatch_get_main_queue(),
 */
void runOnMain(dispatch_block_t run);


#pragma mark - Caterory

@end

NS_ASSUME_NONNULL_END

#pragma mark - Development notes
/*
 * 1. NSDictionary, NSArray, NSSet uses nil as terminated, so we cannot use primitive types of
 *    int, long, byte, char, float, double, we should use NSNumber*
 *    Also it may crashes when add nil object.
 *    Solution 1. using method to map to primitives,
 *             2. wrap primitives into NSNumber
 *
 * 2. In iOS system, the UIButton's touch event range is view.frame +- (x, x), with x ~= 30 (larger than the view)
 *    Let button = (100, 200) + (50, 40)
 *    So if the UIButton will change background color when pressed, it keeps press state when touch at (80, 180)
 *    and will no press state when distance is large enough
 *
 * 3. Take care if the string is not for i18n use, write 'N S L o c a l i z e d s t r i n g' makes XCode parser
 *    to take your key into i18n (E.g. Label will taken into translations by following line remove space)
 *    Since XCode parser should avoid those ambiguous items (like #define and parameters), but it does not. :(
 *    N S L o c a l i z e d S t r i n g ( @ " H e l l o " , n i l )
 *
 * 4. If set background color of UIStackView in storyboard/nib(*.xib), editor shows color while run with transparent color. :(
 *
 */
