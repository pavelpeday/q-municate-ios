//
//  QMChatViewsProvider.m
//  Q-municate
//
//  Created by Andrey Ivanov on 14.05.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMChatViewsProvider.h"
#import "QMChatMessageData.h"

#import "QMChatNotificationCell.h"
#import "QMChatContactRequestCell.h"

@implementation QMChatViewsProvider

- (CGSize)sizeForIndexPath:(NSIndexPath *)indexPath messageItem:(id <QMChatMessageData>)messageItem maximumWidht:(CGFloat)maximumWidth {
    
    if ([messageItem messageType] == QMMessageTypeConfirmContactRequest) {
        
        [QMChatNotificationCell sizeForItem:messageItem maximumTextWidth:maximumWidth];
        
    }
    else if ([messageItem messageType] == QMMessageTypeConfirmContactRequest) {
        
        
    }
    
    else if ([messageItem messageType] == QMMessageTypeContactRequest) {
        
        if (self.senderID == [messageItem senderID]) {
            
           return  [QMChatNotificationCell sizeForItem:messageItem maximumTextWidth:maximumWidth];
        }
        
       return [QMChatContactRequestCell sizeForItem:messageItem maximumTextWidth:maximumWidth];
    }
    
    return CGSizeZero;
}

@end
