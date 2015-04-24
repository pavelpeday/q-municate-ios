//
//  QMTagsView.m
//  Q-municate
//
//  Created by Andrey Ivanov on 23.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMTagsContainer.h"

@class QMBackspaceTextField;

@protocol QMBackspaceTextFieldDelegate <UITextFieldDelegate>

- (void)textFieldDidEnterBackspace:(QMBackspaceTextField *)textField;

@end

/**
 *  QMBackspaceTextField
 */
@interface QMBackspaceTextField : UITextField

@property (weak, nonatomic) id<QMBackspaceTextFieldDelegate> backspaceDelegate;

@end

/**
 *  Tag View
 */
@interface QMTagView : UIView

@property (assign, nonatomic) BOOL highlighted;
@property (strong, nonatomic) UIColor *colorScheme;
@property (copy, nonatomic) dispatch_block_t didTapTagBlock;

- (void)setTitleText:(NSString *)text;

@end

const CGFloat kQMTagsContainerDefaultVerticalInset = 7.0;
const CGFloat kQMTagsContainerDefaultHorizontalInset = 15.0;
const CGFloat kQMTagsContainerDefaultToLabelPadding = 5.0;
const CGFloat kQMTagsContainerDefaultTagPadding = 2.0;
const CGFloat kQMTagsContainerDefaultMinInputWidth = 80.0;
const CGFloat kQMTagsContainerDefaultMaxHeight = 150.0;

@interface QMTagsContainer() <QMBackspaceTextFieldDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *tags;
@property (assign, nonatomic) CGFloat originalHeight;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) QMBackspaceTextField *invisibleTextField;
@property (strong, nonatomic) QMBackspaceTextField *inputTextField;
@property (strong, nonatomic) UIColor *colorScheme;
@property (strong, nonatomic) UILabel *collapsedLabel;

@end

@implementation QMTagsContainer

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self configure];
    }
    return self;
}

- (void)awakeFromNib {
    
    [self configure];
}

- (BOOL)isFirstResponder {
    
    return [self.inputTextField isFirstResponder];
}

- (BOOL)becomeFirstResponder {
    
    [self layouttagsAndInputWithFrameAdjustment:YES];
    [self inputTextFieldBecomeFirstResponder];
    
    return YES;
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    
    return [self.inputTextField resignFirstResponder];
}

- (void)configure {
    
    // Set up default values.
    _autocorrectionType = UITextAutocorrectionTypeNo;
    _autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.maxHeight = kQMTagsContainerDefaultMaxHeight;
    self.verticalInset = kQMTagsContainerDefaultVerticalInset;
    self.horizontalInset = kQMTagsContainerDefaultHorizontalInset;
    self.tagPadding = kQMTagsContainerDefaultTagPadding;
    self.minInputWidth = kQMTagsContainerDefaultMinInputWidth;
    self.colorScheme = [UIColor blueColor];
    self.toLabelTextColor = [UIColor colorWithRed:112/255.0f green:124/255.0f blue:124/255.0f alpha:1.0f];
    self.inputTextFieldTextColor = [UIColor colorWithRed:38/255.0f green:39/255.0f blue:41/255.0f alpha:1.0f];
    
    // Accessing bare value to avoid kicking off a premature layout run.
    _toLabelText = NSLocalizedString(@"Add people:", nil);
    
    self.originalHeight = CGRectGetHeight(self.frame);
    
    // Add invisible text field to handle backspace when we don't have a real first responder.
    [self layoutInvisibleTextField];
    
    [self layoutScrollView];
    [self reloadData];
}

- (void)collapse {
    
    [self layoutCollapsedLabel];
}

- (void)reloadData{
    
    [self layouttagsAndInputWithFrameAdjustment:YES];
}

- (void)setPlaceholderText:(NSString *)placeholderText {
    
    _placeholderText = placeholderText;
    self.inputTextField.placeholder = _placeholderText;
}

- (void)setInputTextFieldAccessibilityLabel:(NSString *)inputTextFieldAccessibilityLabel {
    
    _inputTextFieldAccessibilityLabel = inputTextFieldAccessibilityLabel;
    self.inputTextField.accessibilityLabel = _inputTextFieldAccessibilityLabel;
}

- (void)setInputTextFieldTextColor:(UIColor *)inputTextFieldTextColor {
    
    _inputTextFieldTextColor = inputTextFieldTextColor;
    self.inputTextField.textColor = _inputTextFieldTextColor;
}

