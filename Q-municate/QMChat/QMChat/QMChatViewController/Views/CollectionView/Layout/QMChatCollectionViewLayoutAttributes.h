//
//  QMChatCollectionViewLayoutAttributes.h
//  QMChat
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  A `QMChatCollectionViewLayoutAttributes` is an object that manages the layout-related attributes
 *  for a given `QMChatCollectionViewCell` in a `QMChatCollectionView`.
 */

@interface QMChatCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes <NSCopying>

/**
 *  The font used to display the body of a text message in a message bubble within a `QMChatCollectionViewCell`.
 *  This value must not be `nil`.
 */
@property (strong, nonatomic) UIFont *messageBubbleFont;

/**
 *  The width of the `messageBubbleContainerView` of a `QMChatCollectionViewCell`.
 *  This value should be greater than `0.0`.
 *
 *  @see QMChatCollectionViewCell.
 */
@property (assign, nonatomic) CGFloat messageBubbleContainerViewWidth;

/**
 *  The inset of the text container's layout area within the text view's content area in a `QMChatCollectionViewCell`.
 *  The specified inset values should be greater than or equal to `0.0`.
 */
@property (assign, nonatomic) UIEdgeInsets textViewTextContainerInsets;

/**
 *  The inset of the frame of the text view within a `QMChatCollectionViewCell`.
 *
 *  @discussion The inset values should be greater than or equal to `0.0` and are applied in the following ways:
 *
 *  1. The right value insets the text view frame on the side adjacent to the avatar image
 *  (or where the avatar would normally appear). For outgoing messages this is the right side,
 *  for incoming messages this is the left side.
 *
 *  2. The left value insets the text view frame on the side opposite the avatar image
 *  (or where the avatar would normally appear). For outgoing messages this is the left side,
 *  for incoming messages this is the right side.
 *
 *  3. The top value insets the top of the frame.
 *
 *  4. The bottom value insets the bottom of the frame.
 */
@property (assign, nonatomic) UIEdgeInsets textViewFrameInsets;

/**
 *  The size of the `avatarImageView` of a `QMChatCollectionViewCellIncoming`.
 *  The size values should be greater than or equal to `0.0`.
 *
 *  @see QMChatCollectionViewCellIncoming.
 */
@property (assign, nonatomic) CGSize incomingAvatarViewSize;

/**
 *  The size of the `avatarImageView` of a `QMChatCollectionViewCellOutgoing`.
 *  The size values should be greater than or equal to `0.0`.
 *
 *  @see `QMChatCollectionViewCellOutgoing`.
 */
@property (assign, nonatomic) CGSize outgoingAvatarViewSize;

/**
 *  The height of the `cellTopLabel` of a `QMChatCollectionViewCell`.
 *  This value should be greater than or equal to `0.0`.
 *
 *  @see QMChatCollectionViewCell.
 */
@property (assign, nonatomic) CGFloat cellTopLabelHeight;

/**
 *  The height of the `messageBubbleTopLabel` of a `QMChatCollectionViewCell`.
 *  This value should be greater than or equal to `0.0`.
 *
 *  @see QMChatCollectionViewCell.
 */
@property (assign, nonatomic) CGFloat messageBubbleTopLabelHeight;

/**
 *  The height of the `cellBottomLabel` of a `QMChatCollectionViewCell`.
 *  This value should be greater than or equal to `0.0`.
 *
 *  @see QMChatCollectionViewCell.
 */
@property (assign, nonatomic) CGFloat cellBottomLabelHeight;

@end
