//
//  QMSearchCell.h
//  Q-municate
//
//  Created by Andrey Ivanov on 23.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMTableViewCell.h"

@interface QMSearchCell : QMTableViewCell
/**
 *  Set image with url
 *
 *  @param url String url
 */
- (void)setImageWithUrl:(NSString *)url;

/**
 *  Set title
 *
 *  @param title string title
 */
- (void)setTitle:(NSString *)title;

/**
 *  Set subtitle
 *
 *  @param subTitle String title
 */
- (void)setSubTitle:(NSString *)subTitle;

//Higlight title with string
- (void)highlightTitle:(NSString *)title;

@end
