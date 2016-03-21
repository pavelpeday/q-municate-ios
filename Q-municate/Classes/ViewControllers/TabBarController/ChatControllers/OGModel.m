//
//  OGModel.m
//  OpenGraph
//
//  Created by Andrey Ivanov on 10/03/16.
//  Copyright © 2016 Andrey Ivanov. All rights reserved.
//

#import "OGModel.h"
#import "HTMLDocument.h"

@interface OGModel()

@property (strong, nonatomic) NSDictionary *title;

@end

@implementation OGModel

@synthesize originalUrl, ogTitle, url, image, ogDescription, siteName;

- (instancetype)initWithHeadNode:(HTMLNode *)head sourceURL:(NSURL *)sourceURL {
    
    self = [super init];
    if (self) {

		_favIcon = [NSString stringWithFormat:@"%@://%@/favicon.ico", [sourceURL scheme], [sourceURL host]];
		originalUrl = sourceURL;

		NSArray *meta = [head childrenOfTag:@"meta"];
		for (HTMLNode *node in meta) {

			[node.attributes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull attribute, BOOL * _Nonnull stop) {
				//NSLog(@"%@", [node attributes]);
				BOOL property = [key isEqualToString:@"property"];

				if (property && [attribute isEqualToString:@"og:title"]) {

					ogTitle = [node attributeForName:@"content"];
					*stop = YES;
				}

				if ([key isEqualToString:@"property"] && [attribute isEqualToString:@"og:description"]) {
					ogDescription = [node attributeForName:@"content"];
					*stop = YES;
				}

				if ([key isEqualToString:@"property"] && [attribute isEqualToString:@"og:url"]) {

					url = [node attributeForName:@"content"];
					*stop = YES;
				}

				if ([key isEqualToString:@"property"] && [attribute isEqualToString:@"og:site_name"]) {

					siteName = [node attributeForName:@"content"];
					*stop = YES;
				}

				if ([key isEqualToString:@"property"] && [attribute isEqualToString:@"og:image"]) {

					image = [node attributeForName:@"content"];
					*stop = YES;
				}
			}];
		}
	}

    return self;
}

//#pragma mark - Public Getters
//
//- (NSString *)ogDescription {
//
//    return nil;
//}
//
//- (NSString *)ogTitle {
//
//    return nil;
//}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {

}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {

    return nil;
}

@end
