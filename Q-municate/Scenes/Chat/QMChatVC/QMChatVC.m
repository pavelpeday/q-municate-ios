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

#import "QMChatContactRequestCell.h"
#import "QMChatNotificationCell.h"
#import "QMChatOutgoingCell.h"
#import "QMChatIncomingCell.h"
#import "QMMessageText.h"

#import "UIColor+QM.h"
#import "UIImage+QM.h"

@interface QMChatVC () <QMChatServiceDelegate>

@property (strong, nonatomic) NSMutableArray *messages;

@end

@implementation QMChatVC

- (void)viewDidLoad {
    
    QBUUser *sender = QM.profile.userData;
    self.senderID = sender.ID;
    self.senderDisplayName = sender.fullName;
    
    [super viewDidLoad];
    //Cofigure sender
    [self registerCells];
    
    QBUUser *opponent = [QM.contactListService.usersMemoryStorage usersWithIDs:self.chatDialog.occupantIDs withoutID:QM.profile.userData.ID].firstObject;
    
    self.title = opponent.fullName;
    
    self.messages = [NSMutableArray array];
    //Get messages
    [QM.chatService messageWithChatDialogID:self.chatDialog.ID completion:^(QBResponse *response, NSArray *messages) {}];
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

- (void)registerCells {
    /**
     *  Register contact request cell
     */
    UINib *requestNib = [QMChatContactRequestCell nib];
    NSString *requestIdentifier = [QMChatContactRequestCell cellReuseIdentifier];
    [self.collectionView registerNib:requestNib forCellWithReuseIdentifier:requestIdentifier];
    /**
     *  Register Notification  cell
     */
    UINib *notificationNib = [QMChatNotificationCell nib];
    NSString *notificationIdentifier = [QMChatNotificationCell cellReuseIdentifier];
    [self.collectionView  registerNib:notificationNib forCellWithReuseIdentifier:notificationIdentifier];
    /**
     *  Register outgoing cell
     */
    UINib *outgoingNib = [QMChatOutgoingCell nib];
    NSString *ougoingIdentifier = [QMChatOutgoingCell cellReuseIdentifier];
    [self.collectionView  registerNib:outgoingNib forCellWithReuseIdentifier:ougoingIdentifier];
    /**
     *  Register incoming cell
     */
    UINib *incomingNib = [QMChatIncomingCell nib];
    NSString *incomingIdentifier = [QMChatIncomingCell cellReuseIdentifier];
    [self.collectionView  registerNib:incomingNib forCellWithReuseIdentifier:incomingIdentifier];
}

#pragma mark - QMChatServiceDelegate

- (void)chatServiceDidLoadMessagesFromCacheForDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        
        NSArray *cahcedMessages = [QM.chatService.messagesMemoryStorage messagesWithDialogID:dialogID];
        [self.messages addObjectsFromArray:cahcedMessages];
        [self.collectionView reloadData];
        [self scrollToBottomAnimated:NO];
    }
}

- (void)chatServiceDidAddMessagesToHistroy:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        
        NSArray *cahcedMessages = [QM.chatService.messagesMemoryStorage messagesWithDialogID:dialogID];
        [self.messages removeAllObjects];
        [self.messages addObjectsFromArray:cahcedMessages];
        [self.collectionView reloadData];
    }
}

- (void)chatServiceDidAddMessageToHistory:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        [self.messages addObject:message];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.collectionView.collectionViewLayout.springResistanceFactor = 2000;
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (Class)viewClassForItem:(QBChatMessage *)item {
    
    if (item.messageType == QMMessageTypeText) {
        
        return (item.senderID == self.senderID) ? [QMChatOutgoingCell class] : [QMChatIncomingCell class];
    }
    else if (item.messageType == QMMessageTypeContactRequest) {
        
        if (item.senderID != self.senderID) {
            
            return [QMChatContactRequestCell class];
        }
    }
    
    return [QMChatNotificationCell class];
}

- (CGSize)collectionView:(QMChatCollectionView *)collectionView sizeForContainerAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *msg = self.messages[indexPath.item];
    
    Class class = [self viewClassForItem:msg];
    NSAttributedString *attributedString = [self attributedStringForItem:msg];
    
    BOOL isDynamicSize = [class isDynamicSize];
    CGSize size = isDynamicSize ? [class itemSizeWithAttriburedString:attributedString] : [class size];
    
    NSAssert(!CGSizeEqualToSize(size, CGSizeZero), @"Size == CGSizeZero");
    
    return size;
}

- (UICollectionViewCell *)collectionView:(QMChatCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *messageItem = self.messages[indexPath.row];
    
    Class class = [self viewClassForItem:messageItem];
    NSString *itemIdentifier = [class cellReuseIdentifier];
    
    QMChatCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:itemIdentifier forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[QMChatContactRequestCell class]]) {
        
    }
    
    cell.textView.attributedText = [self attributedStringForItem:messageItem];
    
    return cell;
}

- (NSAttributedString *)attributedStringForItem:(QBChatMessage *)messageItem {
    
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:font };
    NSString *str = [QMMessageText textForMessage:messageItem currentUserID:self.senderID];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:attributes];
    
    if (messageItem.messageType == QMMessageTypeContactRequest) {
        
        if ([messageItem senderID] == self.senderID) {
            
            [self appendTimeStampForAttributedString:attrStr date:messageItem.dateSent];
        }
    }

    [self appendTimeStampForAttributedString:attrStr date:messageItem.dateSent];
    
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
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:14];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:[UIColor colorWithWhite:1.000 alpha:0.660], NSFontAttributeName:font };
    NSAttributedString *attributedTimeStamp = [[NSAttributedString alloc] initWithString:timeStamp attributes:attributes];
    
    [attrStr appendAttributedString:attributedTimeStamp];
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.messages.count;
}

- (UIEdgeInsets)collectionView:(QMChatCollectionView *)collectionView
                        layout:(QMChatCollectionViewFlowLayout *)collectionViewLayout insetsForCellContainerViewAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *messageItem = self.messages[indexPath.item];
    
    Class class = [self viewClassForItem:messageItem];
    return [class containerInsets];
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

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSUInteger)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    
    QBChatMessage *message = [QBChatMessage message];
    message.text = text;
    message.senderID = senderId;
    
    QBChatAttachment *attacment = [[QBChatAttachment alloc] init];
    message.attachments = @[attacment];
    
    button.enabled = NO;
    
    [QM.chatService sendMessage:message toDialog:self.chatDialog type:QMMessageTypeText save:YES completion:^(NSError *error) {
        
        button.enabled = YES;
        [self finishSendingMessageAnimated:NO];
    }];
}

#pragma mark Nav bar

- (void)pressGroupInfo:(id)sender {
    
}


@end
