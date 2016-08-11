//
//  SPAddressBookManager.m
//  Simplenote
//
//  Created by Tom Witkin on 7/27/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPAddressBookManager.h"
#import <AddressBook/AddressBook.h>
#import "PersonTag.h"
#import "SPTagStub.h"

@interface SPAddressBookManager ()
@end

@implementation SPAddressBookManager

+ (SPAddressBookManager *)sharedManager
{
    static SPAddressBookManager *sharedManager = nil;
    if (!sharedManager) {
        sharedManager = [[SPAddressBookManager alloc] init];
        
        if (sharedManager.authorizationStatus == kABAuthorizationStatusAuthorized) {
            [sharedManager readContactsFromAddressBook];
        }
    }
    
    return sharedManager;
}

- (void)requestAddressBookPermissions:(void (^)(BOOL))completion {
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        
        if (granted)
            [self readContactsFromAddressBook];
        
        if (completion)
            completion(granted);
        
    });
}


void AddressBookWasChanged(ABAddressBookRef addBook, CFDictionaryRef info, void *context) {

//    SPAddressBookManager *manager = (__bridge SPAddressBookManager *)context;
//    ABAddressBookRevert(manager.addressBookRef);
//    
//    [manager readContactsFromAddressBook];
}

- (ABAuthorizationStatus)authorizationStatus {
    
    return ABAddressBookGetAuthorizationStatus();
}

- (void)readContactsFromAddressBook {
    
    if (self.authorizationStatus == kABAuthorizationStatusAuthorized)
        [self loadPeople];
    
}


-(void)loadPeople
{
	addressBook = ABAddressBookCreateWithOptions(NULL, nil);
	self.people = [NSMutableArray arrayWithCapacity:3];
	NSArray *allPeople = (__bridge_transfer NSArray *) ABAddressBookCopyArrayOfAllPeople(addressBook);
	for (int i = 0; i < [allPeople count]; i++) {
		ABRecordRef person = (__bridge  ABRecordRef)([allPeople objectAtIndex:i]);
        ABRecordRef personCopy = ABRecordCopyValue(person, kABPersonEmailProperty);
		NSArray* emailAddresses = (__bridge_transfer NSArray*)ABMultiValueCopyArrayOfAllValues(personCopy);
        if (personCopy) CFRelease(personCopy);
		
		for (NSString *address in emailAddresses) {
			NSString *personName =(__bridge_transfer NSString *)ABRecordCopyCompositeName(person);
			if (personName.length == 0 && address.length == 0) {
				continue;
            }
			PersonTag *personTag = [[PersonTag alloc] initWithName:personName email: address];
			[_people addObject:personTag];

		}
	}
    
	[_people sortUsingSelector:@selector(compareName:)];
    
}

-(PersonTag *)personTagAtIndex:(int)index
{
	if ([_people count] == 0)
		[self loadPeople];
	
	PersonTag *personTag = (PersonTag *)[_people objectAtIndex: index];
	return personTag;
}


#pragma mark matches

- (NSArray *)matchingPeopleForString:(NSString *)input filterOutPeople:(NSArray *)filter {
    
    if (input == nil || self.authorizationStatus != kABAuthorizationStatusAuthorized) {
        return nil;
    }
    
    // check both emails and people names
    
    NSString *lowercaseInput = [input lowercaseString];
    NSMutableArray *temp = [NSMutableArray array];
    
    for (PersonTag *t in _people) {
        NSRange range = [[t.name lowercaseString] rangeOfString:lowercaseInput];
        if (range.location == 0) {
            [temp addObject:t];
        }
        
        range = [[t.email lowercaseString] rangeOfString:lowercaseInput];
        if (range.location == 0)
            [temp addObject:t];
        
    }
    
    // filter out people
    NSMutableArray *peopleToRemove;
    for (PersonTag *filterTag in filter) {
        
        for (PersonTag *tag in temp) {
            
            if ([filterTag compareEmail:tag] == NSOrderedSame) {
                
                if (!peopleToRemove)
                    peopleToRemove = [NSMutableArray arrayWithCapacity:1];
                
                [peopleToRemove addObject:tag];
                break;
            }
        }
    }
    
    [temp removeObjectsInArray:peopleToRemove];

    [temp sortUsingSelector:@selector(compareName:)];
    return temp;
}


@end
