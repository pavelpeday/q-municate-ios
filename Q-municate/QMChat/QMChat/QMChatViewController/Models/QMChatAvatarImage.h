//
//  QMChatAvatarImage.h
//  QMChat
//
//  Created by Andrey Ivanov on 22.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMChatAvatarImageDataSource.h"

@interface QMChatAvatarImage : NSObject <QMChatAvatarImageDataSource, NSCopying>

/**
 *  The avatar image for a regular display state.
 */
@property (nonatomic, strong) UIImage *avatarImage;

/**
 *  The avatar image for a highlighted display state.
 */
@property (nonatomic, strong) UIImage *avatarHighlightedImage;

/**
 *  Returns the placeholder image for an avatar to display if avatarImage is `nil`.
 */
@property (nonatomic, strong, readonly) UIImage *avatarPlaceholderImage;

/**
 *  Initializes and returns an avatar image object having the specified image.
 *
 *  @param image The image for this avatar image. This image will be used for the all of the following
 *  properties: avatarImage, avatarHighlightedImage, avatarPlaceholderImage;
 *  This value must not be `nil`.
 *
 *  @return An initialized `QMChatAvatarImage` object if successful, `nil` otherwise.
 */
+ (instancetype)avatarWithImage:(UIImage *)image;

/**
 *  Initializes and returns an avatar image object having the specified placeholder image.
 *
 *  @param placeholderImage The placeholder image for this avatar image. This value must not be `nil`.
 *
 *  @return An initialized `QMChatAvatarImage` object if successful, `nil` otherwise.
 */
+ (instancetype)avatarImageWithPlaceholder:(UIImage *)placeholderImage;

/**
 *  Initializes and returns an avatar image object having the specified regular, highlighed, and placeholder images.
 *
 *  @param avatarImage      The avatar image for a regular display state.
 *  @param highlightedImage The avatar image for a highlighted display state.
 *  @param placeholderImage The placeholder image for this avatar image. This value must not be `nil`.
 *
 *  @return An initialized `QMChatAvatarImage` object if successful, `nil` otherwise.
 */
- (instancetype)initWithAvatarImage:(UIImage *)avatarImage
                   highlightedImage:(UIImage *)highlightedImage
                   placeholderImage:(UIImage *)placeholderImage;
@end
