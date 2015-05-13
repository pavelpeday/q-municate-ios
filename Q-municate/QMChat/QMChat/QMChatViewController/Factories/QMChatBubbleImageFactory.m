//
//  QMChatBubbleImageFactory.m
//  QMChat
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatBubbleImageFactory.h"
#import "QMBubbleImage.h"
#import "UIImage+QM.h"
#import "UIColor+QM.h"

@interface QMChatBubbleImageFactory()

@property (strong, nonatomic, readonly) UIImage *bubbleImage;
@property (assign, nonatomic, readonly) UIEdgeInsets capInsets;

@end

@implementation QMChatBubbleImageFactory

#pragma mark - Initialization

- (instancetype)initWithBubbleImage:(UIImage *)bubbleImage capInsets:(UIEdgeInsets)capInsets {
    
    NSParameterAssert(bubbleImage != nil);
    
    self = [super init];
    if (self) {
        _bubbleImage = bubbleImage;
        
        if (UIEdgeInsetsEqualToEdgeInsets(capInsets, UIEdgeInsetsZero)) {
            _capInsets = [self centerPointEdgeInsetsForImageSize:bubbleImage.size];
        }
        else {
            _capInsets = capInsets;
        }
    }
    return self;
}

- (instancetype)init {
    
    return [self initWithBubbleImage:[UIImage imageNamed:@"left_bubble"] capInsets:UIEdgeInsetsZero];
}

- (void)dealloc {
    
    _bubbleImage = nil;
}

#pragma mark - Public

- (QMBubbleImage *)outgoingMessagesBubbleImageWithColor:(UIColor *)color {
    
    return [self messagesBubbleImageWithColor:color flippedForIncoming:NO];
}

- (QMBubbleImage *)incomingMessagesBubbleImageWithColor:(UIColor *)color {
    
    return [self messagesBubbleImageWithColor:color flippedForIncoming:YES];
}

#pragma mark - Private

- (UIEdgeInsets)centerPointEdgeInsetsForImageSize:(CGSize)bubbleImageSize {
    // make image stretchable from center point
    CGPoint center = CGPointMake(bubbleImageSize.width / 2.0f, bubbleImageSize.height / 2.0f);
    return UIEdgeInsetsMake(center.y, center.x, center.y, center.x);
}

- (QMBubbleImage *)messagesBubbleImageWithColor:(UIColor *)color flippedForIncoming:(BOOL)flippedForIncoming {
    
    NSParameterAssert(color != nil);
    
    UIImage *normalBubble = [self.bubbleImage imageMaskedWithColor:color];
    UIImage *highlightedBubble = [self.bubbleImage imageMaskedWithColor:[color colorByDarkeningColorWithValue:0.12f]];
    
    if (flippedForIncoming) {
        
        normalBubble = [self horizontallyFlippedImageFromImage:normalBubble];
        highlightedBubble = [self horizontallyFlippedImageFromImage:highlightedBubble];
    }
    
    normalBubble = [self stretchableImageFromImage:normalBubble withCapInsets:self.capInsets];
    highlightedBubble = [self stretchableImageFromImage:highlightedBubble withCapInsets:self.capInsets];
    
    return [[QMBubbleImage alloc] initWithMessageBubbleImage:normalBubble highlightedImage:highlightedBubble];
}

- (UIImage *)horizontallyFlippedImageFromImage:(UIImage *)image {
    
    return [UIImage imageWithCGImage:image.CGImage
                               scale:image.scale
                         orientation:UIImageOrientationUpMirrored];
}

- (UIImage *)stretchableImageFromImage:(UIImage *)image withCapInsets:(UIEdgeInsets)capInsets {
    
    return [image resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
}

@end
