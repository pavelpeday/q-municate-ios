//
//  QMInviteFriendsTableViewController.m
//  Q-municate
//
//  Created by Anton Sokolchenko on 5/14/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMInviteFriendsTableViewController.h"
#import "QMFacebook.h"


const NSInteger kAddressBookCellTag = 100;
const NSInteger kFacebookCellTag = 200;

@implementation QMInviteFriendsTableViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([tableView cellForRowAtIndexPath:indexPath].tag == kFacebookCellTag) {
	
		QMFacebook *fb = [[QMFacebook alloc] init];
		[fb inviteFriendsWithCompletion:^(BOOL success) {
			
		}];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
}

@end
