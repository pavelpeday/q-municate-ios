//
//  OGGenerator.h
//  OpenGraph
//
//  Created by Andrey Ivanov on 10/03/16.
//  Copyright © 2016 Andrey Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGModel.h"

@class OGModel;

@interface OGGenerator : NSObject

+ (OGGenerator *)sharedInstance;

/**
 *  Generate Open graph model 
 *  @see http://ogp.me
 *
 *	@param urlString OGModel will be generaten for this URL
 *  @param model OGModel instance
 */

- (void)generateModelFromURL:(NSURL *)url withCompletion:(void (^)(OGModel *model))completion;

@end
