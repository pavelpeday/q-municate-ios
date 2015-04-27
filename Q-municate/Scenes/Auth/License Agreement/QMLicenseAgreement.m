//
//  QMLicenseAgreement.m
//  Q-municate
//
//  Created by Andrey Ivanov on 26.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMLicenseAgreement.h"
#import "QMLicenseAgreementVC.h"
#import "QMServicesManager.h"

@implementation QMLicenseAgreement

+ (void)checkAcceptedUserAgreementInViewController:(UIViewController *)vc completion:(void(^)(BOOL success))completion {
    
    if (QM.profile.userAgreementAccepted) {
        
        if (completion)
            completion(YES);
    }
    else {
        
        UINavigationController *navController =
        [vc.storyboard instantiateViewControllerWithIdentifier:@"QMLicenseAgreementControllerID"];
        QMLicenseAgreementViewController *licenseVC = navController.viewControllers.firstObject;
        licenseVC.licenceCompletionBlock = completion;
        
        [vc presentViewController:navController
                         animated:YES
                       completion:nil];
    }
}

@end
