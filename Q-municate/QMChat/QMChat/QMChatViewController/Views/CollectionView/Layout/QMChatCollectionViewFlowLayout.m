//
//  QMChatCollectionViewFlowLayout.m
//  QMChat
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatCollectionViewFlowLayout.h"
#import "QMChatCollectionViewLayoutAttributes.h"
#import "QMCollectionViewFlowLayoutInvalidationContext.h"

#import "QMChatMessageData.h"
#import "QMChatMediaData.h"
#import "QMChatCollectionView.h"
#import "QMChatCollectionViewCell.h"

const CGFloat kQMChatCollectionViewCellLabelHeightDefault = 20.0f;
const CGFloat kQMChatCollectionViewAvatarSizeDefault = 30.0f;

@interface QMChatCollectionViewFlowLayout()

@property (strong, nonatomic) NSMutableSet *visibleIndexPaths;
@property (strong, nonatomic) NSCache *messageBubbleCache;
@property (assign, nonatomic, readonly) NSUInteger bubbleImageAssetWidth;
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (assign, nonatomic) CGFloat latestDelta;

@end

@implementation QMChatCollectionViewFlowLayout

- (QMChatCollectionView *)chatCollectionView {
    
    return (id)self.collectionView;
}

#pragma mark - Initialization

- (void)configureFlowLayout {
    
    self.textCache = [NSMutableArray array];
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.sectionInset = UIEdgeInsetsMake(10.0f, 4.0f, 10.0f, 4.0f);
    self.minimumLineSpacing = 4.0f;
    
    _bubbleImageAssetWidth = [UIImage imageNamed:@""].size.width;
    
    _messageBubbleCache = [NSCache new];
    _messageBubbleCache.name = @"QMChatCollectionViewFlowLayout.messageBubbleCache";
    _messageBubbleCache.countLimit = 200;
    
    _messageBubbleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        _messageBubbleLeftRightMargin = 240.0f;
    }
    else {
        _messageBubbleLeftRightMargin = 50.0f;
    }
    
    _messageBubbleTextViewFrameInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 6.0f);
    _messageBubbleTextViewTextContainerInsets = UIEdgeInsetsMake(7.0f, 14.0f, 7.0f, 14.0f);
    
    CGSize defaultAvatarSize = CGSizeMake(kQMChatCollectionViewAvatarSizeDefault, kQMChatCollectionViewAvatarSizeDefault);
    _incomingAvatarViewSize = defaultAvatarSize;
    _outgoingAvatarViewSize = defaultAvatarSize;
    
    _springinessEnabled = NO;
    _springResistanceFactor = 1000;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveApplicationMemoryWarningNotification:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDeviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        [self configureFlowLayout];
    }
    
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self configureFlowLayout];
}

+ (Class)layoutAttributesClass {
    
    return [QMChatCollectionViewLayoutAttributes class];
}

+ (Class)invalidationContextClass {
    
    return [QMCollectionViewFlowLayoutInvalidationContext class];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _messageBubbleFont = nil;
    
    [self.messageBubbleCache removeAllObjects];
    self.messageBubbleCache = nil;
    
    [_dynamicAnimator removeAllBehaviors];
    _dynamicAnimator = nil;
    
    [self.visibleIndexPaths removeAllObjects];
    self.visibleIndexPaths = nil;
}

