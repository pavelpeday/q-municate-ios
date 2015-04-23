//
//  QMChatBubbleImage.h
//  QMChat
//
//  Created by Andrey Ivanov on 21.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMChatBubbleImageDataSource.h"

/**
 *  A `QMChatBubbleImage` model object represents a message bubble image, and is immutable.
 *  This is a concrete class that implements the `QMChatBubbleImageDataSource` protocol.
 *  It contains a regular message bubble image and a highlighted message bubble image.
 *
 *  @see QMChatBubbleImageFactory.
 */

@interface QMChatBubbleImage : NSObject <QMChatBubbleImageDataSource, NSCopying>

/**
 *  Returns the message bubble image for a regular display state.
 */
@property (strong, nonatomic, readonly) UIImage *messageBubbleImage;

/**
 *  Returns the message bubble image for a highlighted display state.
 */
@property (strong, nonatomic, readonly) UIImage *messageBubbleHighlightedImage;

/**
 *  Initializes and returns a message bubble image object having the specified regular image and highlighted image.
 *
 *  @param image            The regular message bubble image. This value must not be `nil`.
 *  @param highlightedImage The highlighted message bubble image. This value must not be `nil`.
 *
 *  @return An initialized `QMChatBubbleImage` object if successful, `nil` otherwise.
 *
 *  @see QMChatBubbleImageFactory.
 */
- (instancetype)initWithMessageBubbleImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage;

@end
