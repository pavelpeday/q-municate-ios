//
//  QMMessageText.m
//  Q-municate
//
//  Created by Andrey Ivanov on 18.05.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMMessageText.h"
#import "QMServicesManager.h"

@implementation QMMessageText

+ (NSString *)textForMessage:(QBChatMessage *)message currentUserID:(NSUInteger)currentUserID {
    
    QBUUser *user = [QM.contactListService.usersMemoryStorage userWithID:message.senderID];
    
    switch (message.messageType) {
            
        case QMMessageTypeContactRequest: {
            
            if (message.senderID == currentUserID) {
                
                return NSLocalizedString(@"Your request has been sent", nil);
            }
            else {
                
                return [NSString stringWithFormat:NSLocalizedString(@"%@\nwould like to chat with you", nil), user.fullName];
            }
            
        } break;
            
        case QMMessageTypeAcceptContactRequest: {
            
            if (message.senderID == currentUserID) {
                
                return NSLocalizedString(@"You have accepted a request", nil);
            }
            else {
                
                return NSLocalizedString(@"Your request has been accepted", nil);
            }
            
        } break;
            
        case QMMessageTypeRejectContactRequest: {
            
            if (message.senderID == currentUserID) {
                
                return NSLocalizedString(@"You have rejected a request", nil);
            }
            else {
                
                return NSLocalizedString(@"Your request has been rejected", nil);
            }
            
        } break;
            
        case QMMessageTypeDeleteContactRequest: {
            
            if (message.senderID == currentUserID) {
                
                return [NSString stringWithFormat:NSLocalizedString(@"You have deleted %@ from your contact list", nil), @"Andrey"];
            }
            else {
                
                return [NSString stringWithFormat:NSLocalizedString(@"%@ has deleted you from the contact list", nil), @"Andrey"];
            }
            
        } break;
            
        case QMMessageTypeCreateGroupDialog: {
            
            QBUUser *sender = [QM.contactListService.usersMemoryStorage userWithID:message.senderID];
            NSArray *occupants = [QM.contactListService.usersMemoryStorage usersWithIDs:message.dialog.occupantIDs withoutID:sender.ID];
            NSString *occupantsNames = [QM.contactListService.usersMemoryStorage joinedNamesbyUsers:occupants];
            
            return [NSString stringWithFormat:NSLocalizedString(@"%@ has added %@ to the group chat.", nil), sender.fullName, occupantsNames];
            
        } break;
            
        case QMMessageTypeUpdateGroupDialog: {
            return @"";
            
        }break;
            
        default: {
            
            return message.text;
            
        } break;
    }
}

@end
