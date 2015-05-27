//
//  QMGlobalSearchDataSource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMGlobalSearchDataSource.h"

#import "QMAddContactCell.h"
#import "QMSearchStatusCell.h"

@interface QMGlobalSearchDataSource()

@property (strong, nonatomic) QMResponsePageManager *pageManager;

@end

@implementation QMGlobalSearchDataSource

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.pageManager = [[QMResponsePageManager alloc] initWithPerPage:20];
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Loading Cell
    if (indexPath.row == (signed)self.collection.count) {

        QMSearchStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:QMSearchStatusCell.cellIdentifier forIndexPath:indexPath];

        NSString *title = self.pageManager.totalEntries == self.pageManager.loadedEntries ? @"No more results" : @"Loading...";
        [cell setTitle:title];
        
        cell.showActivityIndicator = (self.pageManager.totalEntries != self.pageManager.loadedEntries);

        return cell;
    }
    else {
        //Contact cell
        QMAddContactCell *cell = [tableView dequeueReusableCellWithIdentifier:QMAddContactCell.cellIdentifier forIndexPath:indexPath];
        
        QBUUser *user = self.collection[indexPath.row];
        cell.contact = user;
        
        BOOL userExist = [self.addContactHandler userExist:user];
        [cell setUserExist:userExist];
        
        cell.delegate = self.addContactHandler;
        
        [cell setTitle:user.fullName];
        [cell highlightTitle:self.searchText];
        [cell setImageWithUrl:user.avatarUrl];
        
        return cell;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.collection.count + 1;
}

@end
