//
//  QMProfileTitleView.h
//  Q-municate
//
//  Created by Andrey Ivanov on 14.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMProfileTitleView : UIView

@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL activity;

- (void)setUserImageWithUrl:(NSString *)url;

@end
