//
//  QMChatCollectionView.m
//  QMChat
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatCollectionView.h"
#import "QMLoadEarlierHeaderView.h"
#import "QMTypingIndicatorFooterView.h"

#import "QMChatCollectionViewCellIncoming.h"
#import "QMChatCollectionViewCellOutgoing.h"

#import "QMLoadEarlierHeaderView.h"
#import "QMTypingIndicatorFooterView.h"
#import "UIColor+QM.h"

@interface QMChatCollectionView()
<QMLoadEarlierHeaderViewDelegate>
@end

@implementation QMChatCollectionView

@dynamic dataSource;
@dynamic delegate;
@dynamic collectionViewLayout;

#pragma mark - Initialization

- (void)configureCollectionView {
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.backgroundColor = [UIColor clearColor];
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    self.alwaysBounceVertical = YES;
    self.bounces = YES;
    
    [self registerNib:[QMChatCollectionViewCellIncoming nib] forCellWithReuseIdentifier:[QMChatCollectionViewCellIncoming cellReuseIdentifier]];
    [self registerNib:[QMChatCollectionViewCellOutgoing nib] forCellWithReuseIdentifier:[QMChatCollectionViewCellOutgoing cellReuseIdentifier]];
    [self registerNib:[QMChatCollectionViewCellIncoming nib] forCellWithReuseIdentifier:[QMChatCollectionViewCellIncoming mediaCellReuseIdentifier]];
    [self registerNib:[QMChatCollectionViewCellOutgoing nib] forCellWithReuseIdentifier:[QMChatCollectionViewCellOutgoing mediaCellReuseIdentifier]];
    
    [self registerNib:[QMTypingIndicatorFooterView nib] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
  withReuseIdentifier:[QMTypingIndicatorFooterView footerReuseIdentifier]];
    
    [self registerNib:[QMLoadEarlierHeaderView nib] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
  withReuseIdentifier:[QMLoadEarlierHeaderView headerReuseIdentifier]];
    
    _typingIndicatorDisplaysOnLeft = YES;
    _typingIndicatorMessageBubbleColor = [UIColor messageBubbleLightGrayColor];
    _typingIndicatorEllipsisColor = [_typingIndicatorMessageBubbleColor colorByDarkeningColorWithValue:0.3f];
    _loadEarlierMessagesHeaderTextColor = [UIColor messageBubbleBlueColor];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self configureCollectionView];
    }
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self configureCollectionView];
}

#pragma mark - Typing indicator

- (QMTypingIndicatorFooterView *)dequeueTypingIndicatorFooterViewForIndexPath:(NSIndexPath *)indexPath {
    
    QMTypingIndicatorFooterView *footerView = [super dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                        withReuseIdentifier:[QMTypingIndicatorFooterView footerReuseIdentifier]
                                                                               forIndexPath:indexPath];
    [footerView configureWithEllipsisColor:self.typingIndicatorEllipsisColor
                        messageBubbleColor:self.typingIndicatorMessageBubbleColor
                       shouldDisplayOnLeft:self.typingIndicatorDisplaysOnLeft
                         forCollectionView:self];
    
    return footerView;
}

#pragma mark - Load earlier messages header

- (QMLoadEarlierHeaderView *)dequeueLoadEarlierMessagesViewHeaderForIndexPath:(NSIndexPath *)indexPath {
    
    QMLoadEarlierHeaderView *headerView = [super dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                    withReuseIdentifier:[QMLoadEarlierHeaderView headerReuseIdentifier]
                                                                           forIndexPath:indexPath];
    
    headerView.loadButton.tintColor = self.loadEarlierMessagesHeaderTextColor;
    headerView.delegate = self;
    
    return headerView;
}

#pragma mark - Load earlier messages header delegate

- (void)headerView:(QMLoadEarlierHeaderView *)headerView didPressLoadButton:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(collectionView:header:didTapLoadEarlierMessagesButton:)]) {
        [self.delegate collectionView:self header:headerView didTapLoadEarlierMessagesButton:sender];
    }
}

#pragma mark - Messages collection view cell delegate

- (void)messagesCollectionViewCellDidTapAvatar:(QMChatCollectionViewCell *)cell {
    
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    
    [self.delegate collectionView:self
            didTapAvatarImageView:cell.avatarImageView
                      atIndexPath:indexPath];
}

- (void)messagesCollectionViewCellDidTapMessageBubble:(QMChatCollectionViewCell *)cell {
    
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    
    [self.delegate collectionView:self didTapMessageBubbleAtIndexPath:indexPath];
}

- (void)messagesCollectionViewCellDidTapCell:(QMChatCollectionViewCell *)cell atPosition:(CGPoint)position {
    
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    
    [self.delegate collectionView:self
            didTapCellAtIndexPath:indexPath
                    touchLocation:position];
}

@end
