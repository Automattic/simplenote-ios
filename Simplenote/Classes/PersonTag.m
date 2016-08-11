//
//  PersonTag.m
//  Simplenote
//
//  Created by Michael Johnston on 11-08-23.
//  Copyright (c) 2011 Codality. All rights reserved.
//

#import "PersonTag.h"

@implementation PersonTag
@synthesize name;
@synthesize email;

-(id)initWithName:(NSString *)aName email:(NSString *)anEmail {
    
    if ((self = [super init])) {
        self.name = aName;
        self.email = anEmail;
    }
    return self;
    
}

- (NSComparisonResult)compareName:(PersonTag *)anotherTag
{
	NSString *str1, *str2;
	
	str1 = self.name.length == 0 ? email : self.name;
	str2 = anotherTag.name.length == 0 ? anotherTag.email : anotherTag.name;
	return [str1 localizedCaseInsensitiveCompare:str2];
}

- (NSComparisonResult)compareEmail:(PersonTag *)anotherTag {
    
	return [self.email localizedCaseInsensitiveCompare:anotherTag.email];
}

@end
