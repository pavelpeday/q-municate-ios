//
//  QMImagePicker.h
//  Q-municate
//
//  Created by Andrey Ivanov on 11.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^QMImagePickerResult)(UIImage *image);

@interface QMImagePicker : UIImagePickerController

/**
 *  Pressent image picker
 *
 *  @param vc          Source view controller
 *  @param configure   Block configuration
 *  @param resultImage Result image
 */
+ (void)presentInViewController:(UIViewController *)vc configure:(void (^)(UIImagePickerController *picker))configure resultImage:(QMImagePickerResult)resultImage;

+ (void)chooseSourceTypeInViewController:(UIViewController *)viewController allowsEditing:(BOOL)allowsEditing resultImage:(QMImagePickerResult)resultImage;

@end
