//
//  QMSettingsViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 06/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSettingsViewController.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"
#import "SDWebImageManager.h"
#import "QMServicesManager.h"
#import "QMImageView.h"
#import "QMPlaceholder.h"

@interface QMSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *changePasswordCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *profileCell;
@property (weak, nonatomic) IBOutlet UISwitch *pushNotificationSwitch;
@property (weak, nonatomic) IBOutlet UILabel *cacheSize;
@property (weak, nonatomic) IBOutlet QMImageView *avatarImageView;

@end

@implementation QMSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pushNotificationSwitch.on = QM.profile.pushNotificationsEnabled;
//    
//    if (QM.profile.type == QMProfileTypeFacebook) {
//        
//        [self cell:self.changePasswordCell setHidden:YES];
//    }
    
    self.fullNameLabel.text = QM.profile.userData.fullName;
    
    UIImage *placeholder = [QMPlaceholder placeholderWithFrame:self.avatarImageView.bounds fullName:QM.profile.userData.fullName];
    self.avatarImageView.imageViewType = QMImageViewTypeCircle;
    
    [self.avatarImageView setImageWithURL:QM.profile.userData.avatarUrl
                              placeholder:placeholder
                                  options:SDWebImageLowPriority
                                 progress:nil
                           completedBlock:nil];
    
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:kSettingsCellBundleVersion];
    self.versionLabel.text =  [@"Powered by QuickBlox. v." stringByAppendingString:appVersion];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak __typeof(self)weakSelf = self;
    [[[SDWebImageManager sharedManager] imageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        
        weakSelf.cacheSize.text = [NSString stringWithFormat:@"Cache size: %.2f mb", (float)totalSize / 1024.f / 1024.f];
    }];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger count = [tableView numberOfRowsInSection:indexPath.section];
    
    UITableViewCell *nextCell = nil;
    
    if (indexPath.row + 1 < count) {
        
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
        nextCell = [super tableView:tableView cellForRowAtIndexPath:nextIndexPath];
    }
    
    if ([cell.reuseIdentifier isEqualToString:@"Separator"] || [nextCell.reuseIdentifier isEqualToString:@"Separator"]) {
        cell.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.tableView.bounds), 0, 0);
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.logoutCell) {
        
        __weak __typeof(self)weakSelf = self;
        [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
            
            alertView.message = NSLocalizedString(@"QM_STR_ARE_YOU_SURE", nil);
            [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_LOGOUT", nil) andActionBlock:^{
                
                [weakSelf pressClearCache:nil];
                [SVProgressHUD  showWithMaskType:SVProgressHUDMaskTypeClear];
                
                [QM.authService logOut:^(QBResponse *response) {
                    
                    [SVProgressHUD dismiss];
                    [weakSelf performSegueWithIdentifier:kSplashSegueIdentifier sender:nil];
                }];
            }];
            
            [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) andActionBlock:^{}];
        }];
    }
}

#pragma mark - Actions

- (IBAction)changePushNotificationValue:(UISwitch *)sender {
    
    //    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    //    if (sender.on) {
    //        [[QMApi instance] subscribeToPushNotificationsForceSettings:YES complete:^(BOOL success) {
    //            [SVProgressHUD dismiss];
    //        }];
    //    }
    //    else {
    //        [[QMApi instance] unSubscribeToPushNotifications:^(BOOL success) {
    //            [SVProgressHUD dismiss];
    //        }];
    //    }
    
}

- (IBAction)pressClearCache:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
    [[[SDWebImageManager sharedManager] imageCache] clearDiskOnCompletion:^{
        
        [[[SDWebImageManager sharedManager] imageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
            weakSelf.cacheSize.text = [NSString stringWithFormat:@"Cache size: %.2f mb", (float)totalSize / 1024.f / 1024.f];
        }];
    }];
}

@end