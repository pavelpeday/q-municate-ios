//
//  QMProfileTitleView.h
//  Q-municate
//
//  Created by Andrey Ivanov on 14.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QMProfileTitleViewDelegate;

@interface QMProfileTitleView : UIView

@property (weak, nonatomic) id<QMProfileTitleViewDelegate> delegate;

- (instancetype)initWithUserName:(NSString *)userName imageUrl:(NSString *)imageUrl;

@end

@protocol QMProfileTitleViewDelegate <NSObject>

- (void)profileTitleViewDidTap:(QMProfileTitleView *)titleView;

@end
