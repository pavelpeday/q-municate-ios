//
//  QMGlobalCallStatusBar.m
//  Q-municate
//
//  Created by Pavel Peday on 17.03.16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGlobalCallStatusBar.h"
#import "QMScreenShareManager.h"

@interface QMGlobalCallStatusBar()

@property (nonatomic, strong, readonly) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval timeInterval;

@end

const CGFloat kTimerInterval = 1.f;

@implementation QMGlobalCallStatusBar

+ (QMGlobalCallStatusBar *)loadStatusBar {
	NSArray *nibViews = [[NSBundle bundleForClass:[QMGlobalCallStatusBar class]] loadNibNamed:NSStringFromClass([QMGlobalCallStatusBar class])
																	   owner:nil
																	 options:nil];

	return nibViews.firstObject;
}

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	id hitView = [super hitTest:point withEvent:event];

	if (hitView == self) {
		return nil;
	} else {
		return hitView;
	}
}

- (void)awakeFromNib {
	[super awakeFromNib];

	self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
	[self startTimer];
	self.declineBtn.userInteractionEnabled = YES;
}

- (CGFloat)currentCallDuration {
	return self.timeInterval;
}

- (IBAction)declineTapped:(id)sender {
	[[QMScreenShareManager sharedManager] hungupWithCompletion:^{}];
	[self removeFromSuperview];
}

- (void)startTimerIfNeeded {
	if( [_timer isValid] ){
		return;
	}
	_timeInterval = 0.0f;
	self.statusLabel.text = [self stringWithTimeDuration:self.timeInterval];
	_timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(updateStatusLabel) userInfo:nil repeats:YES];
	[_timer fire];
}

- (void)startTimer {
	// stop if running
	[self stopTimer];
	[self startTimerIfNeeded];
}

- (void)stopTimer {
	[_timer invalidate];
	_timer = nil;
	_timeInterval = 0.0f;
}

- (void)updateStatusLabel {
	self.timeInterval += kTimerInterval;
	self.statusLabel.text = [self stringWithTimeDuration:self.timeInterval];
}

- (void)updateCallDuration:(CGFloat)duration {
	self.timeInterval = duration;
	self.statusLabel.text = [self stringWithTimeDuration:self.timeInterval];
}

- (NSString *)stringWithTimeDuration:(NSTimeInterval )timeDuration {

	NSInteger minutes = timeDuration / 60;
	NSInteger seconds = (NSInteger)timeDuration % 60;

	NSString *timeStr = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];

	return timeStr;
}

@end
