//
//  QMChatCollectionViewCellIncoming.m
//  QMChat
//
//  Created by Andrey Ivanov on 21.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatCollectionViewCellIncoming.h"

@implementation QMChatCollectionViewCellIncoming

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.messageBubbleTopLabel.textAlignment = NSTextAlignmentLeft;
    self.cellBottomLabel.textAlignment = NSTextAlignmentLeft;
}

@end
