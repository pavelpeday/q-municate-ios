//
//  QMMessageText.h
//  Q-municate
//
//  Created by Andrey Ivanov on 18.05.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMMessageText : NSObject

+ (NSString *)textForMessage:(QBChatMessage *)message currentUserID:(NSUInteger)currentUserID;

@end
