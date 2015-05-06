    //
//  QMNewMessageVC.m
//  Q-municate
//
//  Created by Andrey Ivanov on 03.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMCreateMessageVC.h"
#import "QMContactListDataSource.h"
#import "QMServicesManager.h"
#import "QMChatVC.h"

@implementation QMCreateMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchController.searchBar.tintColor = [UIColor colorWithRed:0.067 green:0.357 blue:0.643 alpha:1.000];
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QBUUser *user = [self.contactListDatasource userAtIndexPath:indexPath];
    QBChatDialog *dialog = [QM.chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:user.ID];
    
    [self performSegueWithIdentifier:@"ChatViewController" sender:dialog];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString: @"ChatViewController"]) {
        
        QMChatVC *chatVC = segue.destinationViewController;
        chatVC.chatDialog = sender;
    }
}

@end
