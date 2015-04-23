//
//  QMChatBubbleImage.m
//  QMChat
//
//  Created by Andrey Ivanov on 21.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatBubbleImage.h"

@implementation QMChatBubbleImage

#pragma mark - Initialization

- (instancetype)initWithMessageBubbleImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    
    NSParameterAssert(image != nil);
    NSParameterAssert(highlightedImage != nil);
    
    self = [super init];
    if (self) {
        _messageBubbleImage = image;
        _messageBubbleHighlightedImage = highlightedImage;
    }
    return self;
}

- (id)init {
    
    NSAssert(NO, @"%s is not a valid initializer for %@. Use %@ instead.",
             __PRETTY_FUNCTION__, [self class], NSStringFromSelector(@selector(initWithMessageBubbleImage:highlightedImage:)));
    return nil;
}

#pragma mark - NSObject

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@: messageBubbleImage=%@, messageBubbleHighlightedImage=%@>",
            [self class], self.messageBubbleImage, self.messageBubbleHighlightedImage];
}

- (id)debugQuickLookObject {
    
    return [[UIImageView alloc] initWithImage:self.messageBubbleImage highlightedImage:self.messageBubbleHighlightedImage];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    return [[[self class] allocWithZone:zone] initWithMessageBubbleImage:[UIImage imageWithCGImage:self.messageBubbleImage.CGImage]
                                                        highlightedImage:[UIImage imageWithCGImage:self.messageBubbleHighlightedImage.CGImage]];
}

@end
