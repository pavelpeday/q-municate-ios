//
//  QMChatBubbleImageDataSource.h
//  QMChat
//
//  Created by Andrey Ivanov on 21.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  The `QMChatBubbleImageDataSource` protocol defines the common interface through which
 *  a `QMChatViewController` and `QMChatCollectionView` interact with
 *  message bubble image model objects.
 *
 *  It declares the required and optional methods that a class must implement so that instances
 *  of that class can be display properly within a `QMChatCollectionViewCell`.
 *
 *  A concrete class that conforms to this protocol is provided in the library. See `QMBubbleImage`.
 *
 *  @see QMBubbleImage.
 */
@protocol QMChatBubbleImageDataSource <NSObject>

@required

/**
 *  @return The message bubble image for a regular display state.
 *
 *  @warning You must not return `nil` from this method.
 */
- (UIImage *)messageBubbleImage;

/**
 *  @return The message bubble image for a highlighted display state.
 *
 *  @warning You must not return `nil` from this method.
 */
- (UIImage *)messageBubbleHighlightedImage;

@end
