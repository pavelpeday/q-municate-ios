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
    UIImage *placeholder = [QMPlaceholder placeholderWithFrame:CGRectMake(0, 0, 30, 30) fullName:self.chatDialog.name];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:placeholder style:UIBarButtonItemStyleBordered target:self
                                    action:@selector(pressGroupInfo:)];
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
    }
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID{
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        
        NSArray *cahcedMessages = [QM.chatService.messagesMemoryStorage messagesWithDialogID:dialogID];
        [self.items removeAllObjects];
        [self.items addObjectsFromArray:cahcedMessages];
        [self.collectionView reloadData];
    }
}

- (void)chatServiceDidAddMessageToHistory:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        [self.items addObject:message];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.collectionView.collectionViewLayout.springResistanceFactor = 2000;
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (CGSize)collectionView:(QMChatCollectionView *)collectionView dynamicSizeAtIndexPath:(NSIndexPath *)indexPath maxWidth:(CGFloat)maxWidth {
    
    QBChatMessage *item = self.items[indexPath.item];
    
    NSAttributedString *attributedString = [self attributedStringForItem:item];
    
    CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                   withConstraints:CGSizeMake(maxWidth, MAXFLOAT)
                                            limitedToNumberOfLines:0];
    return size;
}

- (NSAttributedString *)attributedStringForItem:(QBChatMessage *)messageItem {
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:15];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:font};
    NSString *str = [QMMessageText textForMessage:messageItem currentUserID:self.senderID];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:attributes];
    
    if (messageItem.messageType == QMMessageTypeContactRequest) {
        
        if ([messageItem senderID] == self.senderID) {
            
            [self appendTimeStampForAttributedString:attrStr date:messageItem.dateSent];
        }
    } else {
        
        [self appendTimeStampForAttributedString:attrStr date:messageItem.dateSent];
    }

    
    return attrStr;
}

- (void)appendTimeStampForAttributedString:(NSMutableAttributedString *)attrStr date:(NSDate *)date {
    
    static NSDateFormatter *dateFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @" HH:mm";
    });
    
    NSString *timeStamp = [dateFormatter stringFromDate:date];
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:15];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:[UIColor colorWithWhite:1.000 alpha:0.660], NSFontAttributeName:font };
    NSAttributedString *attributedTimeStamp = [[NSAttributedString alloc] initWithString:timeStamp attributes:attributes];
    
    [attrStr appendAttributedString:attributedTimeStamp];
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
        
        [actionSheet addButtonWithTitle:@"Take Video" andActionBlock:^{
            
        }];
        
        [actionSheet addButtonWithTitle:@"Share image" andActionBlock:^{
            
            [QMImagePicker presentIn:self configure:^(UIImagePickerController *picker) {
                
            } result:^(UIImage *image) {
                
            }];
        }];
        
        [actionSheet addButtonWithTitle:@"Share Location" andActionBlock:^{
            
        }];
        
        [actionSheet addCancelButtonWihtTitle:@"Cancel" andActionBlock:^{
            
        }];
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
        
        [QM.chatService notifyOponentAboutAcceptContactRequest:accept opponent:message.senderID completion:^(NSError *error) {
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

#pragma mark Nav bar

- (void)pressGroupInfo:(id)sender {
    
}


@end
