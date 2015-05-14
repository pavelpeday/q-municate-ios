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

+ (CGSize)sizeForItem:(id<QMChatMessageData>)messageItem
     maximumTextWidth:(CGFloat)maximumTextWidth {
    
    CGRect stringRect =
    [[messageItem text] boundingRectWithSize:CGSizeMake(maximumTextWidth, CGFLOAT_MAX)
                                     options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                  attributes:@{ NSFontAttributeName : [self font] }
                                     context:nil];
    return stringRect.size;
}


@end
