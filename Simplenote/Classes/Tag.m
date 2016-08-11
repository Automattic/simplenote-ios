//
//  Tag.m
//  Simplenote
//
//  Created by Michael Johnston on 10-04-19.
//  Copyright 2010 Simperium. All rights reserved.
//

#import "Tag.h"
//#import "NSArray+Utilities.h"
#import "JSONKit+Simplenote.h"

@interface Tag()
- (void)updateRecipients;
@end

@implementation Tag
@synthesize count;
@dynamic index;
@dynamic share;
@dynamic name;

- (void)awakeFromFetch {
    [super awakeFromFetch];
    [self updateRecipients];
}

- (id)initWithText:(NSString *)str {
	if ((self = [super init])) {
		self.name = str;
		self.recipients = [NSMutableArray arrayWithCapacity:2];
		self.index = [NSNumber numberWithInt:-1];
	}
	return self;
}


- (id)initWithText:(NSString *)str recipients:(NSArray *)emailList {
	if ((self = [super init])) {
		self.name = str;
        NSMutableArray *newEmailList = [emailList mutableCopy];
		self.recipients = newEmailList;
		self.index = [NSNumber numberWithInt:-1];
	}
	return self;
}

- (void)updateRecipients {
    if (share.length > 0)
        self.recipients = [share objectFromJSONString];
    else
        self.recipients = [NSMutableArray arrayWithCapacity: 3];
}

- (void)setRecipients:(NSMutableArray *)newRecipients {
    // Update share instead; recipients will get updated in setShare: below via updateRecipients
        self.share = [newRecipients count] > 0 ? [newRecipients JSONString] : @"[]";
}

- (NSMutableArray *)recipients {
	return recipients;
}

- (NSComparisonResult)compareIndex:(Tag *)tag {
	int i1 = [[self index] intValue];
	int i2 = [[tag index] intValue];
	if (i1 >= 0 && i2 >= 0) {
		return [[self index] compare:[tag index]];
	} else {
		return NSOrderedSame;
	}	
}

-(NSString *)textWithPrefix {
	return [@"#" stringByAppendingString: name];
}


-(void)addRecipient:(NSString *)emailAddress {
    NSString *newEmailAddress = [emailAddress copy];
	[recipients addObject: newEmailAddress];
    self.share = [recipients JSONString];
}

-(NSDictionary *)tagDictionary {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:self.name forKey:@"name"];
	if (self.recipients && [self.recipients count] > 0)
		[dict setObject:self.recipients forKey:@"share"];
	[dict setObject:index forKey:@"index"];

	return dict;
}

@end
