//
//  QMChatCell.h
//  Q-municate
//
//  Created by Andrey Ivanov on 14.05.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMChatContainerView.h"
#import "TTTAttributedLabel.h"

@class QMChatCell;

@protocol QMChatCellDelegate <NSObject>
@required

/**
 *  Tells the delegate that the avatarImageView of the cell has been tapped.
 *
 *  @param cell The cell that received the tap touch event.
 */
- (void)chatCellDidTapAvatar:(QMChatCell *)cell;

/**
 *  Tells the delegate that the message bubble of the cell has been tapped.
 *
 *  @param cell The cell that received the tap touch event.
 */
- (void)chatCellDidTapContainer:(QMChatCell *)cell;

/**
 *  Tells the delegate that the cell has been tapped at the point specified by position.
 *
 *  @param cell The cell that received the tap touch event.
 *  @param position The location of the received touch in the cell's coordinate system.
 *
 *  @discussion This method is *only* called if position is *not* within the bounds of the cell's
 *  avatar image view or message bubble image view. In other words, this method is *not* called when the cell's
 *  avatar or message bubble are tapped.
 *
 *  @see `messagesCollectionViewCellDidTapAvatar:`
 *  @see `messagesCollectionViewCellDidTapMessageBubble:`
 */
- (void)chatCellDidTapCell:(QMChatCell *)cell atPosition:(CGPoint)position;

/**
 *  Tells the delegate that an actions has been selected from the menu of this cell.
 *  This method is automatically called for any registered actions.
 *
 *  @param cell The cell that displayed the menu.
 *  @param action The action that has been performed.
 *  @param sender The object that initiated the action.
 *
 *  @see `JSQMessagesCollectionViewCell`
 */
- (void)chatCell:(QMChatCell *)cell didPerformAction:(SEL)action withSender:(id)sender;

@end

@interface QMChatCell : UICollectionViewCell

@property (weak, nonatomic) id <QMChatCellDelegate> delegate;
@property (weak, nonatomic, readonly) QMChatContainerView *containerView;
@property (weak, nonatomic, readonly) TTTAttributedLabel *textView;


+ (UINib *)nib;

+ (NSString *)cellReuseIdentifier;

+ (UIEdgeInsets)containerInsets;
+ (BOOL)isDynamicSize;
+ (CGSize)itemSizeWithAttriburedString:(NSAttributedString *)attriburedString;
+ (CGSize)size;

@end
