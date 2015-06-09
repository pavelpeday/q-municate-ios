//
//  QMSignUpController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSignUpVC.h"
#import "QMLicenseAgreement.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"
#import "QMImagePicker.h"
#import "QMServicesManager.h"
#import "QMPlaceholder.h"
#import "QMImageView.h"

@interface QMSignUpVC ()

@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet QMImageView *qmImageView;

@property (strong, nonatomic) UIImage *selectedImage;

@end

@implementation QMSignUpVC

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.qmImageView.imageViewType = QMImageViewTypeCircle;
    self.qmImageView.image = [QMPlaceholder ovalWithFrame:self.qmImageView.bounds text:@"" color:[UIColor lightGrayColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - Actions

- (IBAction)hideKeyboard:(id)sender {
    
    [sender resignFirstResponder];
}

- (IBAction)chooseUserPicture:(id)sender {
    
    [QMImagePicker chooseSourceTypeInViewController:self allowsEditing:YES resultImage:^(UIImage *image) {

        self.selectedImage = image;
        [self.qmImageView applyImage:image];
    }];
}

- (IBAction)pressentUserAgreement:(id)sender {
    
    [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self completion:nil];
}

- (IBAction)done:(id)sender {
    
    if (self.fullNameField.text.length == 0 ||
        self.passwordField.text.length == 0 ||
        self.emailField.text.length == 0) {
        
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil) actionSuccess:NO];
    }
    else {
        
        __weak __typeof(self)weakSelf = self;
        [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self completion:^(BOOL userAgreementSuccess) {
            
            if (userAgreementSuccess) {
                
                QBUUser *newUser = [QBUUser user];
                
                newUser.fullName = weakSelf.fullNameField.text;
                newUser.email = weakSelf.emailField.text;
                newUser.password = weakSelf.passwordField.text;
                newUser.tags = @[@"ios"].mutableCopy;
                
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                
                [QM.authService signUpAndLoginWithUser:newUser completion:^(QBResponse *response, QBUUser *userProfile) {
                    
                    if (response.success) {
                        //Update password data
                        QM.profile.userAgreementAccepted = userAgreementSuccess;
                        //Synchronize user profile
                        [QM.profile synchronize];
                        //Upload user image
                        [QM.profile updateUserImage:weakSelf.selectedImage progress:^(float progress) {
                            //Upload avatar progress
                            NSLog(@"%fu", progress);
                            
                        } completion:^(BOOL success) {
                            
                            [weakSelf performSegueWithIdentifier:kSceneSegueChat sender:nil];
                        }];
                    }
                    
                    [SVProgressHUD dismiss];
                }];
            }
        }];
    }
}

@end
