//
//  SPAddressBookManager.h
//  Simplenote
//
//  Created by Tom Witkin on 7/27/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface SPAddressBookManager : NSObject {
    ABAddressBookRef addressBook;
}

@property (nonatomic, retain) NSMutableArray *people;

+ (SPAddressBookManager *)sharedManager;

- (ABAuthorizationStatus)authorizationStatus;
- (void)requestAddressBookPermissions:(void (^)(BOOL success))completion;
-(void)loadPeople;

- (NSArray *)matchingPeopleForString:(NSString *)input filterOutPeople:(NSArray *)filter;

@end
