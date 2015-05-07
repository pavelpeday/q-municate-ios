//
//  QMGroupInfoHeaderView.m
//  Q-municate
//
//  Created by Andrey Ivanov on 23.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMGroupInfoHeaderView.h"
#import "QMImageView.h"
#import "QMPlaceholder.h"

@interface QMGroupInfoHeaderView()

@end

@implementation QMGroupInfoHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIColor *imageColor = [UIColor lightGrayColor];
    UIImage *image = [QMPlaceholder ovalWithFrame:self.qm_imageView.bounds text:@"Add" color:imageColor];
    
    self.qm_imageView.imageViewType= QMImageViewTypeCircle;
    [self.qm_imageView setImage:image];
}

- (void)dealloc {
    
    self.qm_imageView = nil;
    self.groupNameTextField = nil;
    self.tagsContainer = nil;
}

@end
