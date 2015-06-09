//
//  QMChatVC.m
//  Q-municate
//
//  Created by Andrey Ivanov on 30.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMChatVC.h"
#import "QMPlaceholder.h"
#import "REActionSheet.h"
#import "QMServicesManager.h"
#import "QMImagePicker.h"
#import "TTTAttributedLabel.h"
#import "QMMapViewController.h"

#import "QMMessageText.h"
#import "QMChatActionsHandler.h"

#import "UIColor+QM.h"
#import "UIImage+QM.h"

@interface QMChatVC () <QMChatServiceDelegate, QMChatActionsHandler>

@end

@implementation QMChatVC


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.actionsHandler = self;
    
    QBUUser *sender = QM.profile.userData;
    self.senderID = sender.ID;
    self.senderDisplayName = sender.fullName;
    //Cofigure sender
    QBUUser *opponent = [QM.contactListService.usersMemoryStorage usersWithIDs:self.chatDialog.occupantIDs
                                                                     withoutID:QM.profile.userData.ID].firstObject;
    
    self.title = opponent.fullName;
    self.items = [NSMutableArray array];
    //Get messages
    [QM.chatService messagesWithChatDialogID:self.chatDialog.ID completion:^(QBResponse *response, NSArray *messages) {}];
    
    //Configure navigation bar
    
    if (self.chatDialog.type == QBChatDialogTypeGroup) {
        
        UIImage *placeholder = [QMPlaceholder placeholderWithFrame:CGRectMake(0, 0, 30, 30) fullName:self.chatDialog.name];

        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithImage:placeholder
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(pressGroupInfo:)];
    }
    else {
        
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_video_chat"]
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(pressConference:)];
    }
    //Customize your toolbar buttons
    self.inputToolbar.contentView.leftBarButtonItem = [self accessoryButtonItem];
    self.inputToolbar.contentView.rightBarButtonItem = [self sendButtonItem];
    //Subscribe to chat notifications
    [QM.chatService addDelegate:self];
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService didLoadMessagesFromCache:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        
        NSArray *cahcedMessages = [QM.chatService.messagesMemoryStorage messagesWithDialogID:dialogID];
        [self.items addObjectsFromArray:cahcedMessages];
        [self.collectionView reloadData];
        [self scrollToBottomAnimated:NO];
    }
}

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        
        [self.items addObject:message];
        [self finishReceivingMessage];
    }
}

- (void)chatServiceDidAddMessageToHistory:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        [self.items addObject:message];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.collectionView.collectionViewLayout.springResistanceFactor = 1000;
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (Class)viewClassForItem:(QBChatMessage *)item {
    
    if (item.messageType == QMMessageTypeContactRequest) {
        
        if (item.senderID != self.senderID) {
            
            return [QMChatContactRequestCell class];
        }
    }
    
    else if (item.messageType == QMMessageTypeRejectContactRequest) {
        
        return [QMChatNotificationCell class];
    }
    
    else if (item.messageType == QMMessageTypeAcceptContactRequest) {
        
        return [QMChatNotificationCell class];
    }
    else if (item.messageType == QMMessageTypeText) {
        
        if (item.senderID != self.senderID) {
            
            return [QMChatIncomingCell class];
        }
        else {
            
            return [QMChatOutgoingCell class];
        }
    }
    
    return nil;
}

- (QMChatCellLayoutModel)collectionView:(QMChatCollectionView *)collectionView layoutModelAtIndexPath:(NSIndexPath *)indexPath {
    
    QMChatCellLayoutModel model = [super collectionView:collectionView layoutModelAtIndexPath:indexPath];
    
    if(self.chatDialog.type == QBChatDialogTypePrivate) {
        
        model.topLabelHeight = 0;
    }
    
    return model;
}

- (CGSize)collectionView:(QMChatCollectionView *)collectionView dynamicSizeAtIndexPath:(NSIndexPath *)indexPath maxWidth:(CGFloat)maxWidth {
    
    QBChatMessage *item = self.items[indexPath.item];
    
    NSAttributedString *attributedString = [self attributedStringForItem:item];
    
    CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                   withConstraints:CGSizeMake(maxWidth, MAXFLOAT)
                                            limitedToNumberOfLines:0];
    return size;
}

