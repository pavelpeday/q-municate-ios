//
//  QMFriendsDetailsController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 28/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendsDetailsController.h"
#import "QMVideoCallController.h"
#import "QMChatVC.h"
#import "QMUsersUtils.h"
#import "QMImageView.h"
#import "QMAlertsFactory.h"
#import "REAlertView.h"
#import "SVProgressHUD.h"
#import "QMApi.h"
#import "REAlertView+QMSuccess.h"
#import "QMVideoP2PController.h"
#import "QMScreenShareManager.h"

typedef NS_ENUM(NSUInteger, QMCallType) {
    QMCallTypePhone,
    QMCallTypeVideo,
    QMCallTypeAudio,
    QMCallTypeChat
};

@interface QMFriendsDetailsController ()
<
UIActionSheetDelegate,
QMContactListServiceDelegate
>

@property (weak, nonatomic) IBOutlet UITableViewCell *phoneCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *videoChatCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *audioChatCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *chatCell;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteContactButton;
@property (weak, nonatomic) IBOutlet QMImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UILabel *userDetails;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIImageView *onlineCircle;

@end

@implementation QMFriendsDetailsController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.selectedUser.phone.length == 0) {
        [self.phoneLabel setText:NSLocalizedString(@"QM_STR_NONE", nil)];
    } else {
        self.phoneLabel.text = self.selectedUser.phone;
    }
    
    self.fullName.text = self.selectedUser.fullName;
    self.userDetails.text = self.selectedUser.status;
    self.userAvatar.imageViewType = QMImageViewTypeCircle;
    
    NSURL *url = [QMUsersUtils userAvatarURL:self.selectedUser];
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    [self.userAvatar setImageWithURL:url
                         placeholder:placeholder
                             options:SDWebImageHighPriority
                            progress:
     ^(NSInteger receivedSize, NSInteger expectedSize) {
         
     }
     
                      completedBlock:
     ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
         
     }];
    
    [self updateUserStatus];
    
    [self disableDeleteContactButtonIfNeeded];
    
#if !QM_AUDIO_VIDEO_ENABLED
    
    UITableViewCell *videoChatCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITableViewCell *audioChatCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [self cells:@[videoChatCell, audioChatCell] setHidden:YES];
    
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[QMApi instance].contactListService addDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([QMScreenShareManager sharedManager].isSharing) {
		[[QMScreenShareManager sharedManager] updateSharingView:self.view];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[QMApi instance].contactListService removeDelegate:self];
}

- (void)updateUserStatus {
    
    QBContactListItem *item = [[QMApi instance] contactItemWithUserID:self.selectedUser.ID];
    
    if (item) { //friend if YES
        self.status.text = NSLocalizedString(item.online ? @"QM_STR_ONLINE": @"QM_STR_OFFLINE", nil);
        self.onlineCircle.hidden = !item.online;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kChatViewSegueIdentifier]) {
        
        QMChatVC *chatController = segue.destinationViewController;
        chatController.dialog = sender;
        
        NSAssert([sender isKindOfClass:QBChatDialog.class], @"Need update this case");
    }
}

- (BOOL)isCallAllowed {
    
    if (![QMApi instance].isInternetConnected) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return NO;
    }
    
    if( ![[QMApi instance] isFriend:self.selectedUser] || [[QMApi instance] userIDIsInPendingList:self.selectedUser.ID] ) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_MAKE_CALLS", nil) actionSuccess:NO];
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case QMCallTypePhone: break;
            
#if QM_AUDIO_VIDEO_ENABLED
        case QMCallTypeVideo:{
            
            if ([self isCallAllowed]) {
				NSUInteger opponentID = self.selectedUser.ID;

				if ([QMScreenShareManager sharedManager].isSharing) {
					if ([QMScreenShareManager sharedManager].opponent.ID == opponentID) {
						//Same opponent, restore screen

						UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
						QMVideoP2PController *callVC = (QMVideoP2PController *)[storyboard instantiateViewControllerWithIdentifier:@"DuringVideoCallIdentifier"];
						callVC.opponent = [QMScreenShareManager sharedManager].opponent;
						callVC.wasRestoredAfterScreenSharing = YES;

						callVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
						[self presentViewController:callVC animated:YES completion:^{
							[callVC.contentView updateCallDuration:[[QMScreenShareManager sharedManager].globalStatusBar currentCallDuration]];
							[[QMScreenShareManager sharedManager] stopSharing];
							[[QBRTCSoundRouter instance] setCurrentSoundRoute:QBRTCSoundRouteSpeaker];
						}];
					} else {
						// Different opponent, drop current call and proceed
						[[QMScreenShareManager sharedManager] hungupWithCompletion:^{
							[[QMApi instance] callToUser:@(opponentID) conferenceType:QBRTCConferenceTypeVideo];
						}];
					}
				} else {
					[[QMApi instance] callToUser:@(opponentID) conferenceType:QBRTCConferenceTypeVideo];
				}
            }
        }
            break;
        case QMCallTypeAudio: {
            if([self isCallAllowed]) {
				NSUInteger opponentID = self.selectedUser.ID;

				//If video sharing is in progress, drop it.
				if ([QMScreenShareManager sharedManager].isSharing) {
					[[QMScreenShareManager sharedManager] hungupWithCompletion:^{
						[[QMApi instance] callToUser:@(opponentID) conferenceType:QBRTCConferenceTypeAudio];
					}];
				} else {
					[[QMApi instance] callToUser:@(opponentID) conferenceType:QBRTCConferenceTypeAudio];
				}
            }
        }
            break;
        case QMCallTypeChat: {
#else
        case QMCallTypeVideo: {
#endif
            __weak __typeof(self)weakSelf = self;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            
            [[[QMApi instance].chatService createPrivateChatDialogWithOpponent:self.selectedUser] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
                //
                if (task.error != nil) {
                    [SVProgressHUD showErrorWithStatus:task.error.localizedRecoverySuggestion];
                } else {
                    [weakSelf performSegueWithIdentifier:kChatViewSegueIdentifier sender:task.result];
                    [SVProgressHUD dismiss];
                }
                
                return nil;
            }];
            
        } break;
            
        default:break;
    }
}

#pragma mark - Actions

- (IBAction)removeFromFriends:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
        
        alertView.message = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_CONFIRM_DELETE_CONTACT", @"{User Full Name}"), self.selectedUser.fullName];
        [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) andActionBlock:^{}];
        [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_DELETE", nil) andActionBlock:^{
            
            [[QMApi instance] removeUserFromContactList:weakSelf.selectedUser completion:^(BOOL success, QBChatMessage *notification) {}];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }];
}
    

- (void)disableDeleteContactButtonIfNeeded
{
    BOOL isContact = [[QMApi instance] isFriend:self.selectedUser];
    self.deleteContactButton.enabled = isContact;
}
    
#pragma mark Contact List Serice Delegate
    
- (void)contactListService:(QMContactListService *)contactListService didReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status {
    [self updateUserStatus];
}
    
- (void)contactListService:(QMContactListService *)contactListService contactListDidChange:(QBContactList *)contactList {
    [self updateUserStatus];
}
    
- (void)contactListService:(QMContactListService *)contactListService didUpdateUser:(QBUUser *)user {
    [self updateUserStatus];
}

@end
