//
//  QMChatCell.m
//  Q-municate
//
//  Created by Andrey Ivanov on 14.05.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMChatCell.h"
#import "QMChatCellLayoutAttributes.h"
#import "TTTAttributedLabel.h"

@interface QMChatCell()

@property (weak, nonatomic) IBOutlet QMChatContainerView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerWidthConstraint;

@end

@implementation QMChatCell

+ (UINib *)nib {
    
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier {
    
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    
    return layoutAttributes;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    
    [super applyLayoutAttributes:layoutAttributes];
    QMChatCellLayoutAttributes *customAttributes = (id)layoutAttributes;
    
//    self.containerHeightConstraint.constant = customAttributes.containerViewSize.height +
////    customAttributes.containerInsents.bottom + customAttributes.containerInsents.top;
//    
//    self.containerWidthConstraint.constant = customAttributes.containerViewSize.width +
//    customAttributes.containerInsents.left+ customAttributes.containerInsents.right;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    if ([[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending) {
        self.contentView.frame = bounds;
    }
}

+ (UIEdgeInsets)containerInsets {
    
    return UIEdgeInsetsZero;
}

+ (QMChatCellLayoutAttributes *)layoutAttributes {
    
    QMChatCellLayoutAttributes *attributes = [[QMChatCellLayoutAttributes alloc] init];
    
    return attributes;
}

@end
