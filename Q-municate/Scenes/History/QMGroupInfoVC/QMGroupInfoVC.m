//
//  QMGroupInfoVC.m
//  Q-municate
//
//  Created by Andrey Ivanov on 23.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMGroupInfoVC.h"
#import "QMGroupInfoHeaderView.h"
#import "QMContactListDataSource.h"
#import "QMTagsContainer.h"
#import "QMContactListVC.h"
#import "QMImagePicker.h"
#import "QMImageView.h"
#import "QMServicesManager.h"
#import "SVProgressHUD.h"
#import "QMChatVC.h"

const NSUInteger kQMMaxTagsCount = 5;

@interface QMGroupInfoVC()

<QMContactListDataSourceHandler, QMTagsContainerDataSource, QMTagsContainerDelegate, QMImageViewDelegate>

@property (weak, nonatomic) IBOutlet QMTagsContainer *tagsContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property (weak, nonatomic) IBOutlet QMGroupInfoHeaderView *headerView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) QMContactListVC *contactListVC;
@property (strong, nonatomic) UIImage *selectedImage;

@end

@implementation QMGroupInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tagsContainer.delegate = self;
    self.tagsContainer.dataSource = self;
    self.headerView.qm_imageView.delegate = self;
}

#pragma mark QMContactListDataSourceHandler

- (void)didUpdateContactListDataSource:(QMContactListDataSource *)datasource {
    
    if (datasource.selectedObjects.count > kQMMaxTagsCount) {
        
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

#pragma mark - QMImageViewDelegate

- (void)imageViewDidTap:(QMImageView *)imageView {
    
    [QMImagePicker chooseSourceTypeInVC:self allowsEditing:YES result:^(UIImage *image) {
        
        self.selectedImage = image;
        [self.headerView.qm_imageView applyImage:image];
    }];
}

#pragma mark - Actions

- (IBAction)pressRightNavItem:(id)sender {
    
    void (^createGroupBlock)(id, id, id) = ^(NSString *groupName, NSString *photo, NSArray *occupants) {
        
        [SVProgressHUD show];
        [QM.chatService createGroupChatDialogWithName:groupName
                                                photo:photo
                                            occupants:occupants
                                           completion:^(QBResponse *response, QBChatDialog *createdDialog)
         {
             if (response.success) {
                 //Make notificaiton message
                 QBChatMessage *message = [QBChatMessage message];
                 message.text = @"Notification message";
                 //Send notification message
                 [self performSegueWithIdentifier:@"ChatViewController" sender:createdDialog];
                 
                 [QM.chatService sendMessage:message
                                    toDialog:createdDialog
                                        type:QMMessageTypeNotificationAboutSendContactRequest
                                        save:YES
                                  completion:^(NSError *error)
                  {
                      NSLog(@"Send contact request");
                  }];
             }
             
             [SVProgressHUD dismiss];
         }];
    };
    //Get occupants
    NSArray *occupants = self.contactListVC.contactListDatasource.selectedObjects;
    
    if (occupants.count == 0) {
        
        [SVProgressHUD showErrorWithStatus:@"Please select any users"];
    }
    //Get group name
    NSString *groupName = self.headerView.groupNameTextField.text;
    if (groupName.length == 0) {
        
        groupName = @"unnamed";//self.tagsContainer.text;
        NSAssert(groupName.length > 0, @"Need update this case");
    }
    
    if (self.selectedImage) {
        
        NSData *data = UIImageJPEGRepresentation(self.selectedImage, 0.6);
        [SVProgressHUD showProgress:0 maskType:SVProgressHUDMaskTypeClear];
        
        [QBRequest TUploadFile:data
                      fileName:@"photo"
                   contentType:@"image/jpeg"
                      isPublic:YES
                  successBlock:^(QBResponse *response, QBCBlob *blob)
         {
             createGroupBlock(groupName, blob.publicUrl, occupants);
             
         } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
             
             [SVProgressHUD showProgress:status.percentOfCompletion maskType:SVProgressHUDMaskTypeClear];
             
         } errorBlock:^(QBResponse *response) {
             
         }];
    }
    else {
        
        createGroupBlock(groupName, nil, occupants);
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString: @"ChatViewController"]) {
        
        QMChatVC *chatVC = segue.destinationViewController;
        chatVC.chatDialog = sender;
        
    } else  if ([segue.identifier isEqualToString: @"QMContactListVC"]) {
        //Get embed contact list view controller
        QMContactListVC * childViewController = (id)[segue destinationViewController];
        self.contactListVC = childViewController;
        self.contactListVC.contactListDatasource.handler = self;
    }
}

@end
