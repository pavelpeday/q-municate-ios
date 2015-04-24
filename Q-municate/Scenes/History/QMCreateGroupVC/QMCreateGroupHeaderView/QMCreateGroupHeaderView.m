//
//  QMCreateGroupHeaderView.m
//  Q-municate
//
//  Created by Andrey Ivanov on 23.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMCreateGroupHeaderView.h"
#import "QMImageView.h"

@interface QMCreateGroupHeaderView()

@property (strong, nonatomic) IBOutlet QMImageView *qm_imageView;
@property (strong, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (strong, nonatomic) IBOutlet QMTagsContainer *tagsContainer;

@end

@implementation QMCreateGroupHeaderView

- (void)dealloc {
    
    self.qm_imageView = nil;
    self.groupNameTextField = nil;
    self.tagsContainer = nil;
}

//- (instancetype)initWithCoder:(NSCoder *)coder {
//    
//    self = [[[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
//    if (self) {
//        
//    }
//    return self;
//}

//- (id)initWithFrame:(CGRect)frame {
//    
//    self = [[[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
//    
//    if (self) {
//        
//    }
//    
//    return self;
//}

@end
