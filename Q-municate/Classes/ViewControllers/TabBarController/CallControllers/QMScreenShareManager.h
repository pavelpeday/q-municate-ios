//
//  QMScreenShareManager.h
//  Q-municate
//
//  Created by Pavel Peday on 17.03.16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMApi.h"
#import "QMGlobalCallStatusBar.h"

@interface QMScreenShareManager : NSObject <QBRTCClientDelegate>

@property (weak, nonatomic) QBRTCSession *session;

@property (nonatomic, readonly) QBUUser *opponent;
@property (nonatomic, readonly) QMGlobalCallStatusBar *globalStatusBar;

/**
 * Singleton accessor
 */
+ (QMScreenShareManager *)sharedManager;

/**
 * YES if screen sharing is in progress, otherwise NO
 */
- (BOOL)isSharing;

/**
 * Starts screen sharing session. OpponentID should be set before calling this method.
 * @param shareView view to share
 * @param session active RTC session for current call
 * @param callDuration current call duration
 * @param opponent call opponent
 */
- (void)shareView:(UIView *)sharingView
	  withSession:(QBRTCSession *)session
	 callDuration:(CGFloat)callDurationTillNow
		 opponent:(QBUUser *)opponent;

/**
 *	Update view, which is being shared
 */
- (void)updateSharingView:(UIView *)sharingView;

/**
 * End call
 */
- (void)hungupWithCompletion:(void(^)())completion;

/**
 *	Stop screen sharing
 */
- (void)stopSharing;

@end
