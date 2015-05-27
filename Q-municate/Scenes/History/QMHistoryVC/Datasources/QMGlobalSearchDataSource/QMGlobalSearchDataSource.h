//
//  QMGlobalSearchDataSource.h
//  Q-municate
//
//  Created by Andrey Ivanov on 11.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMTableViewDataSource.h"
#import "QMAddContactProtocol.h"
#import "QMResponsePageManager.h"

@interface QMGlobalSearchDataSource : QMTableViewDataSource

@property (weak, nonatomic) id <QMAddContactProtocol> addContactHandler;
@property (strong, nonatomic, readonly) QMResponsePageManager *pageManager;
@property (strong, nonatomic) NSString *searchText;

@end