- (void)setToLabelTextColor:(UIColor *)toLabelTextColor {
    
    _toLabelTextColor = toLabelTextColor;
    self.toLabel.textColor = _toLabelTextColor;
}

- (void)setToLabelText:(NSString *)toLabelText {
    
    _toLabelText = toLabelText;
    [self reloadData];
}

- (void)setColorScheme:(UIColor *)color {
    
    _colorScheme = color;
    self.collapsedLabel.textColor = color;
    self.inputTextField.tintColor = color;
    
    for (QMTagView *tagView in self.tags) {
        
        [tagView setColorScheme:color];
    }
}

- (void)setInputTextFieldAccessoryView:(UIView *)inputTextFieldAccessoryView {
    
    _inputTextFieldAccessoryView = inputTextFieldAccessoryView;
    self.inputTextField.inputAccessoryView = _inputTextFieldAccessoryView;
}

- (NSString *)inputText {
    
    return self.inputTextField.text;
}

#pragma mark - View Layout

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) - self.horizontalInset * 2,
                                             CGRectGetHeight(self.frame) - self.verticalInset * 2);
    
    if ([self isCollapsed]) {
        
        [self layoutCollapsedLabel];
    }
    else {
        
        [self layouttagsAndInputWithFrameAdjustment:NO];
    }
}

- (void)layoutCollapsedLabel {
    
    [self.collapsedLabel removeFromSuperview];
    self.scrollView.hidden = YES;
    
    CGRect frame = self.frame;
    frame.size.height = self.originalHeight;
    self.frame = frame;
    
    if ([self.delegate respondsToSelector:@selector(tagsContainer:didChangeHeight:)]) {
        [self.delegate tagsContainer:self didChangeHeight:self.originalHeight];
    }
    
    CGFloat currentX = 0;
    [self layoutToLabelInView:self origin:CGPointMake(self.horizontalInset, self.verticalInset) currentX:&currentX];
    [self layoutCollapsedLabelWithCurrentX:&currentX];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)layouttagsAndInputWithFrameAdjustment:(BOOL)shouldAdjustFrame {
    
    [self.collapsedLabel removeFromSuperview];
    BOOL inputFieldShouldBecomeFirstResponder = self.inputTextField.isFirstResponder;
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.scrollView.hidden = NO;
    [self removeGestureRecognizer:self.tapGestureRecognizer];
    
    self.tags = [NSMutableArray array];
    
    CGFloat currentX = 0;
    CGFloat currentY = 0;
    
    [self layoutToLabelInView:self.scrollView origin:CGPointZero currentX:&currentX];
    [self layouttagsWithCurrentX:&currentX currentY:&currentY];
    [self layoutInputTextFieldWithCurrentX:&currentX currentY:&currentY];
    
    if (shouldAdjustFrame) {
        
        [self adjustHeightForCurrentY:currentY];
    }
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width,
                                               currentY + [self heightForTag])];
    
    [self updateInputTextField];
    
    if (inputFieldShouldBecomeFirstResponder) {
        
        [self inputTextFieldBecomeFirstResponder];
    }
    else {
        [self focusInputTextField];
    }
}

- (BOOL)isCollapsed {
    
    return self.collapsedLabel.superview != nil;
}

- (void)layoutScrollView {
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     CGRectGetWidth(self.frame),
                                                                     CGRectGetHeight(self.frame))];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) - self.horizontalInset * 2,
                                             CGRectGetHeight(self.frame) - self.verticalInset * 2);
    
    self.scrollView.contentInset = UIEdgeInsetsMake(self.verticalInset,
                                                    self.horizontalInset,
                                                    self.verticalInset,
                                                    self.horizontalInset);
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self addSubview:self.scrollView];
}

- (void)layoutInputTextFieldWithCurrentX:(CGFloat *)currentX currentY:(CGFloat *)currentY {
    
    CGFloat inputTextFieldWidth = self.scrollView.contentSize.width - *currentX;
    if (inputTextFieldWidth < self.minInputWidth) {
        
        inputTextFieldWidth = self.scrollView.contentSize.width;
        *currentY += [self heightForTag];
        *currentX = 0;
    }
    
    QMBackspaceTextField *inputTextField = self.inputTextField;
    inputTextField.text = @"";
    inputTextField.frame = CGRectMake(*currentX, *currentY + 1, inputTextFieldWidth, [self heightForTag] - 1);
    inputTextField.tintColor = self.colorScheme;
    [self.scrollView addSubview:inputTextField];
}

