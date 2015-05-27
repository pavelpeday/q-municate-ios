//
//  QMOnlineTitle.m
//  Q-municate
//
//  Created by Andrey Ivanov on 14.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMProfileTitleView.h"
#import "QMImageView.h"
#import "QMPlaceholder.h"


@interface QMProfileTitleView()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aspectRatioConstraint;

@property (weak, nonatomic) IBOutlet QMImageView *qmImageVIew;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maxLabelWidthConstraint;

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *imageUrl;

@end

@implementation QMProfileTitleView

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}


- (instancetype)init {
    
    self = [[[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class])
                                                           owner:self options:nil] firstObject];
    
    if (self) {

        self.qmImageVIew.imageViewType = QMImageViewTypeCircle;
        self.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        
        [self addGestureRecognizer:tapGesture];
        self.tapGestureRecognizer = tapGesture;
    }
    
    return self;
}

- (void)setUserName:(NSString *)userName imageUrl:(NSString *)imageUrl {
    
    self.userName = userName;
    self.imageUrl = imageUrl;
    
    [self needsUpdateConstraints];
}

- (void)setUserName:(NSString *)userName {
    
    if (![userName isEqualToString:_userName]) {
        _userName = userName;
        
        self.label.text = userName;
    }
}

- (void)setImageUrl:(NSString *)imageUrl {
    
    if (![imageUrl isEqualToString:_userName]) {
        _imageUrl = imageUrl;
        
        UIImage *placeholder = [QMPlaceholder placeholderWithFrame:self.qmImageVIew.bounds fullName:self.userName];
        
        [self.qmImageVIew setImageWithURL:imageUrl
                              placeholder:placeholder
                                  options:SDWebImageLowPriority
                                 progress:nil completedBlock:nil];
    }
}

#pragma mark - Tap gesture

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    
    [self.delegate profileTitleViewDidTap:self];
}

@end
