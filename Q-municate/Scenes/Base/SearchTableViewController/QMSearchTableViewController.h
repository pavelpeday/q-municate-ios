//
//  QMSearchTableViewController.h
//  Q-municate
//
//  Created by Andrey Ivanov on 23.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMSearchController.h"

@interface QMSearchTableViewController : UITableViewController

<UITableViewDelegate, UISearchBarDelegate, QMSearchResultsUpdating, QMSearchControllerDelegate>

@property (strong, nonatomic, readonly) QMSearchController *searchController;
@property (assign, nonatomic) IBInspectable BOOL makeSearch;
@property (assign, nonatomic) IBInspectable BOOL makeRefresh;

- (void)didBeginRefresh;

@end