- (void)layoutCollapsedLabelWithCurrentX:(CGFloat *)currentX {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(*currentX, CGRectGetMinY(self.toLabel.frame),
                                                               self.frame.size.width - *currentX - self.horizontalInset,
                                                               self.toLabel.frame.size.height)];
    
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:15.5];
    label.text = [self collapsedText];
    label.textColor = self.colorScheme;
    label.minimumScaleFactor = 5./label.font.pointSize;
    label.adjustsFontSizeToFitWidth = YES;
    
    [self addSubview:label];
    self.collapsedLabel = label;
}

- (void)layoutToLabelInView:(UIView *)view origin:(CGPoint)origin currentX:(CGFloat *)currentX {
    
    [self.toLabel removeFromSuperview];
    self.toLabel = [self toLabel];
    
    CGRect newFrame = self.toLabel.frame;
    newFrame.origin = origin;
    
    [self.toLabel sizeToFit];
    newFrame.size.width = CGRectGetWidth(self.toLabel.frame);
    
    self.toLabel.frame = newFrame;
    
    [view addSubview:self.toLabel];
    *currentX += self.toLabel.hidden ? CGRectGetMinX(self.toLabel.frame) : CGRectGetMaxX(self.toLabel.frame) + kQMTagsContainerDefaultToLabelPadding;
}

- (void)layouttagsWithCurrentX:(CGFloat *)currentX currentY:(CGFloat *)currentY {
    
    for (NSUInteger i = 0; i < [self numberOftags]; i++) {
        
        NSString *title = [self titleForTagAtIndex:i];
        QMTagView *tagView = [[QMTagView alloc] init];
        
        __weak QMTagView *weakTag = tagView;
        __weak __typeof(self)weakSelf = self;
        
        tagView.didTapTagBlock = ^{
            [weakSelf didTapTag:weakTag];
        };
        
        [tagView setTitleText:[NSString stringWithFormat:@"%@,", title]];
        tagView.colorScheme = [self colorSchemeForTagAtIndex:i];
        
        [self.tags addObject:tagView];
        
        if (*currentX + tagView.frame.size.width <= self.scrollView.contentSize.width) {
            // tagView fits in current line
            tagView.frame = CGRectMake(*currentX, *currentY, tagView.frame.size.width, tagView.frame.size.height);
            
        }
        else {
            
            *currentY += tagView.frame.size.height;
            *currentX = 0;
            CGFloat tagWidth = tagView.frame.size.width;
            
            if (tagWidth > self.scrollView.contentSize.width) { // tag is wider than max width
                tagWidth = self.scrollView.contentSize.width;
            }
            
            tagView.frame = CGRectMake(*currentX, *currentY, tagWidth, tagView.frame.size.height);
        }
        
        *currentX += tagView.frame.size.width + self.tagPadding;
        [self.scrollView addSubview:tagView];
    }
}


#pragma mark - Private

- (CGFloat)heightForTag {
    
    return 30;
}

- (void)layoutInvisibleTextField {
    
    self.invisibleTextField = [[QMBackspaceTextField alloc] initWithFrame:CGRectZero];
    [self.invisibleTextField setAutocorrectionType:self.autocorrectionType];
    [self.invisibleTextField setAutocapitalizationType:self.autocapitalizationType];
    self.invisibleTextField.backspaceDelegate = self;
    [self addSubview:self.invisibleTextField];
}

- (void)inputTextFieldBecomeFirstResponder {
    
    if (self.inputTextField.isFirstResponder) {
        
        return;
    }
    
    [self.inputTextField becomeFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(tagsContainerDidBeginEditing:)]) {
        
        [self.delegate tagsContainerDidBeginEditing:self];
    }
}

- (UILabel *)toLabel {
    
    if (!_toLabel) {
        
        _toLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _toLabel.textColor = self.toLabelTextColor;
        _toLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.5];
        [_toLabel sizeToFit];
        
        CGRect frame = _toLabel.frame;
        frame.size.height = [self heightForTag];
        _toLabel.frame = frame;
    }
    
    if (![_toLabel.text isEqualToString:_toLabelText]) {
        _toLabel.text = _toLabelText;
    }
    
    return _toLabel;
}

