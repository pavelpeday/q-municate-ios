//
//  QMAddContactCell.m
//  Q-municate
//
//  Created by Andrey Ivanov on 23.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMAddContactCell.h"
#import "QMImageView.h"

@interface QMAddContactCell()

@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (assign, nonatomic) BOOL userExist;

@end

@implementation QMAddContactCell

#pragma mark - Override

+ (NSString *)cellIdentifier {
    
    static NSString *cellIdentifier = @"QMAddContactCell";
    return cellIdentifier;
}

#pragma mark - Actions

- (IBAction)pressAddBtn:(id)sender {
    
    [self.delegate didAddContact:self.contact];
}

- (void)setUserExist:(BOOL)userExist {

    if (_userExist != userExist) {
        _userExist = userExist;
        self.addBtn.hidden = userExist;
    }
}

@end
