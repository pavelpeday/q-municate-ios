//
//  QMImagePicker.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMImagePicker.h"
#import "REActionSheet.h"

@interface QMImagePicker()

<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (copy, nonatomic) QMImagePickerResult result;

@end

@implementation QMImagePicker

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

+ (void)presentInViewController:(UIViewController *)vc configure:(void (^)(UIImagePickerController *picker))configure resultImage:(QMImagePickerResult)resultImage {
    
    QMImagePicker *picker = [[QMImagePicker alloc] init];
    picker.result = resultImage;
    configure(picker);
    [vc presentViewController:picker animated:YES completion:nil];
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *key = picker.allowsEditing ? UIImagePickerControllerEditedImage: UIImagePickerControllerOriginalImage;
    UIImage *image = info[key];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        self.result(image);
        self.result = nil;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        self.result = nil;
    }];
}

+ (void)chooseSourceTypeInViewController:(UIViewController *)viewController allowsEditing:(BOOL)allowsEditing resultImage:(QMImagePickerResult)resultImage{

    void (^showImagePicker)(UIImagePickerControllerSourceType) = ^(UIImagePickerControllerSourceType type) {
        
        [QMImagePicker presentInViewController:viewController configure:^(UIImagePickerController *picker) {
            
            picker.sourceType = type;
            picker.allowsEditing = allowsEditing;
            
        } resultImage:resultImage];
    };
    
    [REActionSheet presentActionSheetInView:viewController.view configuration:^(REActionSheet *actionSheet) {
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QM_STR_TAKE_NEW_PHOTO", nil)
                         andActionBlock:^{
                             showImagePicker(UIImagePickerControllerSourceTypeCamera);
                         }];
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_FROM_LIBRARY", nil)
                         andActionBlock:^{
                             showImagePicker(UIImagePickerControllerSourceTypePhotoLibrary);
                         }];
        
        [actionSheet addCancelButtonWihtTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                               andActionBlock:^{}];
    }];
}

@end
