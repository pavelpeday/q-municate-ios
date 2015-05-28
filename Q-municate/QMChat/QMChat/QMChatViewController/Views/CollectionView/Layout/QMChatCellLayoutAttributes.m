//
//  QMChatCollectionViewLayoutAttributes.m
//  QMChat
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatCellLayoutAttributes.h"

@interface QMChatCellLayoutAttributes()

@property (strong, nonatomic) NSMutableDictionary *customAttributes;

@end

@implementation QMChatCellLayoutAttributes

#pragma mark - Lifecycle

- (void)dealloc {
    
}

//#pragma mark - Setters
//- (void)setMessageBubbleFont:(UIFont *)messageBubbleFont {
//    
//    NSParameterAssert(messageBubbleFont != nil);
//    _messageBubbleFont = messageBubbleFont;
//}
//
//- (void)setMessageBubbleContainerViewWidth:(CGFloat)messageBubbleContainerViewWidth {
//    
//    NSParameterAssert(messageBubbleContainerViewWidth > 0.0f);
//    _messageBubbleContainerViewWidth = ceilf(messageBubbleContainerViewWidth);
//}
//
//- (void)setIncomingAvatarViewSize:(CGSize)incomingAvatarViewSize {
//    
//    NSParameterAssert(incomingAvatarViewSize.width >= 0.0f && incomingAvatarViewSize.height >= 0.0f);
//    _incomingAvatarViewSize = [self correctedAvatarSizeFromSize:incomingAvatarViewSize];
//}
//
//- (void)setOutgoingAvatarViewSize:(CGSize)outgoingAvatarViewSize {
//    
//    NSParameterAssert(outgoingAvatarViewSize.width >= 0.0f && outgoingAvatarViewSize.height >= 0.0f);
//    _outgoingAvatarViewSize = [self correctedAvatarSizeFromSize:outgoingAvatarViewSize];
//}
//
//- (void)setCellTopLabelHeight:(CGFloat)cellTopLabelHeight {
//    
//    NSParameterAssert(cellTopLabelHeight >= 0.0f);
//    _cellTopLabelHeight = [self correctedLabelHeightForHeight:cellTopLabelHeight];
//}
//
//- (void)setCellBottomLabelHeight:(CGFloat)cellBottomLabelHeight {
//    
//    NSParameterAssert(cellBottomLabelHeight >= 0.0f);
//    _cellBottomLabelHeight = [self correctedLabelHeightForHeight:cellBottomLabelHeight];
//}
//
//- (void)setMessageBubbleBottomLabelSize:(CGSize)messageBubbleBottomLabelSize {
//    
//    NSParameterAssert(messageBubbleBottomLabelSize.height >= 0.0f);
//    _messageBubbleBottomLabelSize = [self correctedLabelSizeForSize:messageBubbleBottomLabelSize];
//}
//
//- (void)setMessageBubbleTopLabelSize:(CGSize)messageBubbleTopLabelSize {
//    
//    NSParameterAssert(messageBubbleTopLabelSize.height >= 0.0f);
//    _messageBubbleTopLabelSize = [self correctedLabelSizeForSize:messageBubbleTopLabelSize];
//}

//#pragma mark - Utilities

//- (CGSize)correctedAvatarSizeFromSize:(CGSize)size {
//    
//    return CGSizeMake(ceilf(size.width), ceilf(size.height));
//}
//
//- (CGFloat)correctedLabelHeightForHeight:(CGFloat)height {
//    
//    return ceilf(height);
//}
//
//- (CGSize)correctedLabelSizeForSize:(CGSize)size {
//    
//    return CGSizeMake(ceilf(size.width), ceilf(size.height));
//}

- (void)setAttribute:(id <NSCopying>)attribure forKey:(id <NSCopying>)key {
    
    self.customAttributes[key] = attribure;
}

- (id <NSCopying>)attributeForKey:(id <NSCopying>)key {
    return self.customAttributes[key];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    
    if (self == object) {
        
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        
        return NO;
    }
    
    if (self.representedElementCategory == UICollectionElementCategoryCell) {
        
        QMChatCellLayoutAttributes *layoutAttributes = (QMChatCellLayoutAttributes *)object;
        
        if (![layoutAttributes.customAttributes isEqualToDictionary:self.customAttributes]) {
            
            return NO;
        }
    }
    return [super isEqual:object];
}

- (NSUInteger)hash {
    
    return [self.indexPath hash];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    QMChatCellLayoutAttributes *copy = [super copyWithZone:zone];
    
    if (copy.representedElementCategory != UICollectionElementCategoryCell) {
        
        return copy;
    }
    
    copy.customAttributes = self.customAttributes;
    return copy;
}

@end
