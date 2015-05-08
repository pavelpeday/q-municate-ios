//
//  QMChatVC.m
//  Q-municate
//
//  Created by Andrey Ivanov on 30.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMChatVC.h"
#import "QMBubbleImage.h"
#import "QMChatBubbleImageFactory.h"
#import "QMPlaceholder.h"
#import "REActionSheet.h"
#import "QMServicesManager.h"
#import "QMImagePicker.h"

#import "UIColor+QM.h"
#import "UIImage+QM.h"

@interface QMChatVC () <QMChatServiceDelegate>

@property (strong, nonatomic) NSMutableArray *array;
@property (strong, nonatomic) QMBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) QMBubbleImage *incomingBubbleImageData;

@end

@implementation QMChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //Cofigure sender
    QBUUser *sender = QM.profile.userData;
    self.senderID = sender.ID;
    self.senderDisplayName = sender.fullName;
    
    QBUUser *opponent = [QM.contactListService usersWithoutMeWithIDs:self.chatDialog.occupantIDs].firstObject;
    
    self.title = opponent.fullName;
    // Do any additional setup after loading the view, typically from a nib.
    QMChatBubbleImageFactory *bubbleFactory = [[QMChatBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor messageBubbleGreenColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor whiteColor]];
    self.showLoadEarlierMessagesHeader = YES;
    
    self.array = [NSMutableArray array];
    //Get messages
    [QM.chatService messageWithChatDialogID:self.chatDialog.ID completion:^(QBResponse *response, NSArray *messages) {
        
        [self.collectionView reloadData];
    }];
    
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
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

- (void)chatServiceDidLoadMessagesFromCacheForDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        
        NSArray *cahcedMessages = [QM.chatService.messagesMemoryStorage messagesWithDialogID:dialogID];
        [self.array addObjectsFromArray:cahcedMessages];
        [self.collectionView reloadData];
        [self scrollToBottomAnimated:NO];
    }
}

- (void)chatServiceDidAddMessagesToHistroy:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        
        NSArray *cahcedMessages = [QM.chatService.messagesMemoryStorage messagesWithDialogID:dialogID];
        [self.array removeAllObjects];
        [self.array addObjectsFromArray:cahcedMessages];
        [self.collectionView reloadData];
    }
}

- (void)chatServiceDidAddMessageToHistory:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        
        [self.array addObject:message];
        [self.collectionView reloadData];
        [self scrollToBottomAnimated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.collectionView.collectionViewLayout.springResistanceFactor = 1000;
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (UICollectionViewCell *)collectionView:(QMChatCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  Override point for customizing cells
     */
    QMChatCollectionViewCell *cell = (id)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    QBChatMessage *msg = self.array[indexPath.row];
    
    cell.textView.textColor = msg.senderID == self.senderID ?  [UIColor blackColor] : [UIColor whiteColor];
    
    return cell;
}

#pragma mark - QBChatMessage CollectionView DataSource

- (NSAttributedString *)collectionView:(QMChatViewController *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    return [[NSAttributedString alloc] initWithString:@"Hello"];
}

- (NSAttributedString *)collectionView:(QMChatViewController *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *message = [self.array objectAtIndex:indexPath.item];
    /** *  iOS7-style sender name labels */
    if (message.senderID == self.senderID) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        
        QBChatMessage *previousMessage = [self.array objectAtIndex:indexPath.item - 1];
        if (previousMessage.senderID == message.senderID) {
            
            return nil;
        }
    }
    /**
     *  Don't specify attributes to use the defaults.
     */
    if (message.messageType == QMMessageTypeDefault) {
        
        return [[NSAttributedString alloc] initWithString:message.senderNick];
        
    } else if (message.messageType == QMMessageTypeNotificationAboutCreateGroupDialog) {
        
        return [[NSAttributedString alloc] initWithString:@"crete dialog"];
    }
    else if (message.messageType == QMMessageTypeNotificationAboutSendContactRequest) {
        
        return [[NSAttributedString alloc] initWithString:@"Contact request"];
    }
    else if (message.messageType == QMMessageTypeNotificationAboutRejectContactRequest) {
        
        return [[NSAttributedString alloc] initWithString:@"Reject contact request"];
    }
    else if (message.messageType == QMMessageTypeNotificationAboutConfirmContactRequest) {
        
        return [[NSAttributedString alloc] initWithString:@"Confirm contact request"];
    }
    
    
    return [[NSAttributedString alloc] initWithString:message.senderNick];
}

- (id<QMChatMessageData>)collectionView:(QMChatViewController *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.array[indexPath.row];
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.array count];
}

- (id<QMChatBubbleImageDataSource>)collectionView:(QMChatCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *msg = self.array[indexPath.item];
    
    if (msg.senderID == QM.profile.userData.ID) {
        
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<QMChatAvatarImageDataSource>)collectionView:(QMChatCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}

- (CGFloat)collectionView:(QMChatCollectionView *)collectionView
                   layout:(QMChatCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *msg = self.array[indexPath.row];
    
//    if (msg.senderID == self.senderID ) {
//        return 0.0f;
//    }
//    
//    if (indexPath.item - 1 > 0) {
//        
//        QBChatMessage *previousMessage = [self.array objectAtIndex:indexPath.item - 1];
//        if (previousMessage.senderID == msg.senderID) {
//            
//            return 0.0f;
//        }
//    }
    
    return kQMChatCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(QMChatCollectionView *)collectionView
                   layout:(QMChatCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    return 20;
}

- (CGFloat)collectionView:(QMChatCollectionView *)collectionView
                   layout:(QMChatCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    return kQMChatCollectionViewCellLabelHeightDefault;
}

- (NSAttributedString *)collectionView:(QMChatCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    UIColor *color = [UIColor lightGrayColor];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    QBChatMessage *msg = self.array[indexPath.row];
    
    if (msg.senderID == self.senderID ) {
        paragraphStyle.alignment = NSTextAlignmentRight;
    }
    /**
     *  Set bottom Lable attribues
     */
    NSDictionary *dateTextAttributes =
    @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0f],
       NSForegroundColorAttributeName : color,
       NSParagraphStyleAttributeName : paragraphStyle };
    
    return [[NSAttributedString alloc] initWithString:@"Hello" attributes:dateTextAttributes];
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
    
    NSString *sendTitle = @"Send";
    
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
    sendButton.frame = CGRectMake(0.0f,
                                  0.0f,
                                  CGRectGetWidth(CGRectIntegral(sendTitleRect)),
                                  maxHeight);
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
    
    [QM.chatService sendMessage:message toDialog:self.chatDialog type:QMMessageTypeDefault save:YES completion:^(NSError *error) {
        
        [self finishSendingMessageAnimated:YES];
        
    }];
    
}

#pragma mark Nav bar

- (void)pressGroupInfo:(id)sender {
    
}


@end
