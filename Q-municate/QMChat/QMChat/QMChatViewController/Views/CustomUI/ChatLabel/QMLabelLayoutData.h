//
//  QMDrawingLabelLayoutData.h
//  QMChat
//
//  Created by Andrey Ivanov on 22.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QMLabelLinkType) {
    
    QMLabelLinkTypeUsername,
    QMLabelLinkTypeHashtag,
    QMLabelLinkTypeURL
};

#ifdef __cplusplus

#include <vector>
typedef struct {
    
    float horizontalOffset;
    float verticalOffset;
    NSTextAlignment alignment;
    CGFloat lineWidth;
}
QMLabelLinePosition;

typedef struct {
    
    NSRange range;
    QMLabelLinkType linkType;
    NSString *link;
    NSMutableArray *rects;
    
}
QMLabelLinkData;

#endif


@interface QMLabelLayoutData : NSObject

@property (nonatomic) CGSize size;
@property (nonatomic, strong) NSArray *textLines;

#ifdef __cplusplus
- (std::vector<QMLabelLinePosition> *)lineOrigins;
- (std::vector<QMLabelLinkData> *)links;
- (QMLabelLinkData)linkAtPoint:(CGPoint)point;
#endif

@end
