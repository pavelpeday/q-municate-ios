//
//  QMProfileViewController.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 3/24/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMProfileViewController.h"
#import "QMPlaceHolderTextView.h"
#import "REAlertView+QMSuccess.h"
#import "QMImageView.h"
#import "SVProgressHUD.h"
#import "REActionSheet.h"
#import "QMImagePicker.h"
#import "QMServicesManager.h"

@interface QMProfileViewController ()

<UITextFieldDelegate, UITextViewDelegate, QMImagePickerResultHandler>

@property (weak, nonatomic) IBOutlet QMImageView *avatarView;
@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet QMPlaceHolderTextView *statusField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *updateProfileButton;

@property (strong, nonatomic) NSString *fullNameFieldCache;
@property (copy, nonatomic) NSString *phoneFieldCache;
@property (copy, nonatomic) NSString *statusTextCache;

@property (nonatomic, strong) UIImage *avatarImage;

@end

@implementation QMProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.avatarView.imageViewType = QMImageViewTypeCircle;
    self.statusField.placeHolder = @"Add status...";
    
    [self updateProfileView];
    [self setUpdateButtonActivity];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateProfileView {
    
    QBUUser *currentUser = QM.profile.userData;
    
    self.fullNameFieldCache = currentUser.fullName;
    self.phoneFieldCache = currentUser.phone ?: @"";
    self.statusTextCache = currentUser.status ?: @"";
    
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    //    NSURL *url = [QMUsersUtils userAvatarURL:currentUser];
    
    [self.avatarView setImageWithURL:nil placeholder:placeholder options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        ILog(@"r - %ld; e - %ld", (long)receivedSize, (long)expectedSize);
    } completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    self.fullNameField.text = currentUser.fullName;
    self.emailField.text = currentUser.email;
    self.phoneNumberField.text = currentUser.phone;
    self.statusField.text = currentUser.status;
}

- (IBAction)changeAvatar:(id)sender {
    
    [REActionSheet presentActionSheetInView:self.view configuration:^(REActionSheet *actionSheet) {
        
        [actionSheet addButtonWithTitle:@"Take image" andActionBlock:^{
            [QMImagePicker takePhotoInViewController:self resultHandler:self];
        }];
        
        [actionSheet addButtonWithTitle:@"Choose from library" andActionBlock:^{
            [QMImagePicker choosePhotoInViewController:self resultHandler:self];
        }];
    }];
}

- (void)setUpdateButtonActivity {
    
    BOOL activity = [self fieldsWereChanged];
    self.updateProfileButton.enabled = activity;
}

- (IBAction)hideKeyboard:(id)sender {
    
    [sender resignFirstResponder];
}

- (IBAction)saveChanges:(id)sender {
    
    [self.view endEditing:YES];
    
    __weak __typeof(self)weakSelf = self;
    QBUUser *currentUser = QM.profile.userData;
    
    currentUser.fullName = weakSelf.fullNameFieldCache;
    currentUser.phone = weakSelf.phoneFieldCache;
    currentUser.status = weakSelf.statusTextCache;
    
    [SVProgressHUD showProgress:0.f status:nil maskType:SVProgressHUDMaskTypeClear];
    
    [QM.profile updateUserImage:self.avatarImage progress:^(float progress) {
         
         [SVProgressHUD showProgress:progress status:nil maskType:SVProgressHUDMaskTypeClear];
         
     } completion:^(BOOL success) {
         
         if (success) {
             weakSelf.avatarImage = nil;
             [weakSelf updateProfileView];
             [weakSelf setUpdateButtonActivity];
         }
         
         [SVProgressHUD dismiss];
     }];
}

- (BOOL)fieldsWereChanged {
    
    QBUUser *currentUser = QM.profile.userData;
    
    if (self.avatarImage) return YES;
    if (![self.fullNameFieldCache isEqualToString:currentUser.fullName]) return YES;
    if (![self.phoneFieldCache isEqualToString:currentUser.phone ?: @""]) return YES;
    if (![self.statusTextCache isEqualToString:currentUser.status ?: @""]) return YES;
    
    return NO;
}

#pragma mark - UITextFieldDelegate & UITextViewDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.fullNameField) {
        self.fullNameFieldCache = str;
    } else if (textField == self.phoneNumberField) {
        self.phoneFieldCache = str;
    }
    
    [self setUpdateButtonActivity];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    self.statusTextCache = textView.text;
    [self setUpdateButtonActivity];
}

#pragma mark - QMImagePickerResultHandler

- (void)imagePicker:(QMImagePicker *)imagePicker didFinishPickingPhoto:(UIImage *)photo {
    
    self.avatarImage = photo;
    [self.avatarView applyImage:photo];
    [self setUpdateButtonActivity];
}

@end
