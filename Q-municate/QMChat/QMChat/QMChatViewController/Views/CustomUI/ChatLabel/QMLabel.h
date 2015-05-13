//
//  QMChatLabel.h
//  QMChat
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMLabelLayoutData.h"

typedef enum {
    QMLabelDetectionUsernames = 1ULL << 0,
    QMLabelDetectionHashtags = 1ULL << 1,
    QMLabelDetectionURLs = 1ULL << 2
} QMLabelDetection;

@interface QMLabel : UILabel

@property (nonatomic, strong) QMLabelLayoutData *precalculatedLayout;

/**
 *  The inset of the text layout area within the label's content area. The default value is `UIEdgeInsetsZero`.
 *
 *  @discussion This property provides text margins for the text laid out in the label.
 *  The inset values provided must be greater than or equal to `0.0f`.
 */
@property (assign, nonatomic) UIEdgeInsets textInsets;

+ (QMLabelLayoutData *)calculateLayoutWithText:(NSString *)text
                                          font:(UIFont *)font
                                      maxWidth:(float)maxWidth
                                    attributes:(NSDictionary *)attributes
                                 linkDetection:(QMLabelDetection)linkDetection;

@end


@interface QMLabelAttributedRange : NSObject

- (id)initWithAttributes:(NSDictionary *)attributes range:(NSRange)range;

@property (nonatomic) NSRange range;
@property (nonatomic, strong) NSDictionary *attributes;

@end