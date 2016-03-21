//
//  QMChatLinkOutgoingCell.m
//  Q-municate
//
//  Created by Pavel Peday on 15.03.16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMChatLinkOutgoingCell.h"
#import "OGModel.h"

@implementation QMChatLinkOutgoingCell

+ (QMChatCellLayoutModel)layoutModel {

	QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
	defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
	defaultLayoutModel.containerInsets = UIEdgeInsetsMake(4, 4, 4, 15),
	defaultLayoutModel.topLabelHeight = 0;
	defaultLayoutModel.bottomLabelHeight = 14;

	return defaultLayoutModel;
}

+ (UINib *)nib {
	return [UINib nibWithNibName:[self cellReuseIdentifier] bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier {
	return NSStringFromClass([self class]);
}

-(void)awakeFromNib {
	[super awakeFromNib];
	[self.gradientView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.4f]];
}

- (void)prepareForReuse {
	[super prepareForReuse];
	self.ogModel = nil;
}

- (void)setOgModel:(OGModel *)ogModel {
	_ogModel = ogModel;

	_siteNameLabel.text = _ogModel.siteName;
	_linkTitleLabel.text = _ogModel.ogTitle;
	_linkDescriptionLabel.text = _ogModel.ogDescription.length > 0 ? _ogModel.ogDescription : _ogModel.originalUrl.absoluteString;

	[self.previewImageView setImageWithURL:[NSURL URLWithString:_ogModel.image]
							   placeholder:nil
								   options:kNilOptions
								  progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
							completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
								self.previewImageView.image = image;
							}];

	[self.siteFaviconImageView setImageWithURL:[NSURL URLWithString:_ogModel.favIcon]
								   placeholder:nil
									   options:kNilOptions
									  progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
								completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
									self.siteFaviconImageView.image = image;
								}];
}

@end
