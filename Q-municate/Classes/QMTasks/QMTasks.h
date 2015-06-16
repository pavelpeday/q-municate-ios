//
//  QMTasks.h
//  Q-municate
//
//  Created by Andrey on 24.11.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMTasks : NSObject

+ (void)taskLogin:(void(^)(BOOL success))completion;
+ (void)taskFetchDialogsAndUsers:(void(^)(BOOL success))completion;
+ (void)taskLoginAndFetchAllData:(void(^)(BOOL success))completion;

@end
