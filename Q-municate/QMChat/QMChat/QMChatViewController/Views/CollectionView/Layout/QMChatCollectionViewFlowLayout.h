//
//  QMChatCollectionViewFlowLayout.h
//  QMChat
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  A constant that describes the default height for all label subviews in a `QMChatCollectionViewCell`.
 *
 *  @see QMChatCollectionViewCell.
 */
FOUNDATION_EXPORT const CGFloat kQMChatCollectionViewCellLabelHeightDefault;

/**
 *  A constant that describes the default size for avatar images in a `QMChatCollectionViewFlowLayout`.
 */
FOUNDATION_EXPORT const CGFloat kQMChatCollectionViewAvatarSizeDefault;

@class QMChatCollectionView;

/**
 *  The `QMChatCollectionViewFlowLayout` is a concrete layout object that inherits
 *  from `UICollectionViewFlowLayout` and organizes message items in a vertical list.
 *  Each `QMChatCollectionViewCell` in the layout can display messages of arbitrary sizes and avatar images,
 *  as well as metadata such as a timestamp and sender.
 *  You can easily customize the layout via its properties or its delegate methods
 *  defined in `QMChatCollectionViewDelegateFlowLayout`.
 *
 *  @see QMChatCollectionViewDelegateFlowLayout.
 *  @see QMChatCollectionViewCell.
 */
@interface QMChatCollectionViewFlowLayout : UICollectionViewFlowLayout

/**
 *  The collection view object currently using this layout object.
 */
@property (weak, nonatomic) QMChatCollectionView *chatCollectionView;


/**
 *  Specifies whether or not the layout should enable spring behavior dynamics for its items using `UIDynamics`.
 *
 *  @discussion The default value is `NO`, which disables "springy" or "bouncy" items in the layout.
 *  Set to `YES` if you want items to have spring behavior dynamics. You *must* set this property from `viewDidAppear:`
 *  in your `QMChatViewController` subclass.
 *
 *  @warning Though this feature is mostly stable, it is still considered an experimental feature.
 */
@property (assign, nonatomic) BOOL springinessEnabled;

/**
 *  Specifies the degree of resistence for the "springiness" of items in the layout.
 *  This property has no effect if `springinessEnabled` is set to `NO`.
 *
 *  @discussion The default value is `1000`. Increasing this value increases the resistance, that is, items become less "bouncy".
 *  Decrease this value in order to make items more "bouncy".
 */
@property (assign, nonatomic) NSUInteger springResistanceFactor;

/**
 *  Returns the width of items in the layout.
 */
@property (readonly, nonatomic) CGFloat itemWidth;

@property (readonly, nonatomic) CGFloat maxMessageWidht;

/**
 *  The maximum number of items that the layout should keep in its cache of layout information.
 *
 *  @discussion The default value is `200`. A limit of `0` means no limit. This is not a strict limit.
 */
@property (assign, nonatomic) NSUInteger cacheLimit;

/**
 *  Computes and returns the size of the `messageBubbleImageView` property of a `QMChatCollectionViewCell`
 *  at the specified indexPath. The returned size contains the required dimensions to display the entire message contents.
 *  Note, this is *not* the entire cell, but only its message bubble.
 *
 *  @param indexPath The index path of the item to be displayed.
 *
 *  @return The size of the message bubble for the item displayed at indexPath.
 */
- (CGSize)messageBubbleSizeForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Computes and returns the size of the item specified by indexPath.
 *
 *  @param indexPath The index path of the item to be displayed.
 *
 *  @return The size of the item displayed at indexPath.
 */
- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
