//
//  FLImagePicker.h
//  PhotoDirector
//
//  Created by Eric Chen on 2019/7/3.
//  Copyright © 2019 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FLImagePicked <NSObject>

- (void) onImagePicked:(UIImage*)image info:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info;


@end

@interface FLImagePicker : UIImagePickerController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) id<FLImagePicked> onPick;

@end
//FLImagePicker : NSObject

//@end

NS_ASSUME_NONNULL_END
