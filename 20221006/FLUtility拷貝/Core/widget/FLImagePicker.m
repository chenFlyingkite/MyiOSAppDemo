//
//  FLImagePicker.m
//  PhotoDirector
//
//  Created by Eric Chen on 2019/7/3.
//  Copyright © 2019 CyberLink. All rights reserved.
//

#import "FLImagePicker.h"

@implementation FLImagePicker

- (instancetype)init {
    self = [super init];
    self.delegate = self;
    return self;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *m = info[UIImagePickerControllerOriginalImage];
    [_onPick onImagePicked:m info:info];
    [picker dismissViewControllerAnimated:true completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
}

@end
