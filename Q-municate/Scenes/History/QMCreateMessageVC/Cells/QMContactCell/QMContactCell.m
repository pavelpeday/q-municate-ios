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

@property (weak, nonatomic) IBOutlet QMImageView *qmImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkWidth;
@property (assign, nonatomic) CGFloat defaultCheckMarkWidth;
@property (weak, nonatomic) IBOutlet QMCheckMarkView *checkMarkView;

@end

@implementation QMContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.defaultCheckMarkWidth = self.checkMarkWidth.constant;
    self.checkMarkWidth.constant = 0;
    self.qmImageView.imageViewType = QMImageViewTypeCircle;
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

- (void)setUserImageWithUrl:(NSURL *)userImageUrl {
    
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];

    __weak __typeof(self)weakSelf = self;
    [self.qmImageView setImageWithURL:userImageUrl
                          placeholder:placeholder
                              options:SDWebImageHighPriority
                             progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         
     } completedBlock:^(UIImage *image,
                       NSError *error,
                       SDImageCacheType cacheType,
                       NSURL *imageURL)
     {
         if (error) {
             
             NSLog(@"load image for user %@ error %@ ", weakSelf.contact.fullName, error.localizedDescription);
         }
     }];
}

- (void)setUserImage:(UIImage *)image withKey:(NSString *)key {
    
    if (!image) {
        image = [UIImage imageNamed:@"upic-placeholder"];
    }
    
    [self.qmImageView sd_setImage:image withKey:key];
}

+ (NSString *)cellIdentifier {
    
    static NSString *cellIdentifier = @"QMContactCell";
    return cellIdentifier;
}

+ (CGFloat)height {
    
    return 48.f;
}


@end
