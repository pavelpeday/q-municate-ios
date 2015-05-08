//
//  QMServicesManager.m
//  Q-municate
//
//  Created by Andrey Ivanov on 24.11.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMServicesManager.h"
#import "REAlertView.h"

NSString *const kQMChatCacheStoreName = @"QMCahtCacheStorage";
NSString *const kQMContactListCacheStoreName = @"QMContactListStorage";

typedef NS_ENUM(NSUInteger, QM_STATUS) {
    QM_STATUS_REGISTER_PUSH_NOTIFICATION,
    QM_STATUS_UN_REGISTER_PUSH_NOTIFICATION
};

@interface QMServicesManager()

<QMChatServiceDelegate, QMContactListServiceDelegate, QMContactListServiceCacheDelegate, QMChatServiceCacheDelegate, QMAuthServiceDelegate>

@property (strong, nonatomic) QMAuthService *authService;
@property (strong, nonatomic) QMChatService *chatService;
@property (strong, nonatomic) QMContactListService *contactListService;
@property (strong, nonatomic) QMProfile *profile;

@end

@implementation QMServicesManager

+ (instancetype)instance {
    
    static QMServicesManager *_sharedQMServicesManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedQMServicesManager = [[QMServicesManager alloc] init];
        
        [QBConnection setAutoCreateSessionEnabled:YES];
    });
    
    return _sharedQMServicesManager;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self initialization];
    }
    
    return self;
}

- (void)initialization {
    
    self.profile = [QMProfile profile];
    
    //Setup core data
    [QMChatCache setupDBWithStoreNamed:kQMChatCacheStoreName];
    [QMContactListCache setupDBWithStoreNamed:kQMContactListCacheStoreName];
    //Init servises
    self.contactListService = [[QMContactListService alloc] initWithServiceManager:self cacheDelegate:self];
    self.authService = [[QMAuthService alloc] initWithServiceManager:self];
    self.chatService = [[QMChatService alloc] initWithServiceManager:self cacheDelegate:self];
    //Subsicribe to notifications
    [self.authService addDelegate:self];
    [self.chatService addDelegate:self];
    [self.contactListService addDelegate:self];
}

#pragma mark - QMServiceManagerProtocol

- (QBUUser *)currentUser {
    
    return self.profile.userData;
}

- (BOOL)isAutorized {
    
    return self.authService.isAuthorized;
}

- (void)handleErrorResponse:(QBResponse *)response {
    
    [self showMessageForQBError:response.error status:response.status];
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService didAddChatDialog:(QBChatDialog *)chatDialog {
    
    [[QMChatCache instance] insertOrUpdateDialog:chatDialog completion:nil];
}

- (void)chatService:(QMChatService *)chatService didAddChatDialogs:(NSArray *)chatDialogs {

    [[QMChatCache instance] insertOrUpdateDialogs:chatDialogs completion:nil];
}

- (void)chatServiceDidAddMessagesToHistroy:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    [[QMChatCache instance] insertOrUpdateMessages:messages withDialogId:dialogID completion:nil];
}

- (void)chatServiceDidAddMessageToHistory:(QBChatMessage *)message forDialog:(QBChatDialog *)dialog {
    
    [[QMChatCache instance] insertOrUpdateMessage:message withDialogId:dialog.ID read:YES completion:nil];
}

- (void)chatServiceDidReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog {
    
    NSAssert([message.dialogID isEqualToString:dialog.ID], @"Muste be equal");
    [[QMChatCache instance] insertOrUpdateMessage:message withDialogId:dialog.ID read:YES completion:nil];
    [[QMChatCache instance] insertOrUpdateDialog:dialog completion:nil];
}

- (void)chatServiceDidReceiveNotificationMessage:(QBChatMessage *)message updateDialog:(QBChatDialog *)dialog {
    
    [[QMChatCache instance] insertOrUpdateMessage:message withDialogId:dialog.ID read:YES completion:nil];
    [[QMChatCache instance] insertOrUpdateDialog:dialog completion:nil];
}

#pragma mark - QMChatServiceCacheDelegate

- (void)cachedDialogs:(QMCacheCollection)block {
    
    [[QMChatCache instance] dialogsSortedBy:@"lastMessageDate" ascending:NO completion:block];
}

- (void)cachedMessagesWithDialogID:(NSString *)dialogID block:(QMCacheCollection)block {
    
    [[QMChatCache instance] messagesWithDialogId:dialogID sortedBy:nil ascending:NO completion:block];
}

#pragma mark - QMContactListServiceCacheDelegate

- (void)cachedUsers:(QMCacheCollection)block {
    
    [[QMContactListCache instance] usersSortedBy:nil ascending:NO completion:block];
}

