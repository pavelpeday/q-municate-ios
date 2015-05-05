    //
//  QMNewMessageVC.m
//  Q-municate
//
//  Created by Andrey Ivanov on 03.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMCreateMessageVC.h"

@implementation QMCreateMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchController.searchBar.tintColor = [UIColor colorWithRed:0.067 green:0.357 blue:0.643 alpha:1.000];
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
}

@end
