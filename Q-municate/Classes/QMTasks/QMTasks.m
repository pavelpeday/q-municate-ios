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
    
    void (^copletionLogin)(QBResponse *, QBUUser *) = ^(QBResponse* response,  QBUUser *user) {
        
        //Save profile to keychain
        user.password = QM.profile.userData.password;
        [QM.profile synchronizeWithUserData:user];
        
        success();
    };
    
    if (!QM.authService.isAuthorized) {
        
        if (QM.profile.type == QMProfileTypeFacebook) {
            
            QMFacebook *facebook = [[QMFacebook alloc] init];
            [facebook openSession:^(NSString *sessionToken) {
                // Singin or login
                [QM.authService logInWithFacebookSessionToken:sessionToken completion:copletionLogin];
            }];
            
        } else {
            
            [QM.authService logInWithUser:QM.profile.userData completion:copletionLogin];
        }
    }
    else {
        
        success();
    }
}

+ (void)taskFetchDialogsAndUsers:(void(^)(BOOL success))completion {
    
    [QM.chatService dialogs:^(QBResponse *fetchAllDialogsResponse, NSArray *dialogObjects, NSSet *dialogsUsersIDs) {
        
        if (fetchAllDialogsResponse.success) {
            
            [QM.contactListService retrieveUsersWithIDs:dialogsUsersIDs.allObjects
                                             completion:^(QBResponse *retriveUsersResponse, QBGeneralResponsePage *page, NSArray *users) {
                                                 completion(!retriveUsersResponse || retriveUsersResponse.success);
                                             }];
        }
        else {
            
            completion(NO);
        }
    }];
}

@end
