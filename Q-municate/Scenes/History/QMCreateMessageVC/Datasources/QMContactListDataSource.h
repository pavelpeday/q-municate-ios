//
//  QMContactListDatasource.h
//  Q-municate
//
//  Created by Andrey Ivanov on 03.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMTableViewDataSource.h"

@class QMContactListDataSource;

@protocol QMContactListDataSourceHandler <NSObject>

/** Is called when datasource changed. */
- (void)didUpdateContactListDataSource:(QMContactListDataSource *)datasource;

@end

@interface QMContactListDataSource : QMTableViewDataSource

@property (assign, nonatomic) BOOL selectable;
@property (weak, nonatomic) id <QMContactListDataSourceHandler> handler;

- (QBUUser *)userAtIndexPath:(NSIndexPath *)indexPath;
- (void)selectObjectAtIndexPath:(NSIndexPath *)indexPath;
- (void)deselectObjectAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isSelectedObjectAtIndedx:(NSIndexPath *)indexPath;
- (NSArray *)selectedObjects;

@end
