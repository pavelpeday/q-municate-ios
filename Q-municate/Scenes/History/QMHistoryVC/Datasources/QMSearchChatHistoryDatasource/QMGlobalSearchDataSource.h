//
//  QMGlobalSearchDataSource.h
//  Q-municate
//
//  Created by Andrey Ivanov on 11.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMPagedTableViewDataSource.h"
#import "QMAddContactProtocol.h"

@interface QMGlobalSearchDataSource : QMPagedTableViewDataSource

@property (weak, nonatomic) id <QMAddContactProtocol> addContactHandler;

@property (strong, nonatomic) NSString *searchText;

@end