- (CGFloat)collectionView:(QMChatCollectionView *)collectionView minWidthAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *item = self.items[indexPath.item];
    
    NSAttributedString *attributedString =
    [item senderID] == self.senderID ?  [self bottomLabelAttributedStringForItem:item] : [self topLabelAttributedStringForItem:item];
    
    CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                   withConstraints:CGSizeMake(1000, 10000)
                                            limitedToNumberOfLines:1];
    
    CGSize size1 = [TTTAttributedLabel sizeThatFitsAttributedString:[self bottomLabelAttributedStringForItem:item]
                                                    withConstraints:CGSizeMake(1000, 10000)
                                             limitedToNumberOfLines:1];
    
    return MAX(size.width, size1.width);
}

- (NSAttributedString *)attributedStringForItem:(QBChatMessage *)messageItem {
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:15];
    
    NSString *str = [QMMessageText textForMessage:messageItem currentUserID:self.senderID];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    if (messageItem.messageType == QMMessageTypeText) {
        
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.alignment = NSTextAlignmentJustified;
        
        UIColor *textColor = [messageItem senderID] == self.senderID ? [UIColor whiteColor] : [UIColor colorWithWhite:0.290 alpha:1.000];
        NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
        [attrStr addAttributes:attributes range:NSMakeRange(0, str.length)];
        
    }
    else  {
        
        UIColor *textColor = [UIColor whiteColor];
        
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor,
                                      NSFontAttributeName:font,
                                      NSParagraphStyleAttributeName:paragraphStyle};
        
        [attrStr addAttributes:attributes range:NSMakeRange(0, str.length)];
        
        if ([messageItem senderID] == self.senderID) {
            
            UIFont *timeStampFont = [UIFont fontWithName:@"Helvetica" size:12];
            NSDictionary *timeAttributes = @{ NSForegroundColorAttributeName:[UIColor colorWithWhite:1.000 alpha:0.480], NSFontAttributeName:timeStampFont};
            NSAttributedString *timeStamp = [[NSAttributedString alloc] initWithString:[self timeStampWithDate:messageItem.dateSent] attributes:timeAttributes];
            
            [attrStr appendAttributedString:timeStamp];
        }
    }
    
    return attrStr;
}

- (NSAttributedString *)topLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:14];
    
    if ([messageItem senderID] == self.senderID || self.chatDialog.type == QBChatDialogTypePrivate) {
        return nil;
    }
    
    QBUUser *user = [QM.contactListService.usersMemoryStorage userWithID:messageItem.senderID];
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:[UIColor colorWithRed:0.184 green:0.467 blue:0.733 alpha:1.000], NSFontAttributeName:font};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:user.fullName attributes:attributes];
    
    return attrStr;
}

- (NSAttributedString *)bottomLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    UIColor *textColor = [messageItem senderID] == self.senderID ? [UIColor colorWithWhite:1.000 alpha:0.510] : [UIColor colorWithWhite:0.000 alpha:0.490];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
    NSString *timeStamp = [self timeStampWithDate:messageItem.dateSent];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:timeStamp attributes:attributes];
    
    return attrStr;
}

- (NSString *)timeStampWithDate:(NSDate *)date {
    
    static NSDateFormatter *dateFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @" HH:mm";
    });
    
    NSString *timeStamp = [dateFormatter stringFromDate:date];
    
    return timeStamp;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.items.count;
}

#pragma mark - Buttons factory

- (UIButton *)accessoryButtonItem {
    
    UIImage *accessoryImage = [UIImage imageNamed:@"attachment_ic"];
    UIImage *normalImage = [accessoryImage imageMaskedWithColor:[UIColor lightGrayColor]];
    UIImage *highlightedImage = [accessoryImage imageMaskedWithColor:[UIColor darkGrayColor]];
    
    UIButton *accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, accessoryImage.size.width, 32.0f)];
    [accessoryButton setImage:normalImage forState:UIControlStateNormal];
    [accessoryButton setImage:highlightedImage forState:UIControlStateHighlighted];
    
    accessoryButton.contentMode = UIViewContentModeScaleAspectFit;
    accessoryButton.backgroundColor = [UIColor clearColor];
    accessoryButton.tintColor = [UIColor lightGrayColor];
    
    return accessoryButton;
}