- (void)setSpringinessEnabled:(BOOL)springinessEnabled {
    
    if (_springinessEnabled == springinessEnabled) {
        return;
    }
    
    _springinessEnabled = springinessEnabled;
    
    if (!springinessEnabled) {
        [_dynamicAnimator removeAllBehaviors];
        [_visibleIndexPaths removeAllObjects];
    }
    
    [self invalidateLayoutWithContext:[QMCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setMessageBubbleFont:(UIFont *)messageBubbleFont {
    
    if ([_messageBubbleFont isEqual:messageBubbleFont]) {
        return;
    }
    
    NSParameterAssert(messageBubbleFont != nil);
    _messageBubbleFont = messageBubbleFont;
    
    [self invalidateLayoutWithContext:[QMCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setMessageBubbleLeftRightMargin:(CGFloat)messageBubbleLeftRightMargin {
    
    NSParameterAssert(messageBubbleLeftRightMargin >= 0.0f);
    _messageBubbleLeftRightMargin = ceilf(messageBubbleLeftRightMargin);
    [self invalidateLayoutWithContext:[QMCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setMessageBubbleTextViewTextContainerInsets:(UIEdgeInsets)messageBubbleTextContainerInsets {
    
    if (UIEdgeInsetsEqualToEdgeInsets(_messageBubbleTextViewTextContainerInsets, messageBubbleTextContainerInsets)) {
        return;
    }
    
    _messageBubbleTextViewTextContainerInsets = messageBubbleTextContainerInsets;
    [self invalidateLayoutWithContext:[QMCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setIncomingAvatarViewSize:(CGSize)incomingAvatarViewSize {
    
    if (CGSizeEqualToSize(_incomingAvatarViewSize, incomingAvatarViewSize)) {
        return;
    }
    
    _incomingAvatarViewSize = incomingAvatarViewSize;
    [self invalidateLayoutWithContext:[QMCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setOutgoingAvatarViewSize:(CGSize)outgoingAvatarViewSize
{
    if (CGSizeEqualToSize(_outgoingAvatarViewSize, outgoingAvatarViewSize)) {
        return;
    }
    
    _outgoingAvatarViewSize = outgoingAvatarViewSize;
    [self invalidateLayoutWithContext:[QMCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setCacheLimit:(NSUInteger)cacheLimit {
    
    self.messageBubbleCache.countLimit = cacheLimit;
}

#pragma mark - Getters

- (CGFloat)itemWidth
{
    return CGRectGetWidth(self.collectionView.frame) - self.sectionInset.left - self.sectionInset.right;
}

- (UIDynamicAnimator *)dynamicAnimator {
    
    if (!_dynamicAnimator) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    }
    return _dynamicAnimator;
}

- (NSMutableSet *)visibleIndexPaths {
    
    if (!_visibleIndexPaths) {
        _visibleIndexPaths = [NSMutableSet new];
    }
    return _visibleIndexPaths;
}

- (NSUInteger)cacheLimit {
    
    return self.messageBubbleCache.countLimit;
}

#pragma mark - Notifications

- (void)didReceiveApplicationMemoryWarningNotification:(NSNotification *)notification {
    
    [self resetLayout];
}

- (void)didReceiveDeviceOrientationDidChangeNotification:(NSNotification *)notification {
    
    [self resetLayout];
    [self invalidateLayoutWithContext:[QMCollectionViewFlowLayoutInvalidationContext context]];
}

#pragma mark - Collection view flow layout

- (void)invalidateLayoutWithContext:(QMCollectionViewFlowLayoutInvalidationContext *)context {
    
    if (context.invalidateDataSourceCounts) {
        
        context.invalidateFlowLayoutAttributes = YES;
        context.invalidateFlowLayoutDelegateMetrics = YES;
    }
    
    if (context.invalidateFlowLayoutAttributes
        || context.invalidateFlowLayoutDelegateMetrics) {
        
        [self resetDynamicAnimator];
    }
    
    if (context.invalidateFlowLayoutMessagesCache) {
        
        [self resetLayout];
    }
    
    [super invalidateLayoutWithContext:context];
}

- (void)prepareLayout {
    
    [super prepareLayout];
    
    if (self.springinessEnabled) {
        //  pad rect to avoid flickering
        CGFloat padding = -100.0f;
        CGRect visibleRect = CGRectInset(self.collectionView.bounds, padding, padding);
        
        NSArray *visibleItems = [super layoutAttributesForElementsInRect:visibleRect];
        NSSet *visibleItemsIndexPaths = [NSSet setWithArray:[visibleItems valueForKey:NSStringFromSelector(@selector(indexPath))]];
        
        [self removeNoLongerVisibleBehaviorsFromVisibleItemsIndexPaths:visibleItemsIndexPaths];
        
        [self addNewlyVisibleBehaviorsFromVisibleItems:visibleItems];
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *attributesInRect = [super layoutAttributesForElementsInRect:rect];
    
    if (self.springinessEnabled) {
        NSMutableArray *attributesInRectCopy = [attributesInRect mutableCopy];
        NSArray *dynamicAttributes = [self.dynamicAnimator itemsInRect:rect];
        
        //  avoid duplicate attributes
        //  use dynamic animator attribute item instead of regular item, if it exists
        for (UICollectionViewLayoutAttributes *eachItem in attributesInRect) {
            
            for (UICollectionViewLayoutAttributes *eachDynamicItem in dynamicAttributes) {
                
                if ([eachItem.indexPath isEqual:eachDynamicItem.indexPath]
                    && eachItem.representedElementCategory == eachDynamicItem.representedElementCategory) {
                    
                    [attributesInRectCopy removeObject:eachItem];
                    [attributesInRectCopy addObject:eachDynamicItem];
                    
                    continue;
                }
            }
        }
        
        attributesInRect = attributesInRectCopy;
    }
    
    [attributesInRect enumerateObjectsUsingBlock:^(QMChatCollectionViewLayoutAttributes *attributesItem,
                                                   NSUInteger idx,
                                                   BOOL *stop) {
        
        if (attributesItem.representedElementCategory == UICollectionElementCategoryCell) {
            
            [self configureMessageCellLayoutAttributes:attributesItem];
        }
        else {
            
            attributesItem.zIndex = -1;
        }
    }];
    
    return attributesInRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath  {
    
    QMChatCollectionViewLayoutAttributes *customAttributes = (id)[super layoutAttributesForItemAtIndexPath:indexPath];
    
    if (customAttributes.representedElementCategory == UICollectionElementCategoryCell) {
        [self configureMessageCellLayoutAttributes:customAttributes];
    }
    
    return customAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    if (self.springinessEnabled) {
        
        UIScrollView *scrollView = self.collectionView;
        CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
        
        self.latestDelta = delta;
        
        CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
        
        [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour,
                                                                     NSUInteger idx,
                                                                     BOOL *stop) {
            
            [self adjustSpringBehavior:springBehaviour forTouchLocation:touchLocation];
            [self.dynamicAnimator updateItemUsingCurrentState:[springBehaviour.items firstObject]];
        }];
    }
    
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        
        return YES;
    }
    
    return NO;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    
    [super prepareForCollectionViewUpdates:updateItems];
    
    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem,
                                              NSUInteger index,
                                              BOOL *stop) {
        
        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
            
            if (self.springinessEnabled && [self.dynamicAnimator layoutAttributesForCellAtIndexPath:updateItem.indexPathAfterUpdate]) {
                *stop = YES;
            }
            
            CGFloat collectionViewHeight = CGRectGetHeight(self.collectionView.bounds);
            
            QMChatCollectionViewLayoutAttributes *attributes =
            [QMChatCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:updateItem.indexPathAfterUpdate];
            
            if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
                [self configureMessageCellLayoutAttributes:attributes];
            }
            
            attributes.frame = CGRectMake(0.0f,
                                          collectionViewHeight + CGRectGetHeight(attributes.frame),
                                          CGRectGetWidth(attributes.frame),
                                          CGRectGetHeight(attributes.frame));
            
            if (self.springinessEnabled) {
                UIAttachmentBehavior *springBehaviour = [self springBehaviorWithLayoutAttributesItem:attributes];
                [self.dynamicAnimator addBehavior:springBehaviour];
            }
        }
    }];
}

#pragma mark - Invalidation utilities

- (void)resetLayout {
    
    [self.messageBubbleCache removeAllObjects];
    [self resetDynamicAnimator];
}

- (void)resetDynamicAnimator {
    
    if (self.springinessEnabled) {
        
        [self.dynamicAnimator removeAllBehaviors];
        [self.visibleIndexPaths removeAllObjects];
    }
}

#pragma mark - Message cell layout utilities

- (CGSize)messageBubbleSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    id<QMChatMessageData> messageItem =
    [self.chatCollectionView.dataSource collectionView:self.chatCollectionView
                         messageDataForItemAtIndexPath:indexPath];
    
    NSValue *cachedSize = [self.messageBubbleCache objectForKey:@([messageItem ID])];
    if (cachedSize != nil) {
        return [cachedSize CGSizeValue];
    }
    
    CGSize finalSize = CGSizeZero;
#warning is media
    //    if ([messageItem isMediaMessage])
    if (/* DISABLES CODE */ (NO)) {
        
        finalSize = [[messageItem media] mediaViewDisplaySize];
    }
    else {
        
        CGSize avatarSize = [self avatarSizeForIndexPath:indexPath];
        
        //  from the cell xibs, there is a 2 point space between avatar and bubble
        CGFloat spacingBetweenAvatarAndBubble = 2.0f;
        CGFloat horizontalContainerInsets = self.messageBubbleTextViewTextContainerInsets.left + self.messageBubbleTextViewTextContainerInsets.right;
        CGFloat horizontalFrameInsets = self.messageBubbleTextViewFrameInsets.left + self.messageBubbleTextViewFrameInsets.right;
        
        CGFloat horizontalInsetsTotal = horizontalContainerInsets + horizontalFrameInsets + spacingBetweenAvatarAndBubble;
        CGFloat maximumTextWidth = self.itemWidth - avatarSize.width - self.messageBubbleLeftRightMargin - horizontalInsetsTotal;
        
        QMLabelLayoutData *data = nil;
        
        if (indexPath.item < self.textCache.count) {
            data = self.textCache[indexPath.item];
        }
        
        if (!data) {
            
            data = [QMLabel calculateLayoutWithText:[messageItem text]
                                               font:self.messageBubbleFont
                                           maxWidth:maximumTextWidth
                                         attributes:@{ NSFontAttributeName : self.messageBubbleFont }
                                      linkDetection:QMLabelLinkTypeURL];
            
            [self.textCache addObject:data];
        }
        
        
        CGSize stringSize = data.size;
        
        CGFloat verticalContainerInsets = self.messageBubbleTextViewTextContainerInsets.top + self.messageBubbleTextViewTextContainerInsets.bottom;
        CGFloat verticalFrameInsets = self.messageBubbleTextViewFrameInsets.top + self.messageBubbleTextViewFrameInsets.bottom;
        
        //  add extra 2 points of space, because `boundingRectWithSize:` is slightly off
        //  not sure why. magix. (shrug) if you know, submit a PR
        CGFloat verticalInsets = verticalContainerInsets + verticalFrameInsets + 2.0f;
        
        //  same as above, an extra 2 points of magix
        CGFloat finalWidth = MAX(stringSize.width + horizontalInsetsTotal, self.bubbleImageAssetWidth) + 2.0f;
        
        finalSize = CGSizeMake(finalWidth, stringSize.height + verticalInsets);
    }
    
    [self.messageBubbleCache setObject:[NSValue valueWithCGSize:finalSize] forKey:@([messageItem ID])];
    
    return finalSize;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize messageBubbleSize = [self messageBubbleSizeForItemAtIndexPath:indexPath];
    QMChatCollectionViewLayoutAttributes *attributes =
    (QMChatCollectionViewLayoutAttributes *)[self layoutAttributesForItemAtIndexPath:indexPath];
    
    CGFloat finalHeight = messageBubbleSize.height;
    finalHeight += attributes.cellTopLabelHeight;
    finalHeight += attributes.messageBubbleTopLabelHeight;
    finalHeight += attributes.cellBottomLabelHeight;
    
    return CGSizeMake(self.itemWidth, ceilf(finalHeight));
}

- (void)configureMessageCellLayoutAttributes:(QMChatCollectionViewLayoutAttributes *)layoutAttributes {
    
    NSIndexPath *indexPath = layoutAttributes.indexPath;
    
    CGSize messageBubbleSize = [self messageBubbleSizeForItemAtIndexPath:indexPath];
    
    layoutAttributes.messageBubbleContainerViewWidth = messageBubbleSize.width;
    layoutAttributes.textViewFrameInsets = self.messageBubbleTextViewFrameInsets;
    layoutAttributes.textViewTextContainerInsets = self.messageBubbleTextViewTextContainerInsets;
    layoutAttributes.messageBubbleFont = self.messageBubbleFont;
    layoutAttributes.incomingAvatarViewSize = self.incomingAvatarViewSize;
    layoutAttributes.outgoingAvatarViewSize = self.outgoingAvatarViewSize;
    layoutAttributes.cellTopLabelHeight =
    [self.chatCollectionView.delegate collectionView:self.chatCollectionView
                                              layout:self
                    heightForCellTopLabelAtIndexPath:indexPath];
    
    layoutAttributes.messageBubbleTopLabelHeight =
    [self.chatCollectionView.delegate collectionView:self.chatCollectionView
                                              layout:self
           heightForMessageBubbleTopLabelAtIndexPath:indexPath];
    
    layoutAttributes.cellBottomLabelHeight =
    [self.chatCollectionView.delegate collectionView:self.chatCollectionView
                                              layout:self
                 heightForCellBottomLabelAtIndexPath:indexPath];
}

- (CGSize)avatarSizeForIndexPath:(NSIndexPath *)indexPath {
    
    id<QMChatMessageData> messageData =
    [self.chatCollectionView.dataSource collectionView:self.chatCollectionView
                         messageDataForItemAtIndexPath:indexPath];
    
    NSUInteger messageSender = [messageData senderID];
    
    if (messageSender == [self.chatCollectionView.dataSource senderId]) {
        return self.outgoingAvatarViewSize;
    }
    
    return self.incomingAvatarViewSize;
}

#pragma mark - Spring behavior utilities

- (UIAttachmentBehavior *)springBehaviorWithLayoutAttributesItem:(UICollectionViewLayoutAttributes *)item
{
    if (CGSizeEqualToSize(item.frame.size, CGSizeZero)) {
        // adding a spring behavior with zero size will fail in in -prepareForCollectionViewUpdates:
        return nil;
    }
    
    UIAttachmentBehavior *springBehavior =
    [[UIAttachmentBehavior alloc] initWithItem:item
                              attachedToAnchor:item.center];
    
    springBehavior.length = 1.0f;
    springBehavior.damping = 1.0f;
    springBehavior.frequency = 1.0f;
    
    return springBehavior;
}

- (void)addNewlyVisibleBehaviorsFromVisibleItems:(NSArray *)visibleItems {
    //
    //  a "newly visible" item is in `visibleItems` but not in `self.visibleIndexPaths`
    NSIndexSet *indexSet = [visibleItems indexesOfObjectsPassingTest:^BOOL(UICollectionViewLayoutAttributes *item,
                                                                           NSUInteger index,
                                                                           BOOL *stop) {
        return ![self.visibleIndexPaths containsObject:item.indexPath];
    }];
    
    NSArray *newlyVisibleItems = [visibleItems objectsAtIndexes:indexSet];
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item,
                                                    NSUInteger index,
                                                    BOOL *stop) {
        
        UIAttachmentBehavior *springBehaviour = [self springBehaviorWithLayoutAttributesItem:item];
        [self adjustSpringBehavior:springBehaviour forTouchLocation:touchLocation];
        [self.dynamicAnimator addBehavior:springBehaviour];
        [self.visibleIndexPaths addObject:item.indexPath];
    }];
}

- (void)removeNoLongerVisibleBehaviorsFromVisibleItemsIndexPaths:(NSSet *)visibleItemsIndexPaths {
    
    NSArray *behaviors = self.dynamicAnimator.behaviors;
    
    NSIndexSet *indexSet = [behaviors indexesOfObjectsPassingTest:^BOOL(UIAttachmentBehavior *springBehaviour,
                                                                        NSUInteger index,
                                                                        BOOL *stop) {
        
        UICollectionViewLayoutAttributes *layoutAttributes = [springBehaviour.items firstObject];
        
        return ![visibleItemsIndexPaths containsObject:layoutAttributes.indexPath];
    }];
    
    NSArray *behaviorsToRemove = [self.dynamicAnimator.behaviors objectsAtIndexes:indexSet];
    
    [behaviorsToRemove enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour,
                                                    NSUInteger index,
                                                    BOOL *stop) {
        
        UICollectionViewLayoutAttributes *layoutAttributes = [springBehaviour.items firstObject];
        [self.dynamicAnimator removeBehavior:springBehaviour];
        [self.visibleIndexPaths removeObject:layoutAttributes.indexPath];
    }];
}

- (void)adjustSpringBehavior:(UIAttachmentBehavior *)springBehavior forTouchLocation:(CGPoint)touchLocation {
    
    UICollectionViewLayoutAttributes *item = [springBehavior.items firstObject];
    CGPoint center = item.center;
    
    //  if touch is not (0,0) -- adjust item center "in flight"
    if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
        
        CGFloat distanceFromTouch = fabs(touchLocation.y - springBehavior.anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / self.springResistanceFactor;
        
        if (self.latestDelta < 0.0f) {
            
            center.y += MAX(self.latestDelta, self.latestDelta * scrollResistance);
        }
        else {
            
            center.y += MIN(self.latestDelta, self.latestDelta * scrollResistance);
        }
        
        item.center = center;
    }
}

@end
