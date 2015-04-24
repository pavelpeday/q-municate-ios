//
//  QMCheckMarkView.m
//  q-municate
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface QMCheckMarkView : UIView

@property (strong, nonatomic) IBInspectable UIColor *checkColor;
@property (strong, nonatomic) IBInspectable UIColor *borderColor;
@property (strong, nonatomic) IBInspectable UIColor *bgColor;
@property (assign, nonatomic) IBInspectable CGFloat borderWidth;

@property (assign, nonatomic, getter=isCheck) IBInspectable BOOL check;

@end
