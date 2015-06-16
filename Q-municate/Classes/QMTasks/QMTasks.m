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

+ (void)taskLogin:(void(^)(BOOL success))completion {
    
    dispatch_block_t loginChat = ^{
        
        [QM.chatService logIn:^(NSError *error) {
            completion(error ? NO : YES);
        }];
    };
    
    void (^completionQBLogin)(QBResponse *, QBUUser *) = ^(QBResponse* response,  QBUUser *user) {
        
        //Save profile to keychain
        if (response.success) {
            
            [QM.profile synchronizeWithUserData:user];
            
            loginChat();
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
                
                [QM.authService logInWithFacebookSessionToken:sessionToken completion:completionQBLogin];
            }];
        }
        else {
            
            [QM.authService logInWithUser:QM.profile.userData completion:completionQBLogin];
        }
    }
    else {
        
        loginChat();
    }
}

+ (void)taskFetchDialogsAndUsers:(void(^)(BOOL success))completion {
    
    NSMutableSet *resultDialogsUsersIDs = [NSMutableSet set];
    
    [QM.chatService allDialogsWithPageLimit:100
                            extendedRequest:nil
                            interationBlock:^(QBResponse *dialogsResponse,
                                              NSArray *dialogObjects,
                                              NSSet *dialogsUsersIDs,
                                              BOOL *stop)
     {
         
         [resultDialogsUsersIDs unionSet:dialogsUsersIDs];
         
     } completion:^(QBResponse *response) {
         
         [QM.contactListService retrieveUsersWithIDs:resultDialogsUsersIDs.allObjects
                                       forceDownload:YES
                                          completion:^(QBResponse *usersResponse,
                                                       QBGeneralResponsePage *page,
                                                       NSArray *users)
          {
              completion(YES);
          }];
     }];
}

+ (void)taskLoginAndFetchAllData:(void(^)(BOOL success))completion {
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    [self taskLogin:^(BOOL success) {
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [self taskFetchDialogsAndUsers:^(BOOL success) {
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        completion(YES);
    });
}

@end
