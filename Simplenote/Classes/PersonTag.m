//
//  PersonTag.m
//  Simplenote
//
//  Created by Michael Johnston on 11-08-23.
//  Copyright (c) 2011 Codality. All rights reserved.
//

#import "PersonTag.h"

@implementation PersonTag

- (instancetype)initWithName:(NSString *)aName email:(NSString *)anEmail
{
    if ((self = [super init])) {
        self.name = aName;
        self.email = anEmail;
        self.active = YES;
    }

    return self;
}

- (NSUInteger)hash
{
    return self.name.hash + self.email.hash;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[PersonTag class]] == false) {
        return false;
    }

    PersonTag *second = (PersonTag *)object;
    return [self.name isEqual:second.name] && [self.email isEqual:second.email];
}

- (NSComparisonResult)compareName:(PersonTag *)anotherTag
{
	NSString *str1 = _name.length == 0 ? _email : _name;
	NSString *str2 = anotherTag.name.length == 0 ? anotherTag.email : anotherTag.name;

	return [str1 localizedCaseInsensitiveCompare:str2];
}

- (NSComparisonResult)compareEmail:(PersonTag *)anotherTag
{
	return [self.email localizedCaseInsensitiveCompare:anotherTag.email];
}

@end
