//
//  QMShareableViewController.m
//  Q-municate
//
//  Created by Pavel Peday on 17.03.16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMShareableViewController.h"
#import "QMScreenShareManager.h"

@interface QMShareableViewController ()

@end

@implementation QMShareableViewController

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([QMScreenShareManager sharedManager].isSharing) {
		[[QMScreenShareManager sharedManager] updateSharingView:self.view];
	}
}

@end
