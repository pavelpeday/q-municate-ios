//
//  QMHistoryDataSource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMHistoryDataSource.h"
#import "QMChatHistoryCell.h"

@implementation QMHistoryDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMChatHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QMChatHistoryCell" forIndexPath:indexPath];

    QBChatDialog *dialog = self.collection[indexPath.row];

    [cell setTitle:dialog.name];
    [cell setTime:dialog.lastMessageDate.description];
    [cell setSubTitle:dialog.lastMessageText];
    
    return cell;
}

@end
