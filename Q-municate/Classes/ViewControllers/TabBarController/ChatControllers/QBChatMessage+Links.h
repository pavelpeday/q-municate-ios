//
//  QBChatMessage+Links.h
//  Q-municate
//
//  Created by Pavel Peday on 16.03.16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Quickblox/Quickblox.h>

@interface QBChatMessage (Links)

- (BOOL)hasWebLinks;
- (NSArray *)webLinks;

@end