- (void)cachedContactListItems:(QMCacheCollection)block {
    
    [[QMContactListCache instance] contactListItems:block];
}

#pragma mark - QMContactListServiceDelegate

- (void)contactListService:(QMContactListService *)contactListService contactListDidChange:(QBContactList *)contactList {
    
    [[QMContactListCache instance] insertOrUpdateContactListItemsWithContactList:contactList completion:nil];
}

- (void)contactListService:(QMContactListService *)contactListService addRequestFromUser:(QBUUser *)user {
    
}

- (void)contactListService:(QMContactListService *)contactListService didAddUser:(QBUUser *)user {
    
    [[QMContactListCache instance] insertOrUpdateUser:user completion:nil];
}

- (void)contactListService:(QMContactListService *)contactListService didAddUsers:(NSArray *)users {
    
    [[QMContactListCache instance] insertOrUpdateUsers:users completion:nil];
}

- (void)contactListService:(QMContactListService *)contactListService didUpdateUser:(QBUUser *)user {
    
}

#pragma mark QMAuthServiceDelegate

- (void)authServiceDidLogOut:(QMAuthService *)authService {
    
    [QMChatCache cleanDBWithStoreName:kQMChatCacheStoreName];
    [QMContactListCache cleanDBWithStoreName:kQMContactListCacheStoreName];
    
    [self.authService free];
    [self.chatService free];
    [self.contactListService free];
    [self.profile clearProfile];
    
    self.authService = nil;
    self.chatService = nil;
    self.contactListService = nil;
    self.profile = nil;
    
    [self initialization];
}

- (void)authService:(QMAuthService *)authService didLoginWithUser:(QBUUser *)user {
    
}

#pragma mark - Errors handler

#pragma mark - error Handler

NSString *const kQBResponceErrorsKey = @"errors";

- (void)showMessageForQBError:(QBError *)error status:(NSInteger)status {
    
        id errors = error.reasons[kQBResponceErrorsKey];
        NSMutableString *resultErrorMessageString = [NSMutableString string];
    
        if ([errors isKindOfClass:[NSDictionary class]]) {
    
            for (NSString *key in [errors allKeys]) {
                NSArray *obj = errors[key];
                NSString *reason = NSLocalizedString(key, nil);
                [resultErrorMessageString appendFormat:@"%@ - %@", reason, [obj firstObject]];
            }
        }
        else if ([errors isKindOfClass:[NSArray class]]){
    
            NSString *errorStr = [errors firstObject];
            NSString *reason = NSLocalizedString(errorStr, nil);
            [resultErrorMessageString appendFormat:@"%@", reason];
        }
    
        if (resultErrorMessageString.length == 0) {
            [resultErrorMessageString  appendString:error.error.localizedDescription];
        }
    
        NSString *errorTitle = nil;
        if (status == 0) {
            errorTitle = NSLocalizedString(@"QM_STR_ERROR", nil);
        }
        else if (status == QBResponseStatusCodeUnknown) {
            errorTitle = NSLocalizedString(@"QM_ERROR_STATUS_STR_UNKNOWN", nil);
        }
        else if (status == QBResponseStatusCodeValidationFailed) {
            errorTitle = NSLocalizedString(@"QM_ERROR_STATUS_STR_VALIDATION_FAILED", nil);
        }
        else if (status == QBResponseStatusCodeUnAuthorized) {
            errorTitle = NSLocalizedString(@"QM_ERROR_STATUS_STR_UN_AUTORIZED", nil);
        }
        else if (status == QBResponseStatusCodeServerError) {
            errorTitle = NSLocalizedString(@"QM_ERROR_STATUS_STR_SERVER_ERROR", nil);
        }
        else if (status == QBResponseStatusCodeBadRequest) {
            errorTitle = NSLocalizedString(@"QM_ERROR_STAUTS_STR_BAD_REQUEST", nil);
        }
        else if (status == QM_STATUS_REGISTER_PUSH_NOTIFICATION) {
            errorTitle = NSLocalizedString(@"QM_ERROR_STATUS_STR_UNREGISTER_PUSH_NOTIFICATION", nil);
        }
        else if (status == QM_STATUS_UN_REGISTER_PUSH_NOTIFICATION) {
            errorTitle = NSLocalizedString(@"QM_ERROR_STATUS_STR_REGISTER_PUSH_NOTIFICATION", nil);
        }
    
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
        
        alertView.title = errorTitle;
        alertView.message = resultErrorMessageString;
        [alertView addButtonWithTitle:@"Ok" andActionBlock:^{

        }];
        
    }];
}

- (BOOL)checkResult:(QBResult *)result {
    //    
    //    if (!result.success) {
    //        [REAlertView showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
    //    }
    //    
    //return result.success;
    return YES;
}


@end