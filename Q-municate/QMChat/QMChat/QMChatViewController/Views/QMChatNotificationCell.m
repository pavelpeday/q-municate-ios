//
//  QMNotificationCell.m
//  Q-municate
//
//  Created by Andrey Ivanov on 14.05.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMChatNotificationCell.h"

@implementation QMChatNotificationCell

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    
    [super applyLayoutAttributes:layoutAttributes];
}

+ (UIFont *)font {
    
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

+ (UIEdgeInsets)containerInsets {
    
    return UIEdgeInsetsMake(2, 5, 2, 5);
}

@end
