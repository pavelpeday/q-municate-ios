//
//  QMSearchCell.m
//  Q-municate
//
//  Created by Andrey Ivanov on 23.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMSearchCell.h"
#import "QMImageView.h"
#import "UIImage+Cropper.h"
#import "QMPlaceholder.h"

@interface QMSearchCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet QMImageView *qmImageView;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subTitle;
@property (strong, nonatomic) NSString *imageUrl;

@end

@implementation QMSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.qmImageView.imageViewType = QMImageViewTypeCircle;
    self.titleLabel.text = nil;
    self.subTitleLabel.text = nil;
}

#pragma mark - Setters

- (void)setTitle:(NSString *)title {
    
    if (![_title isEqualToString:title]) {
        
        _title = title;
        self.titleLabel.text = title;
    }
}

- (void)setSubTitle:(NSString *)subTitle {
    
    if (![_subTitle isEqualToString:subTitle]) {
        
        _subTitle = subTitle;
        self.subTitleLabel.text = subTitle;
    }
}

- (void)setImageWithUrl:(NSString *)url {
    
    if (![self.imageUrl isEqualToString:url]) {
        
        self.imageUrl = url;
        
        UIImage *placeholder = [QMPlaceholder placeholderWithFrame:self.qmImageView.bounds fullName:self.title];
        
        [self.qmImageView setImageWithURL:url placeholder:placeholder options:SDWebImageLowPriority
                                 progress:nil completedBlock:nil];
    }
}

- (void)highlightTitle:(NSString *)title {
    
    NSMutableAttributedString *attributedString =
    [[NSMutableAttributedString alloc] initWithString:self.title];
    
    UIColor *highlightColor = [UIColor colorWithRed:1.000 green:0.610 blue:0.426 alpha:1.000];
    
    [attributedString beginEditing];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:highlightColor
                             range:[self.title rangeOfString:title options:NSCaseInsensitiveSearch]];
    
    [attributedString endEditing];
    
    self.titleLabel.attributedText = attributedString;
}

@end
