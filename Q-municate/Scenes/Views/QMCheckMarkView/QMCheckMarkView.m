//
//  QMCheckMarkView.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "QMCheckMarkView.h"

@implementation QMCheckMarkView

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        [self setContentMode:UIViewContentModeRedraw];
    }
    return self;
}

- (void)drawCheckMarkElementWithFrame:(CGRect)frame  isCheck:(BOOL)isCheck {
    
    
    if (!isCheck) {
        
        CGRect rect = CGRectMake(self.borderWidth / 2, self.borderWidth / 2, frame.size.width-self.borderWidth, frame.size.height-self.borderWidth);
        UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect:rect];
        [self.borderColor setStroke];
        oval2Path.lineWidth = self.borderWidth;
        [oval2Path stroke];
        
    }
    else {
        
        
        //// Oval Drawing
        UIBezierPath *ovalPath  = [UIBezierPath bezierPathWithOvalInRect:frame];
        [self.bgColor setFill];
        [ovalPath fill];
        //// Check Drawing
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51795 * CGRectGetHeight(frame))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42353 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73333 * CGRectGetHeight(frame))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83333 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33846 * CGRectGetHeight(frame))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.75882 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26667 * CGRectGetHeight(frame))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42353 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58974 * CGRectGetHeight(frame))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.27451 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44615 * CGRectGetHeight(frame))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51795 * CGRectGetHeight(frame))];
        [bezierPath closePath];
        [self.checkColor setFill];
        [bezierPath fill];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    [self drawCheckMarkElementWithFrame:self.bounds
                                isCheck:self.isCheck];
    // Drawing code
}

#pragma mark - Setters

- (void)setCheck:(BOOL)check {
    
    if (_check != check) {
        _check = check;
        
        [self setNeedsDisplay];
    }
}

@end
