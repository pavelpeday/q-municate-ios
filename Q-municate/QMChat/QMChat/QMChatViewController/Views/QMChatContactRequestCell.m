//
//  QMChatContactRequestCell.m
//  Q-municate
//
//  Created by Andrey Ivanov on 14.05.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMChatContactRequestCell.h"

@implementation QMChatContactRequestCell

+ (CGSize)sizeForItem:(id<QMChatMessageData>)messageItem maximumTextWidth:(CGFloat)maximumTextWidth {
    
    return CGSizeMake(255, 128);
}

@end
