//
//  QMScreenShareManager.m
//  Q-municate
//
//  Created by Pavel Peday on 17.03.16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMScreenShareManager.h"
#import "QBRTCScreenCapture.h"
#import "QMApi.h"
#import "QMSoundManager.h"

@interface QMScreenShareManager()

@property (nonatomic, strong) UIView *sharingView;
@property (nonatomic, strong) QBRTCScreenCapture *screenCapture;
@property (nonatomic, strong) QMGlobalCallStatusBar *statusBar;
@property (nonatomic, weak) QBRTCVideoCapture *capture;
@property (nonatomic, weak) QBUUser *opponentUser;

@end

NSInteger const kNavigationBarHeight = 64;
NSInteger const kCallStatusBarHeight = 50;

@implementation QMScreenShareManager

+ (QMScreenShareManager *)sharedManager {
	static QMScreenShareManager *sharedManager;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		sharedManager = [QMScreenShareManager new];
		[[QBRTCClient instance] addDelegate:sharedManager];
	});
	return sharedManager;
}

- (BOOL)isSharing {
	return self.screenCapture != nil;
}

- (QBUUser *)opponent {
	return self.opponentUser;
}

- (QMGlobalCallStatusBar *)globalStatusBar {
	return _statusBar;
}

- (void)shareView:(UIView *)sharingView withSession:(QBRTCSession *)session callDuration:(CGFloat)callDurationTillNow opponent:(QBUUser *)opponent {

	self.session = session;
	self.opponentUser = opponent;

	self.capture = self.session.localMediaStream.videoTrack.videoCapture;
	self.screenCapture = [[QBRTCScreenCapture alloc] initWithView:self.sharingView];
	//Switch to sharing
	self.session.localMediaStream.videoTrack.videoCapture = self.screenCapture;

	//Global status bar
	self.statusBar = [QMGlobalCallStatusBar loadStatusBar];
	UIWindow *top = [[UIApplication sharedApplication] keyWindow];

	self.statusBar.frame = CGRectMake(0, kNavigationBarHeight, top.frame.size.width, kCallStatusBarHeight);
	[self.statusBar updateCallDuration:callDurationTillNow];
	self.statusBar.opponentNameLabel.text = self.opponent.fullName;

	[top addSubview:self.statusBar];
}

- (void)updateSharingView:(UIView *)sharingView {
	self.sharingView = sharingView;

	if (self.isSharing) {
		[self.screenCapture updateSharingView:sharingView];
	}
}

- (void)cleanup {
	[self.statusBar removeFromSuperview];
	self.session.localMediaStream.videoTrack.videoCapture = self.capture;
	self.statusBar = nil;
	self.screenCapture = nil;
	self.sharingView = nil;
	self.opponentUser = nil;
}

- (void)hungupWithCompletion:(void (^)())completion {
	[[QMApi instance] finishCall];

	// stop playing sound:
	[[QMSoundManager instance] stopAllSounds];


	// need a delay to give a time to a WebRTC to unload resources
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * 300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
		[QMSoundManager playEndOfCallSound];

		dispatch_async(dispatch_get_main_queue(), ^{
			[self cleanup];
			
			if (completion) {
				completion();
			}
		});
	});
}

- (void)stopSharing {
	[self cleanup];
}

#pragma mark QBRTCSession delegate -

- (void)sessionDidClose:(QBRTCSession *)session {
	[self cleanup];
}


@end
