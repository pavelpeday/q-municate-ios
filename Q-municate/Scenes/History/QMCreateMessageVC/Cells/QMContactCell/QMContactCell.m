//
//  QMContactCell.m
//  Q-municate
//
//  Created by Andrey Ivanov on 03.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMContactCell.h"
#import "QMImageView.h"
#import "QMCheckMarkView.h"

@interface QMContactCell()

@property (weak, nonatomic) IBOutlet QMCheckMarkView *checkMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkWidth;
@property (assign, nonatomic) CGFloat defaultCheckMarkWidth;

@end

@implementation QMContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.defaultCheckMarkWidth = self.checkMarkWidth.constant;
    self.checkMarkWidth.constant = 0;
}

#pragma mark - Setters

- (void)setSelectable:(BOOL)selectable {
    
    if (_selectable != selectable) {
        _selectable = selectable;
        
        self.checkMarkWidth.constant = _selectable ? self.defaultCheckMarkWidth : 0;
    }
}

- (void)setCheck:(BOOL)check {
    
    if (_check != check) {
        _check = check;
        
        self.checkMarkView.check = check;
    }
}

+ (NSString *)cellIdentifier {
    
    static NSString *cellIdentifier = @"QMContactCell";
    return cellIdentifier;
}

+ (CGFloat)height {
    
    return 48.f;
}


@end
