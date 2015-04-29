//
//  QMUserPlaceholer.m
//  Q-municate
//
//  Created by Andrey Ivanov on 29.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMUserPlaceholer.h"

@interface QMUserPlaceholer()

@property (strong, nonatomic) NSCache *cahce;
@property (assign, nonatomic) NSUInteger idx;
@property (strong, nonatomic) NSArray *colors;

@end

@implementation QMUserPlaceholer

+ (instancetype)instance {
    
    static QMUserPlaceholer *_userPlaceholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _userPlaceholder = [[QMUserPlaceholer alloc] init];
    });
    
    return _userPlaceholder;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.cahce = [[NSCache alloc] init];
        self.cahce.name = @"QMUserPlaceholer.cache";
        self.cahce.countLimit = 1000;
        
        self.colors =
        @[
          [UIColor colorWithRed:0.976 green:0.835 blue:0.341 alpha:1.000],
          [UIColor colorWithRed:0.839 green:0.308 blue:0.087 alpha:1.000],
          
          [UIColor colorWithRed:0.655 green:0.925 blue:0.251 alpha:1.000],
          [UIColor colorWithRed:0.224 green:0.533 blue:0.106 alpha:1.000],
          
          [UIColor colorWithRed:0.263 green:0.529 blue:0.984 alpha:1.000],
          [UIColor colorWithRed:0.141 green:0.055 blue:0.631 alpha:1.000],
          
          [UIColor colorWithWhite:0.855 alpha:1.000],
          [UIColor colorWithWhite:0.556 alpha:1.000],
          ];
    }
    
    return self;
}

- (UIColor *)nextColor {
    
    UIColor *color = self.colors[self.idx++];
    
    if (self.idx == self.colors.count) {
        self.idx = 0;
    }
    
    return color;
}

+ (UIImage *)userPlaceholder:(CGRect)frame fullName:(NSString *)fullName {
    
    NSString *key = [NSString stringWithFormat:@"%@ %@", fullName, NSStringFromCGSize(frame.size)];
    
    UIImage *image = [QMUserPlaceholer.instance.cahce objectForKey:key];
    
    if (image) {
        
        return image;
    }
    else {
        
        UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0);
        //// General Declarations
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = UIGraphicsGetCurrentContext();
        //// Colors
        UIColor* topColor = [QMUserPlaceholer.instance nextColor];
        UIColor* botomColor = [QMUserPlaceholer.instance nextColor];
        UIColor* labelColor = [UIColor colorWithRed:1 green:1 blue:1 alpha: 0.648];
        
        // Gradient Declarations
        CGFloat gradientLocations[] = {0, 1};
        //Make gradient
        CGGradientRef gradient =
        CGGradientCreateWithColors(colorSpace,
                                   (__bridge CFArrayRef)@[(id)topColor.CGColor, (id)botomColor.CGColor],
                                   gradientLocations);
        
        //// Oval Drawing
        UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:frame];
        CGContextSaveGState(context);
        [ovalPath addClip];
        CGContextDrawLinearGradient(context, gradient,
                                    CGPointMake(CGRectGetMidX(frame), CGRectGetMinY(frame)),
                                    CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame)),
                                    0);
        
        CGContextRestoreGState(context);
        //// Text Drawing
        {
            NSString *textContent = [[fullName substringToIndex:1] uppercaseString];
            
            NSMutableParagraphStyle  *textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
            textStyle.alignment = NSTextAlignmentCenter;
            
            UIFont *font = [UIFont fontWithName:@"Helvetica" size:frame.size.height / 2];
            
            NSDictionary* textFontAttributes = @{ NSFontAttributeName:font,
                                                  NSForegroundColorAttributeName:labelColor,
                                                  NSParagraphStyleAttributeName:textStyle};
            
            CGSize size =
            [textContent boundingRectWithSize:frame.size
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:textFontAttributes
                                      context:nil].size;
            
            [textContent drawInRect:CGRectOffset(frame, 0, CGRectGetHeight(frame) - size.height / 2) withAttributes:textFontAttributes];
        }
        
        //// Cleanup
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
        
        UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
        [QMUserPlaceholer.instance.cahce setObject:maskedImage forKey:key];
        
        return maskedImage;
    }
}

@end
