//
//  OGGenerator.m
//  OpenGraph
//
//  Created by Andrey Ivanov on 10/03/16.
//  Copyright © 2016 Andrey Ivanov. All rights reserved.
//

#import "OGGenerator.h"
#import "HTMLDocument.h"
#import "OGModel.h"

@interface OGGenerator()

@property (nonatomic, strong) NSMutableDictionary *modelsCache;

@end

@implementation OGGenerator

+ (OGGenerator *)sharedInstance {
	static OGGenerator *sharedInstance;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		sharedInstance = [OGGenerator new];
		sharedInstance.modelsCache = [NSMutableDictionary new];
	});
	return sharedInstance;
}



- (void)generateModelFromURL:(NSURL *)url withCompletion:(void (^)(OGModel *))completion{

	OGModel *cached = [self cachedModelForURL:url];
	if (cached) {
		if (completion) {
			completion(cached);
		}
	} else {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			NSError *error = nil;

			HTMLDocument *doc = [HTMLDocument documentWithContentsOfURL:url
																  error:&error];
			HTMLNode *head = [doc head];
			OGModel *model = [[OGModel alloc] initWithHeadNode:head
													 sourceURL:url];

			[self.modelsCache setObject:model forKey:url.absoluteString];

			dispatch_async(dispatch_get_main_queue(), ^{
				if (completion) {
					completion(model);
				}
			});
		});
	}
}

- (OGModel *)cachedModelForURL:(NSURL *)url {
	NSString *key = url.absoluteString;
	return self.modelsCache[key];
}

@end
