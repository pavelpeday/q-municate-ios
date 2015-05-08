//
//  QMLogInViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMLogInVC.h"
#import "QMWelcomeVC.h"
#import "QMLicenseAgreement.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"
#import "QMServicesManager.h"

@interface QMLogInVC ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberMeSwitch;

@end

@implementation QMLogInVC

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rememberMeSwitch.on = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (IBAction)done:(id)sender {
    
    QBUUser *user = [QBUUser user];
    
    user.email = self.emailField.text;
    user.password = self.passwordField.text;
    
    if (user.email.length < 5 || user.password.length < 6) {
        
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil) actionSuccess:NO];
    }
    else {
        
        QM.profile.skipSave = !self.rememberMeSwitch.on;
        
        __weak __typeof(self)weakSelf = self;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [QM.authService logInWithUser:user completion:^(QBResponse *response, QBUUser *userProfile) {
            
            [SVProgressHUD dismiss];
            
            if (response.success) {
                
                [weakSelf performSegueWithIdentifier:kSceneSegueChat sender:nil];
            }
        }];
    }
}

@end