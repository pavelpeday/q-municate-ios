//
//  QMChatCollectionViewCellOutgoing.m
//  QMChat
//
//  Created by Andrey Ivanov on 21.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatCollectionViewCellOutgoing.h"

@implementation QMChatCollectionViewCellOutgoing

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.messageBubbleTopLabel.textAlignment = NSTextAlignmentRight;
    self.cellBottomLabel.textAlignment = NSTextAlignmentRight;
    
}

@end
