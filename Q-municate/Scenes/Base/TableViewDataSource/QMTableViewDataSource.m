//
//  QMTableViewDataSource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 01.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMTableViewDatasource.h"

@interface QMTableViewDataSource()

@property (strong, nonatomic) NSMutableArray *collection;

@end

@implementation QMTableViewDataSource

@dynamic items;

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.collection = [NSMutableArray array];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    return nil;
}

- (void)addItems:(NSArray *)items {
    
    [self.collection addObjectsFromArray:items];
}

- (void)replaceItems:(NSArray *)items {
    
    [self.collection removeAllObjects];
    [self.collection addObjectsFromArray:items];
}

- (NSArray *)items {
    
    return [self.collection copy];
}

@end
