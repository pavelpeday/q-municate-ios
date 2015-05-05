//
//  QMTagsView.h
//  Q-municate
//
//  Created by Andrey Ivanov on 23.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMTagsContainer;

/**
 *  This protocol notifies you when things happen in the tags container that you might want to know about.
 */
@protocol QMTagsContainerDelegate <NSObject>

@optional

/** Is called when a user hits the return key on the input field. */
- (void)tagsContainer:(QMTagsContainer *)container didEnterText:(NSString *)text;

/** Is called when a user deletes a tag at a particular index. */
- (void)tagsContainer:(QMTagsContainer *)container didDeleteTagAtIndex:(NSUInteger)index;

/** Is called when a user changes the text in the input field. */
- (void)tagsContainer:(QMTagsContainer *)container didChangeText:(NSString *)text;

/** Is called when the input field becomes first responder */
- (void)tagsContainerDidBeginEditing:(QMTagsContainer *)container;

/** Is called when container change height */
- (void)tagsContainer:(QMTagsContainer *)container didChangeHeight:(CGFloat)height;

@end

/**
 *  This protocol allows you to provide info about what you want to present in the tags container.
 */
@protocol QMTagsContainerDataSource <NSObject>

@optional

/** To specify what the title for the tag at a particular index should be. */
- (NSString *)tagsContainer:(QMTagsContainer *)container titleForTagAtIndex:(NSUInteger)index;

/** To specify how many tags you have. */
- (NSUInteger)numberOfTagsInTagsContainer:(QMTagsContainer *)container;

/** To specify what you want the tags container to say in the collapsed state. */
- (NSString *)tagsContainerCollapsedText:(QMTagsContainer *)container;

/** Color for tag at index */
- (UIColor *)tagsContainer:(QMTagsContainer *)container colorSchemeForTagAtIndex:(NSUInteger)index;

@end

/**
 *  QMTagsContainer is the recipients tags container
 */
@interface QMTagsContainer : UIView

/**
 *  @see QMTagsContainerDelegate
 */
@property (weak, nonatomic) id<QMTagsContainerDelegate> delegate;

/**
 *  @see QMTagsContainerDataSource
 */
@property (weak, nonatomic) id<QMTagsContainerDataSource> dataSource;

- (void)reloadData;
/**
 *  Colaps tags container
 */
- (void)collapse;

/**
 *  Input text
 *
 *  @return text value
 */
- (NSString *)inputText;

/**
 *  Max height, default- 150.f
 */
@property (assign, nonatomic) CGFloat maxHeight;

/**
 *  Vertical inset, default - 7.f
 */
@property (assign, nonatomic) CGFloat verticalInset;

/**
 *  Horizontal inset, default - 15.f
 */
@property (assign, nonatomic) CGFloat horizontalInset;

/**
 *  tag pading, default 2.f
 */
@property (assign, nonatomic) CGFloat tagPadding;

/**
 *  Minimum input width, default - 80.f
 */
@property (assign, nonatomic) CGFloat minInputWidth;

@property (assign, nonatomic) UIKeyboardType inputTextFieldKeyboardType;
@property (assign, nonatomic) UITextAutocorrectionType autocorrectionType;
@property (assign, nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property (assign, nonatomic) UIView *inputTextFieldAccessoryView;
@property (strong, nonatomic) UIColor *toLabelTextColor;
@property (strong, nonatomic) NSString *toLabelText;
@property (strong, nonatomic) UIColor *inputTextFieldTextColor;

@property (strong, nonatomic) UILabel *toLabel;

@property (copy, nonatomic) NSString *placeholderText;
@property (copy, nonatomic) NSString *inputTextFieldAccessibilityLabel;

- (NSString *)text;

- (void)setColorScheme:(UIColor *)color;

@end