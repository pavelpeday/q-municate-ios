//
//  QMGroupInfoHeaderView.h
//  Q-municate
//
//  Created by Andrey Ivanov on 23.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMTagsContainer.h"

@class QMImageView;

@interface QMGroupInfoHeaderView : UIView
@property (strong, nonatomic) IBOutlet QMImageView *qm_imageView;
@property (strong, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (strong, nonatomic) IBOutlet QMTagsContainer *tagsContainer;

@end
