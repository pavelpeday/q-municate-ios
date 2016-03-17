//
//  QMGlobalCallStatusBar.h
//  Q-municate
//
//  Created by Pavel Peday on 17.03.16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *	This bar will be displayed on top of all windows if screen sharing is in progress.
 */
@interface QMGlobalCallStatusBar : UIView

@property (weak, nonatomic) IBOutlet UILabel *opponentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *declineBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

/**
 * Creation method
 * @return QMGlobalCallStatusBar instance
 */
+ (QMGlobalCallStatusBar *)loadStatusBar;

- (IBAction)declineTapped:(id)sender;
- (IBAction)backTapped:(id)sender;

/**
 * Updates current call duration label data (screen sharing is available only on button click, so when it starts call is active for some time already)
 * @param  duration current call duration
 */
- (void)updateCallDuration:(CGFloat)duration;

- (CGFloat)currentCallDuration;

@end
