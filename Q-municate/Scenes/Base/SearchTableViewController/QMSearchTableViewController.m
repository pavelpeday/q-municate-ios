//
//  QMSearchTableViewController.m
//  Q-municate
//
//  Created by Andrey Ivanov on 23.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMSearchTableViewController.h"


@interface QMSearchTableViewController ()

@property (strong, nonatomic) QMSearchController *searchController;

@end

@implementation QMSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.makeSearch) {
        
        self.searchController = [[QMSearchController alloc] initWithContentsController:self];
        self.searchController.delegate = self;
        self.searchController.searchResultsDelegate = self;
        self.searchController.searchResultsUpdater = self;
        self.searchController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        self.searchController.searchBar.delegate = self;
        self.searchController.searchBar.placeholder = @"Search";
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }
    else {
        
        self.searchController = nil;
        self.tableView.tableHeaderView = nil;
    }

    if (self.makeRefresh) {

        //Add refresh control
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.tintColor = [UIColor whiteColor];
        [refreshControl addTarget:self action:@selector(didBeginRefresh) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }
}

#pragma mark - Actions
#pragma mark Refresh control

- (void)didBeginRefresh {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - QMSearchResultsUpdating

- (void)updateSearchResultsForSearchController:(QMSearchController *)searchController {
}

#pragma mark - QMSearchControllerDelegate

- (void)willPresentSearchController:(QMSearchController *)searchController {
}

- (void)didPresentSearchController:(QMSearchController *)searchController {
}

- (void)willDismissSearchController:(QMSearchController *)searchController {
    
}

- (void)didDismissSearchController:(QMSearchController *)searchController {
    
}

- (void)presentSearchController:(QMSearchController *)searchController {
    
}

@end
