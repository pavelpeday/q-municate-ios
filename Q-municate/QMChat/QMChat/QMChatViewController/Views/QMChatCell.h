//
//  QMChatCell.h
//  Q-municate
//
//  Created by Andrey Ivanov on 14.05.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMChatContainerView.h"
#import "QMChatMessageData.h"
#import "TTTAttributedLabel.h"

@class QMChatCell;

@protocol QMChatCellDelegate <NSObject>

@end

@interface QMChatCell : UICollectionViewCell

@property (weak, nonatomic) id <QMChatCellDelegate> delegate;
@property (weak, nonatomic, readonly) QMChatContainerView *containerView;
@property (weak, nonatomic, readonly) TTTAttributedLabel *textView;


+ (UINib *)nib;

+ (NSString *)cellReuseIdentifier;

+ (CGSize)sizeForItem:(id<QMChatMessageData>)messageItem maximumTextWidth:(CGFloat)maximumTextWidth;

@end
