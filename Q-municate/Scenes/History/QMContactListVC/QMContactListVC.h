//
//  QMContactListVC.h
//  Q-municate
//
//  Created by Andrey Ivanov on 24.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMSearchTableViewController.h"
#import "QMContactListDataSource.h"

@interface QMContactListVC : QMSearchTableViewController <UITableViewDelegate>

@property (strong, nonatomic) QMContactListDataSource *contactListDatasource;
@property (assign, nonatomic) IBInspectable BOOL selectable;

@end
