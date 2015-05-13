//
//  QMChatLabel.m
//  QMChat
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMLabel.h"

#import <CoreText/CoreText.h>

@interface QMLabel()

@property (assign, nonatomic) BOOL isTouchMoved;
@property (assign, nonatomic) QMLabelLinkData selectedLinkData;

@end

@implementation QMLabel

#pragma mark - Initialization

- (void)configureLabel {
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    _textInsets = UIEdgeInsetsZero;
    self.backgroundColor = [UIColor clearColor];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self configureLabel];
    }
    
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self configureLabel];
}

#pragma mark - Setters

- (void)setSelectedLinkData:(QMLabelLinkData)selectedLinkData {
    
    _selectedLinkData = selectedLinkData;
    [self setNeedsDisplay]; // TODO: Redraw with highlighted link
}

- (void)setTextInsets:(UIEdgeInsets)textInsets {
    
    if (UIEdgeInsetsEqualToEdgeInsets(_textInsets, textInsets)) {
        return;
    }
    
    _textInsets = textInsets;
    [self setNeedsDisplay];
}

#pragma mark - getters

#pragma mark -
#pragma mark Getters

+ (NSArray *)arrayOfLinksForType:(QMLabelLinkType)linkType inText:(NSString *)text {
    
    switch (linkType) {
        case QMLabelLinkTypeHashtag:
        {
            NSError *error = nil;
            NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(?<!\\w)#([\\w\\_]+)?"
                                                                              options:0
                                                                                error:&error];
            if (!error) {
                return [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
            }
        }
            break;
        case QMLabelLinkTypeUsername:
        {
            NSError *error = nil;
            NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(?<!\\w)@([\\w\\_]+)?"
                                                                              options:0
                                                                                error:&error];
            if (!error) {
                return [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
            }
        }
            break;
        case QMLabelLinkTypeURL:
        {
            NSError *error = nil;
            NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:&error];
            if (!error) {
                return [detector matchesInString:text options:0 range:NSMakeRange(0, text.length)];
            }
        }
            break;
        default:
            break;
    }
    return nil;
}


#pragma mark -
#pragma mark Calculating layout

