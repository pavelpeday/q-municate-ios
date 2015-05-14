//
//  QMChatViewsProvider.h
//  Q-municate
//
//  Created by Andrey Ivanov on 14.05.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QMChatCollectionViewFlowLayout.h"

@interface QMChatViewsProvider : NSObject <QMSizesProviderDelegate>

@property (assign, nonatomic) NSUInteger senderID;

@end