- (UIButton *)sendButtonItem {
    
    NSString *sendTitle = NSLocalizedString(@"Send", nil);
    
    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [sendButton setTitle:sendTitle forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [sendButton setTitleColor:[[UIColor blueColor] colorByDarkeningColorWithValue:0.1f] forState:UIControlStateHighlighted];
    [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    sendButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    sendButton.titleLabel.minimumScaleFactor = 0.85f;
    sendButton.contentMode = UIViewContentModeCenter;
    sendButton.backgroundColor = [UIColor clearColor];
    sendButton.tintColor = [UIColor blueColor];
    
    CGFloat maxHeight = 32.0f;
    
    CGRect sendTitleRect = [sendTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, maxHeight)
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                attributes:@{ NSFontAttributeName : sendButton.titleLabel.font }
                                                   context:nil];
    
    sendButton.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(CGRectIntegral(sendTitleRect)), maxHeight);
    
    return sendButton;
}

#pragma mark - Actions
#pragma mark - Tool bar

- (void)didPressAccessoryButton:(UIButton *)sender {
    
    [REActionSheet presentActionSheetInView:self.view configuration:^(REActionSheet *actionSheet) {
        
        [actionSheet addButtonWithTitle:@"Take Video" andActionBlock:^{}];
        [actionSheet addButtonWithTitle:@"Share image" andActionBlock:^{
            
            [QMImagePicker presentInViewController:self configure:^(UIImagePickerController *picker) {
                
            } resultImage:^(UIImage *image) {
                
            }];
        }];
        
        [actionSheet addButtonWithTitle:@"Share Location" andActionBlock:^{
            
            [self performSegueWithIdentifier:@"QMMapViewController" sender:self];
        
        }];
        [actionSheet addCancelButtonWihtTitle:@"Cancel" andActionBlock:^{}];
    }];
}

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSUInteger)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    
    QBChatMessage *message = [QBChatMessage message];
    message.text = text;
    message.senderID = senderId;
    
    QBChatAttachment *attacment = [[QBChatAttachment alloc] init];
    message.attachments = @[attacment];
    
    button.enabled = NO;
    
    [QM.chatService sendMessage:message toDialog:self.chatDialog save:YES completion:^(NSError *error) {
        
        button.enabled = YES;
        [self finishSendingMessageAnimated:NO];
    }];
}

#pragma mark - QMChatActionsHandler

- (void)chatContactRequestDidAccept:(BOOL)accept sender:(id)sender {
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    QBChatMessage *message = self.items[indexPath.item];
    
    void(^compeltion)(BOOL success) = ^(BOOL success) {
        
        [QM.chatService notifyOponentAboutAcceptingContactRequest:accept opponentID:message.senderID completion:^(NSError *error) {
            [self.collectionView.collectionViewLayout invalidateLayout];
        }];
    };
    
    if (accept) {
        
        [QM.contactListService acceptContactRequest:message.senderID completion:compeltion];
    }
    else {
        
        [QM.contactListService rejectContactRequest:message.senderID completion:compeltion];
    }
}

- (void)chatContactRequestDidAccept:(id)sender {
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    QBChatMessage *message = self.items[indexPath.item];
    
    [QM.contactListService acceptContactRequest:message.senderID completion:^(BOOL success) {
        
    }];
}

#pragma mark Nav bar Actions

- (void)pressGroupInfo:(id)sender {
    
}

- (void)pressConference:(id)sender {
    
    [REActionSheet presentActionSheetInView:self.view configuration:^(REActionSheet *actionSheet) {
        
        [actionSheet addButtonWithTitle:@"Audio call" andActionBlock:^{}];
        [actionSheet addButtonWithTitle:@"Video call" andActionBlock:^{}];
        [actionSheet addCancelButtonWihtTitle:@"Cancel" andActionBlock:^{}];
    }];
}

@end