- (void)adjustHeightForCurrentY:(CGFloat)currentY {
    
    CGRect frame = self.frame;
    
    if (currentY + [self heightForTag] > CGRectGetHeight(self.frame)) { // needs to grow
        
        if (currentY + [self heightForTag] <= self.maxHeight) {
            
            frame.size.height = currentY + [self heightForTag] + self.verticalInset ;
        }
        else {
            
            frame.size.height = self.maxHeight;
        }
        
    }
    else { // needs to shrink
        
        if (currentY + [self heightForTag] > self.originalHeight) {
            
            frame.size.height = currentY + [self heightForTag] + self.verticalInset;
            
        } else {
            
            frame.size.height = self.originalHeight;
        }
    }
    
    if ((int)self.frame.size.height != (int)frame.size.height) {
        
        self.frame = frame;
        
        if ([self.delegate respondsToSelector:@selector(tagsContainer:didChangeHeight:)]) {
            
            [self.delegate tagsContainer:self didChangeHeight:frame.size.height];
        }
    }
}

- (QMBackspaceTextField *)inputTextField {
    
    if (!_inputTextField) {
        
        _inputTextField = [[QMBackspaceTextField alloc] init];
        [_inputTextField setKeyboardType:self.inputTextFieldKeyboardType];
        _inputTextField.textColor = self.inputTextFieldTextColor;
        _inputTextField.font = [UIFont fontWithName:@"HelveticaNeue" size:15.5];
        _inputTextField.autocorrectionType = self.autocorrectionType;
        _inputTextField.autocapitalizationType = self.autocapitalizationType;
        _inputTextField.tintColor = self.colorScheme;
        _inputTextField.delegate = self;
        _inputTextField.backspaceDelegate = self;
        _inputTextField.placeholder = self.placeholderText;
        _inputTextField.accessibilityLabel = self.inputTextFieldAccessibilityLabel ?: NSLocalizedString(@"To", nil);
        _inputTextField.inputAccessoryView = self.inputTextFieldAccessoryView;
        [_inputTextField addTarget:self action:@selector(inputTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    
    return _inputTextField;
}

- (void)setAutocorrectionType:(UITextAutocorrectionType)autocorrectionType {
    
    _autocorrectionType = autocorrectionType;
    [self.inputTextField setAutocorrectionType:self.autocorrectionType];
    [self.invisibleTextField setAutocorrectionType:self.autocorrectionType];
}

- (void)setInputTextFieldKeyboardType:(UIKeyboardType)inputTextFieldKeyboardType {
    
    _inputTextFieldKeyboardType = inputTextFieldKeyboardType;
    [self.inputTextField setKeyboardType:self.inputTextFieldKeyboardType];
}

- (void)setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType {
    
    _autocapitalizationType = autocapitalizationType;
    [self.inputTextField setAutocapitalizationType:self.autocapitalizationType];
    [self.invisibleTextField setAutocapitalizationType:self.autocapitalizationType];
}

- (void)inputTextFieldDidChange:(UITextField *)textField {
    
    if ([self.delegate respondsToSelector:@selector(tagsContainer:didChangeText:)]) {
        
        [self.delegate tagsContainer:self didChangeText:textField.text];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer {
    
    [self becomeFirstResponder];
}

- (void)didTapTag:(QMTagView *)tag {
    
    for (QMTagView *tagView in self.tags) {
        
        if (tagView == tag) {
            
            tagView.highlighted = !tagView.highlighted;
        }
        else {
            tagView.highlighted = NO;
        }
    }
    
    [self setCursorVisibility];
}

- (void)unhighlightAlltags {
    
    for (QMTagView *tagView in self.tags) {
        
        tagView.highlighted = NO;
    }
    
    [self setCursorVisibility];
}

- (void)setCursorVisibility {
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QMTagView *evaluatedObject,
                                                                   NSDictionary *bindings) {
        return evaluatedObject.highlighted;
    }];
    
    NSArray *highlightedtags = [self.tags filteredArrayUsingPredicate:predicate];
    
    BOOL visible = [highlightedtags count] == 0;
    
    if (visible) {
        
        [self inputTextFieldBecomeFirstResponder];
    }
    else {
        
        [self.invisibleTextField becomeFirstResponder];
    }
}

- (void)updateInputTextField {
    
    self.inputTextField.placeholder = [self.tags count] ? nil : self.placeholderText;
}

- (void)focusInputTextField {
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGFloat targetY = self.inputTextField.frame.origin.y + [self heightForTag] - self.maxHeight;
    
    if (targetY > contentOffset.y) {
        
        [self.scrollView setContentOffset:CGPointMake(contentOffset.x,
                                                      targetY)
                                 animated:NO];
    }
}

- (UIColor *)colorSchemeForTagAtIndex:(NSUInteger)index {
    
    if ([self.dataSource respondsToSelector:@selector(tagsContainer:colorSchemeForTagAtIndex:)]) {
        
        return [self.dataSource tagsContainer:self colorSchemeForTagAtIndex:index];
    }
    
    return self.colorScheme;
}

#pragma mark - Data Source

- (NSString *)titleForTagAtIndex:(NSUInteger)index {
    
    if ([self.dataSource respondsToSelector:@selector(tagsContainer:titleForTagAtIndex:)]) {
        return [self.dataSource tagsContainer:self titleForTagAtIndex:index];
    }
    
    return [NSString string];
}

- (NSUInteger)numberOftags {
    
    if ([self.dataSource respondsToSelector:@selector(numberOfTagsInTagsContainer:)]) {
        return [self.dataSource numberOfTagsInTagsContainer:self];
    }
    
    return 0;
}

- (NSString *)collapsedText {
    
    if ([self.dataSource respondsToSelector:@selector(tagsContainerCollapsedText:)]) {
        return [self.dataSource tagsContainerCollapsedText:self];
    }
    
    return @"";
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField.text length]) {
        
        if ([self.delegate respondsToSelector:@selector(tagsContainer:didEnterText:)]) {
            
            [self.delegate tagsContainer:self didEnterText:textField.text];
        }
    }
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == self.inputTextField) {
        
        [self unhighlightAlltags];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    [self unhighlightAlltags];
    
    return YES;
}


#pragma mark - QMBackspaceTextFieldDelegate

- (void)textFieldDidEnterBackspace:(QMBackspaceTextField *)textField {
    
    if ([self.delegate respondsToSelector:@selector(tagsContainer:didDeleteTagAtIndex:)] && [self numberOftags]) {
        
        BOOL didDeleteTag = NO;
        
        for (QMTagView *tagView in self.tags) {
            
            if (tagView.highlighted) {
                
                [self.delegate tagsContainer:self didDeleteTagAtIndex:[self.tags indexOfObject:tagView]];
                didDeleteTag = YES;
                
                break;
            }
        }
        
        if (!didDeleteTag) {
            
            QMTagView *lastTagView = [self.tags lastObject];
            lastTagView.highlighted = YES;
        }
        
        [self setCursorVisibility];
    }
}

@end


@implementation QMBackspaceTextField

- (BOOL)keyboardInputShouldDelete:(UITextField *)textField {
    
    if (self.text.length == 0) {
        
        if ([self.backspaceDelegate respondsToSelector:@selector(textFieldDidEnterBackspace:)]) {
            [self.backspaceDelegate textFieldDidEnterBackspace:self];
        }
    }
    
    return YES;
}

@end

@interface QMTagView ()

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;

@end

@implementation QMTagView

- (void)dealloc {
    
    self.tapGestureRecognizer = nil;
    self.titleLabel = nil;
    self.backgroundView = nil;
    self.didTapTagBlock = nil;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [[[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    
    if (self) {
        
        [self configure];
    }
    
    return self;
}

- (void)configure {
    
    self.backgroundView.layer.cornerRadius = 5;
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(didTapTag:)];
    self.colorScheme = [UIColor blueColor];
    self.titleLabel.textColor = self.colorScheme;
    [self addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)setTitleText:(NSString *)text {
    
    self.titleLabel.text = text;
    self.titleLabel.textColor = self.colorScheme;
    [self.titleLabel sizeToFit];
    
    self.frame = CGRectMake(CGRectGetMinX(self.frame),
                            CGRectGetMinY(self.frame),
                            CGRectGetMaxX(self.titleLabel.frame) + 3,
                            CGRectGetHeight(self.frame));
    
    [self.titleLabel sizeToFit];
}

- (void)setHighlighted:(BOOL)highlighted {
    
    _highlighted = highlighted;
    
    UIColor *textColor = highlighted ? [UIColor whiteColor] : self.colorScheme;
    UIColor *backgroundColor = highlighted ? self.colorScheme : [UIColor clearColor];
    
    self.titleLabel.textColor = textColor;
    self.backgroundView.backgroundColor = backgroundColor;
}

- (void)setColorScheme:(UIColor *)colorScheme {
    
    _colorScheme = colorScheme;
    self.titleLabel.textColor = self.colorScheme;
    [self setHighlighted:_highlighted];
}


#pragma mark - Private

- (void)didTapTag:(UITapGestureRecognizer *)tapGestureRecognizer {
    
    if (self.didTapTagBlock) {
        self.didTapTagBlock();
    }
}

@end
