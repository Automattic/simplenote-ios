//
//  SPTagStub.m
//  Simplenote
//
//  Copyright 2011 Simperium, Inc. All rights reserved.
//

#import "SPTagStub.h"
#import "NSString+Metadata.h"

@implementation SPTagStub


#pragma mark - Constructor

- (id)initWithTag:(NSString *)aTag {
    self = [super init];
    if (self) {
        self.tag = aTag;
        self.displayText = nil;
        self.isEmailTag = [aTag containsEmailAddress];
    }
    return self;
}

- (id)initWithTag:(NSString *)aTag displayText:(NSString *)aDisplayText {
    self = [super init];
    if (self) {
        self.tag = aTag;
        self.displayText = aDisplayText;
        self.isEmailTag = [aTag containsEmailAddress];
    }
    return self;
}


#pragma mark - Properties

@synthesize displayText;
@synthesize isEmailTag;
@synthesize tag;


#pragma mark - Methods

- (NSComparisonResult)compare:(SPTagStub *)aTag {
    if ([self hasDisplayText] && ![aTag hasDisplayText]) {
        return NSOrderedDescending;
    } else if (![self hasDisplayText] && [aTag hasDisplayText]) {
        return NSOrderedAscending;
    } else {
        // We'll try and sort email address based on their last name.
        NSArray *nameArray1 = [self.displayText componentsSeparatedByString:@" "];
        NSString *name1 = nameArray1.count > 1 ? [nameArray1 objectAtIndex:1] : [nameArray1 objectAtIndex:0];
        
        NSArray *nameArray2 = [aTag.displayText componentsSeparatedByString:@" "];
        NSString *name2 = nameArray2.count > 1 ? [nameArray2 objectAtIndex:1] : [nameArray2 objectAtIndex:0];
        
        return [name1 compare:name2];
    }
}

- (NSString *)description {
    return tag;
}

- (BOOL)hasDisplayText {
    return displayText.length != 0;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SPTagStub class]]) {
        SPTagStub *tag2 = (SPTagStub *)object;
        
        NSString *string1 = [self.tag lowercaseString];
        NSString *string2 = [tag2.tag lowercaseString];
        
        return [string1 isEqualToString:string2];
    }
    
    return NO;    
}

@end