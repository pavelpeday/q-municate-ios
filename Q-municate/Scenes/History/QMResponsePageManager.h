//
//  QMResponsePageManager.h
//  Q-municate
//
//  Created by Andrey Ivanov on 27.05.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMResponsePageManager : NSObject

@property (assign, nonatomic, readonly) NSUInteger totalEntries;
@property (assign, nonatomic, readonly) NSUInteger loadedEntries;

- (instancetype)initWithPerPage:(NSUInteger)perPage;

- (void)resetPage;
- (QBGeneralResponsePage *)nextPage;
- (void)updateCurrentPageWithResponcePage:(QBGeneralResponsePage *)page;

@end
