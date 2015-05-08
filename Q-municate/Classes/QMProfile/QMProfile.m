//
//  QMProfile.m
//  Q-municate
//
//  Created by Andrey Ivanov on 24.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMProfile.h"
#import <Security/Security.h>
#import "SSKeychain.h"

NSString *const kQMUserDataKey = @"userData";
NSString *const kQMUserAgreementAcceptedKey = @"userAgreementAccepted";
NSString *const kQMPushNotificationsEnabled = @"pushNotificationsEnabled";
NSString *const kQMUserProfileType = @"userProfileType";
NSString *const kQMAppExist = @"appExist";

static NSUInteger kQMMinPasswordLenght_ = 6;

@implementation QMProfile

+ (instancetype)profile {
    
    QMProfile *profile = [[QMProfile alloc] init];
    
    return profile;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [self loadProfile];
        
        BOOL exist = [defaults boolForKey:kQMAppExist];
        
        if (self.userData && !exist) {
            
            [self clearProfile];
        }
    }
    
    return self;
}

#pragma mark - Keychain

- (void)keychainQuery:(void(^)(SSKeychainQuery *query))keychainQueryBlock {
    
    NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    NSString *service = [NSString stringWithFormat:@"%@.service", bundleIdentifier];
    NSString *account = [NSString stringWithFormat:@"%@.account", bundleIdentifier];
    
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = service;
    query.account = account;
    
    keychainQueryBlock(query);
}

- (BOOL)synchronize {
    
    if (self.skipSave) {
        return NO;
    }
    
    __weak __typeof(self)weakSelf = self;
    __block BOOL success = NO;
    
    NSAssert(self.userData, @"Need user data");
    NSAssert(self.userData.password.length > kQMMinPasswordLenght_, @"Password lenght muste be 6");
    
    [self keychainQuery:^(SSKeychainQuery *query) {
        
        query.passwordObject = weakSelf;
        NSError *error = nil;
        success = [query save:&error];
    }];
    
    if (success) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:kQMAppExist];
    }
    
    return success;
}

- (BOOL)synchronizeWithUserData:(QBUUser *)user {
    
    NSAssert(user, @"Need user data");
    self.userData = user;
    BOOL success = [self synchronize];
    
    return success;
}

- (void)loadProfile {
    
    __block QMProfile *profile = nil;
    
    [self keychainQuery:^(SSKeychainQuery *query) {
        
        NSError *error = nil;
        BOOL success = [query fetch:&error];
        
        if (success) {
            profile = (id)query.passwordObject;
        }
    }];
    
    self.pushNotificationsEnabled = profile.pushNotificationsEnabled;
    self.userAgreementAccepted = profile.userAgreementAccepted;
    self.userData = profile.userData;
    self.type = profile.type;
}

- (BOOL)clearProfile {
    
    __block BOOL success = NO;
    
    [self keychainQuery:^(SSKeychainQuery *query) {
        
        NSError *error = nil;
        success = [query deleteItem:&error];
    }];
    
    self.userData = nil;
    self.type = QMProfileTypeNone;
    self.pushNotificationsEnabled = YES;
    self.userAgreementAccepted = NO;
    
    return success;
}

#pragma mark - Server API

- (void)changePassword:(NSString *)newPassword completion:(void(^)(BOOL success))completion {
    
    QBUUser *updateUser = self.userData;
    
    updateUser.oldPassword = updateUser.password;
    updateUser.password = newPassword;
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest updateUser:updateUser successBlock:^(QBResponse *response, QBUUser *userData) {
        
        userData.password = updateUser.password;
        weakSelf.userData = userData;
        [weakSelf synchronize];
        
        if (completion) {
            completion(YES);
        }
        
    } errorBlock:^(QBResponse *response) {
        
        if (completion) {
            completion(NO);
        }
    }];
}

- (void)saveOnServer:(void (^)(BOOL success))completion {
    
    NSString *password = self.userData.password;
    self.userData.password = nil;
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest updateUser:self.userData successBlock:^(QBResponse *response, QBUUser *updatedUser) {
        
        updatedUser.password = password;
        weakSelf.userData = updatedUser;
        [weakSelf synchronize];
        
        if (completion) {
            completion(YES);
        };
        
    } errorBlock:^(QBResponse *response) {
        
        if (completion) {
            completion(NO);
        }
    }];
}

- (void)updateUserImage:(UIImage *)userImage progress:(void (^)(float progress))progress completion:(void (^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    
    QBUUser *userData = [self.userData copy];
    
    void (^updateUserProfile)(NSString *) =^(NSString *publicUrl) {
        
        NSString *password = userData.password;
        userData.password = nil;
        userData.avatarUrl = publicUrl;
        
        [QBRequest updateUser:userData successBlock:^(QBResponse *response, QBUUser *updatedUser) {
            
            updatedUser.password = password;
            weakSelf.userData = updatedUser;
            [weakSelf synchronize];
            
            if (completion) {
                completion(YES);
            }
            
        } errorBlock:^(QBResponse *response) {
            
            if (completion) {
                completion(NO);
            }
        }];
    };
    
    if (userImage) {
        
        NSData *uploadFile = UIImageJPEGRepresentation(userImage, 0.4);
        
        [QBRequest TUploadFile:uploadFile fileName:@"userImage" contentType:@"image/jpeg" isPublic:YES
                  successBlock:^(QBResponse *response, QBCBlob *blob)
        {
            updateUserProfile(blob.publicUrl);
            
        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            
            progress(status.percentOfCompletion);
            
        } errorBlock:^(QBResponse *response) {
            
            if (completion) {
                completion(NO);
            }
        }];
    }
    else {
        
        if (completion) {
            completion(NO);
        }
    }
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super init]){
        
        self.userData = [aDecoder decodeObjectForKey:kQMUserDataKey];
        self.userAgreementAccepted = [aDecoder decodeBoolForKey:kQMUserAgreementAcceptedKey];
        self.pushNotificationsEnabled = [aDecoder decodeBoolForKey:kQMPushNotificationsEnabled];
        self.type = [aDecoder decodeIntegerForKey:kQMUserProfileType];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.userData forKey:kQMUserDataKey];
    [aCoder encodeBool:self.userAgreementAccepted forKey:kQMUserAgreementAcceptedKey];
    [aCoder encodeBool:self.pushNotificationsEnabled forKey:kQMPushNotificationsEnabled];
    [aCoder encodeInteger:self.type forKey:kQMUserProfileType];
}

@end