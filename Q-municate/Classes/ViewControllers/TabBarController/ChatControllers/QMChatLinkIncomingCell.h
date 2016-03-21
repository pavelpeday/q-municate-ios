//
//  QMChatLinkIncomingCell.h
//  Q-municate
//
//  Created by Pavel Peday on 15.03.16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <QMCVDevelopment/QMChatCell.h>

@class OGModel;

@interface QMChatLinkIncomingCell : QMChatCell

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *textLabel;
@property (weak, nonatomic) IBOutlet UIView *gradientView;

/**
 *	OpenGraph model for link
 */
@property (nonatomic, strong) OGModel *ogModel;

/**
 *  Site preview image view.
 */
@property (weak, nonatomic) IBOutlet QMImageView *previewImageView;

/**
 * Link title
 */
@property (weak, nonatomic) IBOutlet UILabel *linkTitleLabel;

/**
 * Link short description
 */
@property (weak, nonatomic) IBOutlet UILabel *linkDescriptionLabel;

/**
 * Site name
 */
@property (weak, nonatomic) IBOutlet UILabel *siteNameLabel;

/**
 * Site favicon
 */
@property (weak, nonatomic) IBOutlet QMImageView *siteFaviconImageView;

@end