+ (QMLabelLayoutData *)calculateLayoutWithText:(NSString *)text
                                          font:(UIFont *)font
                                      maxWidth:(float)maxWidth
                                    attributes:(NSDictionary *)attributes
                                 linkDetection:(QMLabelDetection)linkDetection {
    
    
    CTFontRef fontRef = (__bridge CTFontRef)font;
    float fontAscent = CTFontGetAscent(fontRef);
    float fontDescent = CTFontGetDescent(fontRef);
    
    NSTextAlignment textAlignment = NSTextAlignmentLeft;
    // TODO: Fix issue with differents fonts at the same time
    float fontLineHeight = floorf(fontAscent + fontDescent);
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    
    NSDictionary *linkAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:0.0f green:0.3f blue:0.8f alpha:1.0f]};
    
    QMLabelLayoutData *layout = [[QMLabelLayoutData alloc] init];
    
    auto *links = layout.links;
    
    if (linkDetection & QMLabelDetectionURLs) {
        
        NSArray *URLs = [QMLabel arrayOfLinksForType:QMLabelLinkTypeURL inText:text];
        [URLs enumerateObjectsUsingBlock:^(NSTextCheckingResult *textCheckingResult, NSUInteger idx, BOOL *stop) {
            
            QMLabelLinkData link = {
                .linkType = QMLabelLinkTypeURL,
                .link = [text substringWithRange:textCheckingResult.range],
                .range = textCheckingResult.range
            };
            
            links->push_back(link);
        }];
    }
    
    if (linkDetection & QMLabelDetectionHashtags) {
        
        NSArray *hashtags = [QMLabel arrayOfLinksForType:QMLabelLinkTypeHashtag inText:text];
        [hashtags enumerateObjectsUsingBlock:^(NSTextCheckingResult *textCheckingResult,
                                               NSUInteger idx, BOOL
                                               *stop) {
            
            QMLabelLinkData link = {
                .linkType = QMLabelLinkTypeHashtag,
                .link = [text substringWithRange:textCheckingResult.range],
                .range = textCheckingResult.range
            };
            
            links->push_back(link);
        }];
    }
    
    if (linkDetection & QMLabelDetectionUsernames) {
        
        NSArray *usernames = [QMLabel arrayOfLinksForType:QMLabelLinkTypeUsername inText:text];
        [usernames enumerateObjectsUsingBlock:^(NSTextCheckingResult *textCheckingResult,
                                                NSUInteger idx,
                                                BOOL *stop) {
            
            QMLabelLinkData link = {
                .linkType = QMLabelLinkTypeUsername,
                .link = [text substringWithRange:textCheckingResult.range],
                .range = textCheckingResult.range
            };
            
            links->push_back(link);
        }];
    }
    
    if (!links->empty()) {
        
        if (linkAttributes) {
            
            for (auto &linkIt: *layout.links) {
                
                [linkAttributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, id attribute, BOOL *stop) {
                    
                    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)string,
                                                   CFRangeFromNSRange(linkIt.range),
                                                   adjustKey(key),
                                                   (__bridge CFTypeRef)attribute);
                }];
            }
        }
    }
    
    auto *lineOrigins = layout.lineOrigins;
    
    CGRect rect = CGRectZero;
    NSMutableArray *textLines = [[NSMutableArray alloc] init];
    CFIndex lastIndex = 0;
    float currentLineOffset = 0;
    
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
    
    while (true) {
        
        CFIndex lineCharacterCount = CTTypesetterSuggestLineBreak(typesetter, lastIndex, maxWidth);
        
        if (lineCharacterCount > 0) {
            
            CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(lastIndex, lineCharacterCount));
            [textLines addObject:(__bridge id)line];
            
            bool rightAligned = (textAlignment == NSTextAlignmentRight);
            
            CFArrayRef glyphRuns = CTLineGetGlyphRuns(line);
            
            if (CFArrayGetCount(glyphRuns) != 0) {
                
                if (CTRunGetStatus((CTRunRef)CFArrayGetValueAtIndex(glyphRuns, 0)) & kCTRunStatusRightToLeft) {
                    
                    rightAligned = true;
                }
            }
            
            float lineWidth = (float)CTLineGetTypographicBounds(line, NULL, NULL, NULL) - (float)CTLineGetTrailingWhitespaceWidth(line);
            
            currentLineOffset += fontLineHeight;
            
            NSTextAlignment alignment = (rightAligned ? NSTextAlignmentRight : textAlignment);
            
            CGFloat horizontalOffset = 0.0f;
            switch (alignment) {
                    
                case NSTextAlignmentCenter:
                    horizontalOffset = floorf((maxWidth - lineWidth) / 2.0f);
                    break;
                case NSTextAlignmentRight:
                    horizontalOffset = maxWidth - lineWidth;
                    break;
                default:
                    break;
            }
            
            QMLabelLinePosition linePosition = {
                
                .horizontalOffset = static_cast<float>(horizontalOffset),
                .verticalOffset = currentLineOffset,
                .alignment = alignment,
                .lineWidth = lineWidth };
            
            lineOrigins->push_back(linePosition);
            
            rect.size.height += fontLineHeight;
            rect.size.width = MAX(rect.size.width, lineWidth);
            
            if (line != NULL) {
                CFRelease(line);
            }
            
            lastIndex += lineCharacterCount;
        }
        else {
            break;
        }
    }
    
    if (!links->empty()) {
        
        CGSize layoutSize = layout.size;
        
        for (auto &linkIt: *layout.links) {
            
            for (NSUInteger lineIdx = 0; lineIdx < textLines.count; lineIdx++) {
                
                CTLineRef line = (__bridge CTLineRef)[textLines objectAtIndex:lineIdx];
                CFRange lineRange = CTLineGetStringRange(line);
                
                const QMLabelLinePosition &linePosition = lineOrigins->at(lineIdx);
                CGPoint lineOrigin = CGPointMake(linePosition.horizontalOffset, linePosition.verticalOffset);
                
                NSRange intersectionRange = NSIntersectionRange(linkIt.range, NSMakeRange(lineRange.location, lineRange.length));
                
                if (intersectionRange.length != 0) {
                    
                    float startX = 0.0f;
                    float endX = 0.0f;
                    
                    startX = ceilf(CTLineGetOffsetForStringIndex(line,
                                                                 intersectionRange.location,
                                                                 NULL) + lineOrigin.x);
                    
                    endX = ceilf(CTLineGetOffsetForStringIndex(line,
                                                               intersectionRange.location + intersectionRange.length,
                                                               NULL) + lineOrigin.x);
                    if (startX > endX) {
                        
                        float tmp = startX;
                        startX = endX;
                        endX = tmp;
                    }
                    
                    if ((unsigned int)intersectionRange.location + intersectionRange.length >= (unsigned int)lineRange.location + lineRange.length
                        && ABS(endX - layoutSize.width) < 16) {
                        
                        endX = layoutSize.width + lineOrigin.x;
                    }
                    
                    CGRect region = CGRectMake(ceilf(startX - 3),
                                               ceilf(lineOrigin.y - fontLineHeight + fontLineHeight * 0.1f),
                                               ceilf(endX - startX + 6),
                                               ceilf(fontLineHeight * 1.1));
                    
                    if (!linkIt.rects) {
                        linkIt.rects = [NSMutableArray array];
                    }
                    
                    NSValue *regionValue = [NSValue valueWithCGRect:region];
                    [linkIt.rects addObject:regionValue];
                }
            }
        }
    }
    
    layout.size = CGSizeMake(floorf(rect.size.width), floorf(rect.size.height + fontLineHeight * 0.4f));
    layout.textLines = textLines;
    
    if (typesetter != NULL) {
        CFRelease(typesetter);
    }
    
    return layout;
}

