//
//  QMNewMessageVC.m
//  Q-municate
//
//  Created by Andrey Ivanov on 03.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMCreateMessageVC.h"
#import "QMSearchController.h"
#import "QMContactListDataSource.h"
#import "QMServicesManager.h"
#import "QMContactCell.h"

@interface QMCreateMessageVC()

@property (strong, nonatomic) QMContactListDataSource *contactListDatasource;

@end

@implementation QMCreateMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [UIColor colorWithRed:0.071 green:0.357 blue:0.643 alpha:1.000];
    self.contactListDatasource = [[QMContactListDataSource alloc] init];
    self.searchController.searchResultsTableView.rowHeight = 48;
    self.tableView.rowHeight = 48;
    
    NSArray *usersFormCache = [QM.contactListService.usersMemoryStorage sortedByName:YES];
    [self.contactListDatasource addObjects:usersFormCache];
    self.tableView.dataSource = self.contactListDatasource;
    
    [QMContactCell registerForReuseInTableView:self.tableView];
}

@end
