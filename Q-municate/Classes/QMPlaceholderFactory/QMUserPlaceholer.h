//
//  QMUserPlaceholer.h
//  Q-municate
//
//  Created by Andrey Ivanov on 29.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMUserPlaceholer : NSObject

+ (UIImage *)userPlaceholderWithFrame:(CGRect)frame fullName:(NSString *)fullName;
+ (UIImage *)ovalWithFrame:(CGRect)frame text:(NSString *)text color:(UIColor *)color;

@end
