//
//  QMChatCollectionViewLayoutAttributes.h
//  QMChat
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMChatCellLayoutAttributes : UICollectionViewLayoutAttributes <NSCopying>

@property (assign, nonatomic) UIEdgeInsets frameInsets;

- (void)setAttribute:(id <NSCopying>)attribure forKey:(id <NSCopying>)key;
- (id <NSCopying>)attributeForKey:(id <NSCopying>)key;

@end
