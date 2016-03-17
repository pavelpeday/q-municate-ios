//
//  QMShareableTableViewController.m
//  Q-municate
//
//  Created by Pavel Peday on 17.03.16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMShareableTableViewController.h"
#import "QMScreenShareManager.h"

@interface QMShareableTableViewController ()

@end

@implementation QMShareableTableViewController

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([QMScreenShareManager sharedManager].isSharing) {
		[[QMScreenShareManager sharedManager] updateSharingView:self.view];
	}
}

@end
