//
//  QMHistoryDataSource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMHistoryDataSource.h"
#import "QMChatHistoryCell.h"
#import "QMServicesManager.h"

@implementation QMHistoryDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.collection.count;
}

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
    }
    
    [cell setTime:dialog.lastMessageDate.description];
    [cell setSubTitle:dialog.lastMessageText];
    [cell setBadgeText:[NSString stringWithFormat:@"%tu", dialog.unreadMessagesCount]];
    
    return cell;
}

@end
