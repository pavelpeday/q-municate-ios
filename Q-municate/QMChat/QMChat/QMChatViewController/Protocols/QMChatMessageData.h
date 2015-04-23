//
//  QMChatMediaData.h
//  QMChat
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QMChatMediaData;

/**
 *  The `QMChatMessageData` protocol defines the common interface through which
 *  a `QMChatViewController` and `QMChatCollectionView` interact with message model objects.
 *
 *  It declares the required and optional methods that a class must implement so that instances of that class
 *  can be displayed properly within a `QMChatCollectionViewCell`.
 *
 *  Two concrete classes that conform to this protocol are provided in the library. See `QBChatMessage`.
 *
 *  @see QBChatMessage.
 */
@protocol QMChatMessageData <NSObject>

@required

/**
 *  @return A string identifier that uniquely identifies the user who sent the message.
 *
 *  @discussion If you need to generate a unique identifier, consider using
 *  `[[NSProcessInfo processInfo] globallyUniqueString]`
 *
 *  @warning You must not return `nil` from this method. This value must be unique.
 */
- (NSUInteger)senderID;

/**
 *  @return The display name for the user who sent the message.
 *
 *  @warning You must not return `nil` from this method.
 */
- (NSString *)senderDisplayName;

/**
 *  @return The date that the message was sent.
 *
 *  @warning You must not return `nil` from this method.
 */
- (NSDate *)date;

/**
 *  This method is used to determine if the message data item contains text or media.
 *  If this method returns `YES`, an instance of `QMChatViewController` will ignore
 *  the `text` method of this protocol when dequeuing a `QMChatCollectionViewCell`
 *  and only call the `media` method.
 *
 *  Similarly, if this method returns `NO` then the `media` method will be ignored and
 *  and only the `text` method will be called.
 *
 *  @return A boolean value specifying whether or not this is a media message or a text message.
 *  Return `YES` if this item is a media message, and `NO` if it is a text message.
 */
- (BOOL)isMediaMessage;

/**
 *  @return An integer that can be used as a table address in a hash table structure.
 *
 *  @discussion This value must be unique for each message with distinct contents.
 *  This value is used to cache layout information in the collection view.
 */
- (NSUInteger)ID;

@optional

/**
 *  @return The body text of the message.
 *
 *  @warning You must not return `nil` from this method.
 */
- (NSString *)text;

/**
 *  @return The media item of the message.
 *
 *  @warning You must not return `nil` from this method.
 */
- (id<QMChatMediaData>)media;

@end
