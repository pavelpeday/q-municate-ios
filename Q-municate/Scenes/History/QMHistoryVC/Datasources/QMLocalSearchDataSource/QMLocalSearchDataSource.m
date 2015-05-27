//
//  QMLocalSearchDataSource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 27.05.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMLocalSearchDataSource.h"

@implementation QMLocalSearchDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMChatHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QMChatHistoryCell" forIndexPath:indexPath];
    
    QBChatDialog *dialog = self.collection[indexPath.row];
    
    if (dialog.type == QBChatDialogTypePrivate) {
        
        QBUUser *recipient = [self.handler historyDataSource:self recipientWithIDs:dialog.occupantIDs];
        
        if (recipient) {
            
            [cell setTitle:recipient.fullName];
            [cell setImageWithUrl:recipient.avatarUrl];
        }
    }
    else {
        
        [cell setTitle:dialog.name];
        [cell setImageWithUrl:dialog.photo];
    }
    
    [cell setSubTitle:dialog.lastMessageText];
    [cell setBadgeText:[NSString stringWithFormat:@"%tu", dialog.unreadMessagesCount]];

    return cell;
}

@end
