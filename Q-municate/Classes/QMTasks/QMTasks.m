//
//  QMTasks.m
//  Q-municate
//
//  Created by Andrey on 24.11.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTasks.h"
#import "QMServicesManager.h"
#import "QMFacebook.h"

@implementation QMTasks

+ (void)taskLogin:(void(^)(BOOL success))completion  {
    
    dispatch_block_t success =^{
        
        [QM.chatService logIn:^(NSError *error) {
            
            completion(error ? NO : YES);
        }];
    };
    
    void (^completionLogin)(QBResponse *, QBUUser *) = ^(QBResponse* response,  QBUUser *user) {
        
        //Save profile to keychain
        if (response.success) {
            
            [QM.profile synchronizeWithUserData:user];
            
            success();
        }
        else {
            
            if (completion) {
                completion(NO);
            }
        }
    };
    
    if (!QM.authService.isAuthorized) {
        
        if (QM.profile.userData.facebookID.length > 0) {
            
            QMFacebook *facebook = [[QMFacebook alloc] init];
            [facebook openSession:^(NSString *sessionToken) {
                
                [QM.authService logInWithFacebookSessionToken:sessionToken completion:completionLogin];
                
            }];
        }
        else {
            
            [QM.authService logInWithUser:QM.profile.userData completion:completionLogin];
        }
    }
    else {
        
        success();
    }
}

+ (void)taskFetchDialogsAndUsers:(void(^)(BOOL success))completion {
    
    [QM.chatService allDialogsWithPageLimit:50 extendedRequest:nil interationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
        
    } completion:^(QBResponse *response) {
        
    }];
}

@end
