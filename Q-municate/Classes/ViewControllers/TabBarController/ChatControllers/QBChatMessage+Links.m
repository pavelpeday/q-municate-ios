//
//  QBChatMessage+Links.m
//  Q-municate
//
//  Created by Pavel Peday on 16.03.16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QBChatMessage+Links.h"

@implementation QBChatMessage (Links)

- (BOOL)hasWebLinks {
	return [self webLinks].count > 0;
}

- (NSArray *)webLinks {
	NSDataDetector* detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
	return [detector matchesInString:self.text options:0 range:NSMakeRange(0, [self.text length])];
}

@end
