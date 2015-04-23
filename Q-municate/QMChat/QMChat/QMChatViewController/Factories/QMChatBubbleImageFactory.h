//
//  QMChatBubbleImageFactory.h
//  QMChat
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class QMBubbleImage;

/**
 *  `QMChaBubbleImageFactory` is a factory that provides a means for creating and styling
 *  `QM` objects to be displayed in a `QMChatCollectonViewCell` of a `QMChatCollectionView`.
 */

@interface QMChatBubbleImageFactory : NSObject

/**
 *  Creates and returns a new instance of `QMChatBubbleImageFactory` that uses the
 *  default bubble image assets and cap insets.
 *
 *  @return An initialized `QMChatBubbleImageFactory` object if created successfully, `nil` otherwise.
 */
- (instancetype)init;

/**
 *  Creates and returns a new instance of `QMChatBubbleImageFactory` having the specified
 *  bubbleImage and capInsets. These values are used internally in the factory to produce
 *  `QMBubbleImage` objects.
 *
 *  @param bubbleImage A template bubble image from which all images will be generated.
 *  The image should represent the *outgoing* message bubble image, which will be flipped
 *  horizontally for generating the corresponding *incoming* message bubble images. This value must not be `nil`.
 *
 *  @param capInsets   The values to use for the cap insets that define the unstretchable regions of the image.
 *  Specify `UIEdgeInsetsZero` to have the factory create insets that allow the image to stretch from its center point.
 *
 *  @return An initialized `QMChatBubbleImageFactory` object if created successfully, `nil` otherwise.
 */
- (instancetype)initWithBubbleImage:(UIImage *)bubbleImage capInsets:(UIEdgeInsets)capInsets;

/**
 *  Creates and returns a `QMBubbleImage` object with the specified color for *outgoing* message image bubbles.
 *  The `messageBubbleImage` property of the `QMBubbleImage` is configured with a flat bubble image, masked to the given color.
 *  The `messageBubbleHighlightedImage` property is configured similarly, but with a darkened version of the given color.
 *
 *  @param color The color of the bubble image in the image view. This value must not be `nil`.
 *
 *  @return An initialized `QMBubbleImage` object if created successfully, `nil` otherwise.
 */
- (QMBubbleImage *)outgoingMessagesBubbleImageWithColor:(UIColor *)color;

/**
 *  Creates and returns a `QMBubbleImage` object with the specified color for *incoming* message image bubbles.
 *  The `messageBubbleImage` property of the `QMBubbleImage` is configured with a flat bubble image, masked to the given color.
 *  The `messageBubbleHighlightedImage` property is configured similarly, but with a darkened version of the given color.
 *
 *  @param color The color of the bubble image in the image view. This value must not be `nil`.
 *
 *  @return An initialized `QMBubbleImage` object if created successfully, `nil` otherwise.
 */
- (QMBubbleImage *)incomingMessagesBubbleImageWithColor:(UIColor *)color;

@end