#pragma mark -
#pragma mark Helpers

CFRange CFRangeFromNSRange(NSRange range) {
    
    return CFRangeMake(range.location, range.length);
}

CFStringRef adjustKey(NSString *key) {
    
    if ([key isEqualToString:NSForegroundColorAttributeName]) {
        return kCTForegroundColorAttributeName;
    }
    
    return (__bridge CFStringRef)key;
}

NSRange NSRangeFromCFRange(CFRange range) {
    return NSMakeRange(range.location, range.length);
}

#pragma mark -
#pragma mark Drawing

+ (void)drawTextInRect:(CGRect)rect withPrecalculatedLayout:(QMLabelLayoutData *)precalculatedLayout {
    
    CFArrayRef lines = (__bridge CFArrayRef)precalculatedLayout.textLines;
    if (!lines) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0f, -1.0f));
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    
    CGRect clipRect = CGContextGetClipBoundingBox(context);
    
    NSInteger numberOfLines = CFArrayGetCount(lines);
    
    NSRange linesRange = NSMakeRange(0, numberOfLines);
    
    auto *lineOrigins = precalculatedLayout.lineOrigins;
    
    CGFloat lineHeight = rect.size.height;
    
    if (lineOrigins->size() > 1) {
        lineHeight = ABS(lineOrigins->at(0).verticalOffset - lineOrigins->at(1).verticalOffset);
    }
    
    CGFloat upperOriginBound = clipRect.origin.y;
    CGFloat lowerOriginBound = clipRect.origin.y + clipRect.size.height + lineHeight;
    
    for (CFIndex lineIndex = linesRange.location; lineIndex < (CFIndex)(linesRange.location + linesRange.length); lineIndex++) {
        
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, lineIndex);
        const QMLabelLinePosition &linePosition = lineOrigins->at(lineIndex);
        CGPoint lineOrigin = CGPointMake(linePosition.horizontalOffset, linePosition.verticalOffset);
        if (lineOrigin.y < upperOriginBound || lineOrigin.y > lowerOriginBound) {
            continue;
        }
        
        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
        CTLineDraw(line, context);
    }
    
    CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.isTouchMoved = NO;
    
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    QMLabelLinkData linkData = [self.precalculatedLayout linkAtPoint:touchLocation];
    
    if (linkData.link) {
        
        self.selectedLinkData = linkData;
    }
    else {
        
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    self.isTouchMoved = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (self.isTouchMoved) {
        
        self.selectedLinkData = {};
        return;
    }
    
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    QMLabelLinkData linkData = [self.precalculatedLayout linkAtPoint:touchLocation];
    
    if (linkData.link) {
        //        if (self.delegate && [self.delegate respondsToSelector:@selector(drawingLabel:didPressAtLink:withType:)]) {
        //            [self.delegate drawingLabel:self didPressAtLink:linkData.link withType:linkData.linkType];
        //        }
    } else {
        
        [super touchesBegan:touches withEvent:event];
    }
    
    self.selectedLinkData = {};
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    self.selectedLinkData = {};
}

#pragma mark - Drawing

- (void)drawTextInRect:(CGRect)rect {
    
    CGRect t_rect = CGRectMake(CGRectGetMinX(rect) + self.textInsets.left,
                               CGRectGetMinY(rect) + self.textInsets.top,
                               CGRectGetWidth(rect) - self.textInsets.right,
                               CGRectGetHeight(rect) - self.textInsets.bottom);
    
    if (!_precalculatedLayout) {
        
        [super drawTextInRect:rect];
    }
    else {
        
        [QMLabel drawTextInRect:t_rect withPrecalculatedLayout:_precalculatedLayout];
    }
}

@end

@implementation QMLabelAttributedRange

- (id)initWithAttributes:(NSDictionary *)attributes range:(NSRange)range {
    
    self = [super init];
    if (self) {
        
        _attributes = attributes;
        
        _range = range;
    }
    return self;
}

@end
