//
//  QMCreateGroupVC.m
//  Q-municate
//
//  Created by Andrey Ivanov on 23.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMCreateGroupVC.h"
#import "QMCreateGroupHeaderView.h"
#import "QMTagsContainer.h"
#import "QMContactListVC.h"

@interface QMCreateGroupVC()

<QMContactListDataSourceHandler, QMTagsContainerDataSource, QMTagsContainerDelegate>

@property (weak, nonatomic) IBOutlet QMTagsContainer *tagsContainer;
@property (weak, nonatomic) QMContactListVC *contactListVC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation QMCreateGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tagsContainer.delegate = self;
    self.tagsContainer.dataSource = self;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString: @"QMContactListVC"]) {
        
        QMContactListVC * childViewController = (id)[segue destinationViewController];
        self.contactListVC = childViewController;
        self.contactListVC.contactListDatasource.handler = self;
    }
}

#pragma mark QMContactListDataSourceHandler

- (void)didUpdateContactListDataSource:(QMContactListDataSource *)datasource {
    
    if (datasource.selectedObjects.count > 5) {
        
        [self.tagsContainer collapse];
    }
    else {
        
        [self.tagsContainer reloadData];
    }
}

#pragma mark QMTagsContainerDelegate
/** Is called when a user hits the return key on the input field. */
- (void)tagsContainer:(QMTagsContainer *)container didEnterText:(NSString *)text {
    
}

/** Is called when a user deletes a tag at a particular index. */
- (void)tagsContainer:(QMTagsContainer *)container didDeleteTagAtIndex:(NSUInteger)index {
    
}

/** Is called when a user changes the text in the input field. */
- (void)tagsContainer:(QMTagsContainer *)container didChangeText:(NSString *)text {
    
}

/** is called when the input field becomes first responder */
- (void)tagsContainerDidBeginEditing:(QMTagsContainer *)container {
    
}

- (void)tagsContainer:(QMTagsContainer *)container didChangeHeight:(CGFloat)height {
    
    self.headerHeight.constant = container.frame.origin.y + height;
    [UIView animateWithDuration:.4 animations:^{
        [self.containerView layoutIfNeeded];
    }];
}

#pragma mark QMTagsContainerDataSource

/** To specify what the title for the tag at a particular index should be. */
- (NSString *)tagsContainer:(QMTagsContainer *)container titleForTagAtIndex:(NSUInteger)index {

    QBUUser *user = self.contactListVC.contactListDatasource.selectedObjects[index];
    return user.fullName;
}

/** To specify how many tags you have. */
- (NSUInteger)numberOfTagsInTagsContainer:(QMTagsContainer *)container {
    
    return self.contactListVC.contactListDatasource.selectedObjects.count;
}

/** To specify what you want the tags container to say in the collapsed state. */
- (NSString *)tagsContainerCollapsedText:(QMTagsContainer *)container {

    return [NSString stringWithFormat:@"Selected %tu", self.contactListVC.contactListDatasource.selectedObjects.count];
}

/** Color for tag at index */
- (UIColor *)tagsContainer:(QMTagsContainer *)container colorSchemeForTagAtIndex:(NSUInteger)index {
    
    return [UIColor colorWithRed:0.377 green:0.627 blue:1.000 alpha:1.000];
}

@end
