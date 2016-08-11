//
//  JSONKit+Simplenote.h
//  Simplenote-iOS
//
//  Created by Jorge Leandro Perez on 1/4/14.
//  Copyright (c) 2014 Simperium. All rights reserved.
//



@interface NSArray (JSONKit)
- (NSString *)JSONString;
@end

@interface NSDictionary (JSONKit)
- (NSString *)JSONString;
@end

@interface NSString (JSONKit)
- (id)objectFromJSONString;
@end

@interface NSData (JSONKit)
- (id)objectFromJSONString;
@end
