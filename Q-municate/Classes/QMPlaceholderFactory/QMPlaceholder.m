//
//  QMPlaceholder.m
//  Q-municate
//
//  Created by Andrey Ivanov on 29.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMPlaceholder.h"

@interface QMPlaceholder()

@property (strong, nonatomic) NSCache *cahce;
@property (assign, nonatomic) NSUInteger idx;
@property (strong, nonatomic) NSArray *colors;

@end

@implementation QMPlaceholder

+ (instancetype)instance {
    
    static QMPlaceholder *_userPlaceholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _userPlaceholder = [[QMPlaceholder alloc] init];
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
        @[[UIColor colorWithRed:1.000 green:0.592 blue:0.000 alpha:1.000],
          [UIColor colorWithRed:0.268 green:0.808 blue:0.120 alpha:1.000],
          [UIColor colorWithRed:0.095 green:0.561 blue:1.000 alpha:1.000],
          [UIColor colorWithWhite:0.556 alpha:1.000],
          [UIColor colorWithRed:0.500 green:0.048 blue:1.000 alpha:1.000],
          [UIColor colorWithRed:0.500 green:0.048 blue:1.000 alpha:1.000],
          [UIColor colorWithRed:1.000 green:0.089 blue:0.222 alpha:1.000]];
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

+ (UIImage *)placeholderWithFrame:(CGRect)frame fullName:(NSString *)fullName{
    
    NSString *key = [NSString stringWithFormat:@"%@ %@", fullName, NSStringFromCGSize(frame.size)];
    
    UIImage *image = [QMPlaceholder.instance.cahce objectForKey:key];
    
    if (image) {
        
        return image;
    }
    else {
        
        UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0);
        //// General Declarations
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = UIGraphicsGetCurrentContext();
        //// Colors
        UIColor *nextColor = QMPlaceholder.instance.nextColor;
        UIColor *topColor = nextColor;
        UIColor *botomColor = [self colorByDarkeningColor:nextColor WithValue:0.2];
        UIColor *labelColor = [UIColor colorWithRed:1 green:1 blue:1 alpha: 0.648];
        // Gradient Declarations
        CGFloat gradientLocations[] = {0, 1};
        //Make gradient
        CGGradientRef gradient =
        CGGradientCreateWithColors(colorSpace,
                                   (__bridge CFArrayRef)@[(id)topColor.CGColor, (id)botomColor.CGColor],
                                   gradientLocations);
        
        //// Gradient oval Drawing
        UIBezierPath* gradientOval = [UIBezierPath bezierPathWithOvalInRect:frame];
        CGContextSaveGState(context);
        [gradientOval addClip];
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
            
            NSDictionary *textFontAttributes = @{ NSFontAttributeName:font,
                                                  NSForegroundColorAttributeName:labelColor,
                                                  NSParagraphStyleAttributeName:textStyle};
            CGSize size =
            [textContent boundingRectWithSize:frame.size
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:textFontAttributes
                                      context:nil].size;
            
            [textContent drawInRect:CGRectOffset(frame,
                                                 0,
                                                 (CGRectGetHeight(frame) - size.height) / 2)
                     withAttributes:textFontAttributes];
        }
        
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
        
        UIImage *placeholderImage = UIGraphicsGetImageFromCurrentImageContext();
        UIImage *toSave = [placeholderImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
        [QMPlaceholder.instance.cahce setObject:toSave forKey:key];
        
        return toSave;
    }
}

+ (UIColor *)colorByDarkeningColor:(UIColor *)color WithValue:(CGFloat)value {
    
    NSUInteger totalComponents = CGColorGetNumberOfComponents(color.CGColor);
    BOOL isGreyscale = (totalComponents == 2) ? YES : NO;
    
    CGFloat *oldComponents = (CGFloat *)CGColorGetComponents(color.CGColor);
    CGFloat newComponents[4];
    
    if (isGreyscale) {
        
        newComponents[0] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[1] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[2] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[3] = oldComponents[1];
    }
    else {
        
        newComponents[0] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[1] = oldComponents[1] - value < 0.0f ? 0.0f : oldComponents[1] - value;
        newComponents[2] = oldComponents[2] - value < 0.0f ? 0.0f : oldComponents[2] - value;
        newComponents[3] = oldComponents[3];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *retColor = [UIColor colorWithCGColor:newColor];
    CGColorRelease(newColor);
    
    return retColor;
}

+ (UIImage *)ovalWithFrame:(CGRect)frame text:(NSString *)text color:(UIColor *)color {
    
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0);
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:frame];
    [color setFill];
    [ovalPath fill];
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:16];
    UIColor *textColor = [UIColor whiteColor];
    
    NSDictionary *ovalFontAttributes = @{NSFontAttributeName:font ,
                                         NSForegroundColorAttributeName:textColor,
                                         NSParagraphStyleAttributeName:paragraphStyle};
    
    CGRect rect = [text boundingRectWithSize:frame.size
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:ovalFontAttributes context:nil];
    
    CGRect textRect = CGRectOffset(frame,
                                   0,
                                   (frame.size.height - rect.size.height) / 2);
    [text drawInRect:textRect withAttributes: ovalFontAttributes];
    //Get image
    UIImage *ovalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return ovalImage;
}

@end
