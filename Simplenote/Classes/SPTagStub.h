//
//  SPTagStub.h
//  Simplenote
//
//  Copyright 2011 Simperium, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SPTagStub : NSObject {
}


#pragma mark - Constructor
- (id)initWithTag:(NSString *)aTag;
- (id)initWithTag:(NSString *)aTag displayText:(NSString *)aDisplayText;


#pragma mark - Properties
@property (nonatomic, copy) NSString *displayText;
@property (nonatomic, assign) BOOL isEmailTag;
@property (nonatomic, retain) NSString *tag;


#pragma mark - Methods
- (BOOL)hasDisplayText;

@end