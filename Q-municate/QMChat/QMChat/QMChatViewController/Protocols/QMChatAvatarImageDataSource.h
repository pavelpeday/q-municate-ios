//
//  QMChatAvatarImageDataSource.h
//  QMChat
//
//  Created by Andrey Ivanov on 22.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol QMChatAvatarImageDataSource <NSObject>

@required

/**
 *  @return The avatar image for a regular display state.
 *
 *  @discussion You may return `nil` from this method while the image is being downloaded.
 */
- (UIImage *)avatarImage;

/**
 *  @return The avatar image for a highlighted display state.
 *
 *  @discussion You may return `nil` from this method if this does not apply.
 */
- (UIImage *)avatarHighlightedImage;

/**
 *  @return A placeholder avatar image to be displayed if avatarImage is not yet available, or `nil`.
 *  For example, if avatarImage needs to be downloaded, this placeholder image
 *  will be used until avatarImage is not `nil`.
 *
 *  @discussion If you do not need support for a placeholder image, that is, your images
 *  are stored locally on the device, then you may simply return the same value as avatarImage here.
 *
 *  @warning You must not return `nil` from this method.
 */

/**
 *  @return A placeholder avatar image to be displayed if avatarImage is not yet available, or `nil`.
 *  For example, if avatarImage needs to be downloaded, this placeholder image
 *  will be used until avatarImage is not `nil`.
 *
 *  @discussion If you do not need support for a placeholder image, that is, your images
 *  are stored locally on the device, then you may simply return the same value as avatarImage here.
 *
 *  @warning You must not return `nil` from this method.
 */
- (UIImage *)avatarPlaceholderImage;

@end
