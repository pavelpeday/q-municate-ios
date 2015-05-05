//
//  QMChatCollectionViewDataSource.h
//  QMChat
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class QMChatCollectionView;

@protocol QMChatMessageData;
@protocol QMChatBubbleImageDataSource;
@protocol QMChatAvatarImageDataSource;

/**
 *  An object that adopts the `QMChatCollectionViewDataSource` protocol is responsible for providing the data and views
 *  required by a `QMChatCollectionView`. The data source object represents your app’s messaging data model
 *  and vends information to the collection view as needed.
 */
@protocol QMChatCollectionViewDataSource <UICollectionViewDataSource>

@required

/**
 *  Asks the data source for the current sender's display name, that is, the current user who is sending messages.
 *
 *  @return An initialized string describing the current sender to display in a `QMChatCollectionViewCell`.
 *
 *  @warning You must not return `nil` from this method. This value does not need to be unique.
 */
- (NSString *)senderDisplayName;

/**
 *  Asks the data source for the current sender's unique identifier, that is, the current user who is sending messages.
 *
 *  @return An initialized string identifier that uniquely identifies the current sender.
 *
 *  @warning You must not return `0` from this method. This value must be unique.
 */
- (NSUInteger)senderId;

/**
 *  Asks the data source for the message data that corresponds to the specified item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return An initialized object that conforms to the `QMChatMessageData` protocol. You must not return `nil` from this method.
 */
- (id<QMChatMessageData>)collectionView:(QMChatCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the data source for the message bubble image data that corresponds to the specified message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return An initialized object that conforms to the `QMChatBubbleImageDataSource` protocol. You may return `nil` from this method if you do not
 *  want the specified item to display a message bubble image.
 *
 *  @discussion It is recommended that you utilize `QMChatBubbleImageFactory` to return valid `QMBubbleImage` objects.
 *  However, you may provide your own data source object as long as it conforms to the `QMChatBubbleImageDataSource` protocol.
 *
 *  @warning Note that providing your own bubble image data source objects may require additional
 *  configuration of the collectionView layout object, specifically regarding its `messageBubbleTextViewFrameInsets` and `messageBubbleTextViewTextContainerInsets`.
 *
 *  @see QMChatBubbleImageFactory.
 *  @see QMChatCollectionViewFlowLayout.
 */
- (id<QMChatBubbleImageDataSource>)collectionView:(QMChatCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the data source for the avatar image data that corresponds to the specified message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return A initialized object that conforms to the `QMChatAvatarImageDataSource` protocol. You may return `nil` from this method if you do not want
 *  the specified item to display an avatar.
 *
 *  @discussion It is recommended that you utilize `QMChatAvatarImageFactory` to return valid `QMChatAvatarImage` objects.
 *  However, you may provide your own data source object as long as it conforms to the `QMChatAvatarImageDataSource` protocol.
 *
 *  @see QMChatAvatarImageFactory.
 *  @see QMChatCollectionViewFlowLayout.
 */
- (id<QMChatAvatarImageDataSource>)collectionView:(QMChatCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

/**
 *  Asks the data source for the text to display in the `cellTopLabel` for the specified
 *  message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return A configured attributed string or `nil` if you do not want text displayed for the item at indexPath.
 *  Return an attributed string with `nil` attributes to use the default attributes.
 *
 *  @see QMChatCollectionViewCell.
 */
- (NSAttributedString *)collectionView:(QMChatCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the data source for the text to display in the `messageBubbleTopLabel` for the specified
 *  message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return A configured attributed string or `nil` if you do not want text displayed for the item at indexPath.
 *  Return an attributed string with `nil` attributes to use the default attributes.
 *
 *  @see QMChatCollectionViewCell.
 */
- (NSAttributedString *)collectionView:(QMChatCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the data source for the text to display in the `cellBottomLabel` for the the specified
 *  message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return A configured attributed string or `nil` if you do not want text displayed for the item at indexPath.
 *  Return an attributed string with `nil` attributes to use the default attributes.
 *
 *  @see QMChatCollectionViewCell.
 */
- (NSAttributedString *)collectionView:(QMChatCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath;

@end

