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
//@property (strong, nonatomic) UIFont *messageBubbleFont;

/**
 *  The width of the `messageBubbleContainerView` of a `QMChatCollectionViewCell`.
 *  This value should be greater than `0.0`.
 *
 *  @see QMChatCollectionViewCell.
 */
@property (assign, nonatomic) CGSize containerViewSize;

@property (assign, nonatomic) UIEdgeInsets containerInsents;

@end
