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
#import "UIColor+QM.h"
#import "QMServicesManager.h"

@interface QMChatVC ()

@property (strong, nonatomic) NSMutableArray *array;
@property (strong, nonatomic) QMBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) QMBubbleImage *incomingBubbleImageData;

@end

@implementation QMChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //Cofigure sender
    QBUUser *sender = QM.profile.userData;
    self.senderId = sender.ID;
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
        
        [self.array addObjectsFromArray:messages];
        [self.collectionView reloadData];
        
    }];
    
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
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
    
    cell.textView.textColor = msg.senderID == self.senderId ?  [UIColor blackColor] : [UIColor whiteColor];
    
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
    if (message.senderID == self.senderId) {
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
    return [[NSAttributedString alloc] initWithString:message.senderNick];
}

- (id<QMChatMessageData>)collectionView:(QMChatViewController *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.array[indexPath.row];
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.array count];
}

- (id<QMChatBubbleImageDataSource>)collectionView:(QMChatCollectionView *)collectionView
         messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    QBChatMessage *msg = self.array[indexPath.item];
    
    if (msg.senderID == 1) {
        
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<QMChatAvatarImageDataSource>)collectionView:(QMChatCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}

- (CGFloat)collectionView:(QMChatCollectionView *)collectionView
                   layout:(QMChatCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  iOS7-style sender name labels
     */
    QBChatMessage *msg = self.array[indexPath.row];
    
    if (msg.senderID == self.senderId ) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        
        QBChatMessage *previousMessage = [self.array objectAtIndex:indexPath.item - 1];
        if (previousMessage.senderID == msg.senderID) {
            
            return 0.0f;
        }
    }
    
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
    
    if (msg.senderID == self.senderId ) {
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

- (void)createNitificationForUser:(NSNotification *)notification {
    
}

@end
