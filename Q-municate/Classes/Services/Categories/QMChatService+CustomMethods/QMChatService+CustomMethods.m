//
//  QMChatService+CustomMethods.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/24/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

@implementation QMChatService(CustomMethods)

- (void)fetchDialogsWithLastActivityFromDate:(NSDate *)date completion:(QBDialogsPagedResponseBlock)completionBlock
{
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    NSMutableDictionary *extendedRequest = @{@"last_message_date_sent[gt]":@(timeInterval)}.mutableCopy;
    
//    __weak typeof(self)weakSelf = self;
    
    [QBRequest dialogsForPage:[QBResponsePage responsePageWithLimit:1 skip:0] extendedRequest:extendedRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
        //
//        if (response.success) {
//            [weakSelf updateDialogsWithRequested:result.dialogs];
//        }
        if (completionBlock) completionBlock(response,dialogObjects,dialogsUsersIDs,page);
    } errorBlock:^(QBResponse *response) {
        //
    }];
}

- (void)changeDialogAvatar:(NSString *)avatarPublicUrl forChatDialog:(QBChatDialog *)chatDialog completion:(void (^)(QBResponse *response, QBChatDialog *updatedDialog))completion {
    
    if (chatDialog.type == QBChatDialogTypePrivate) return;
    
    chatDialog.photo = avatarPublicUrl;
    __weak __typeof(self)weakSelf = self;
    [QBRequest updateDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *dialog) {
        //
        [weakSelf.dialogsMemoryStorage addChatDialog:dialog andJoin:NO onJoin:nil];
        
        if (completion) completion(response,dialog);
    } errorBlock:^(QBResponse *response) {
        //
        [weakSelf.serviceManager handleErrorResponse:response];

        if (completion) completion(response,nil);
    }];
}

@end