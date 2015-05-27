//
//  QMLocalSearchDataSource.h
//  Q-municate
//
//  Created by Andrey Ivanov on 27.05.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMHistoryDataSource.h"

@interface QMLocalSearchDataSource : QMHistoryDataSource

@property (strong, nonatomic) NSString *searchText;

@end
