//
//  QMCreateGroupVC.m
//  Q-municate
//
//  Created by Andrey Ivanov on 23.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMCreateGroupVC.h"
#import "QMContactListDataSource.h"
#import "QMContactCell.h"
#import "QMServicesManager.h"
#import "QMCreateGroupHeaderView.h"

@interface QMCreateGroupVC()

@property (strong, nonatomic) QMContactListDataSource *contactListDatasource;
@property (strong, nonatomic) QMCreateGroupHeaderView *headerView;

@end

@implementation QMCreateGroupVC

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerView = [[QMCreateGroupHeaderView alloc] init];
    self.headerView.tagsContainer.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = self.headerView;
    
    CGRect headerFrame = self.headerView.frame;
    headerFrame.origin.y = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    headerFrame.size.width = self.view.frame.size.width;
    
    self.headerView.frame = headerFrame;
    
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [UIColor colorWithRed:0.071 green:0.357 blue:0.643 alpha:1.000];
    self.contactListDatasource = [[QMContactListDataSource alloc] init];
    self.tableView.rowHeight = 48;
    
    NSArray *usersFormCache = [QM.contactListService.usersMemoryStorage sortedByName:YES];
    [self.contactListDatasource addObjects:usersFormCache];
    self.tableView.dataSource = self.contactListDatasource;
//    self.tableView.contentInset = UIEdgeInsetsMake(self.headerView.frame.size.height,0,0,0);
    
    [QMContactCell registerForReuseInTableView:self.tableView];
}

@end
