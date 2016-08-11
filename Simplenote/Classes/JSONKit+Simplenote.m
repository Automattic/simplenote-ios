//
//  JSONKit+Simplenote.m
//  Simplenote-iOS
//
//  Created by Jorge Leandro Perez on 1/4/14.
//  Copyright (c) 2014 Simperium. All rights reserved.
//

#import "JSONKit+Simplenote.h"



#ifdef DEBUG
static NSJSONWritingOptions const SPJSONWritingOptions = NSJSONWritingPrettyPrinted;
#else
static NSJSONWritingOptions const SPJSONWritingOptions = 0;
#endif

@implementation NSJSONSerialization (JSONKit)

+ (NSString *)JSONStringFromObject:(id)object {
    if (!object) {
		return nil;
	}
	
    NSError __autoreleasing *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object
                                                   options:SPJSONWritingOptions
                                                     error:&error];
	
    if (error) {
        NSLog(@"JSON Serialization of object %@ failed due to error %@",object, error);
        return nil;
    }
	
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (id)JSONObjectWithData:(NSData *)data {
    if (!data) {
		return nil;
	}
	
    NSError __autoreleasing *error = nil;
	
    id value = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"JSON Deserialization of data %@ failed due to error %@",data, error);
        return nil;
    }
    return value;
}


@end

@implementation NSArray (JSONKit)

- (NSString *)JSONString {
    return [NSJSONSerialization JSONStringFromObject:self];
}

@end

@implementation NSDictionary (JSONKit)

- (NSString *)JSONString {
    return [NSJSONSerialization JSONStringFromObject:self];
}

@end



@implementation NSString (JSONKit)

- (id)objectFromJSONString {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data];
}

@end

@implementation NSData (JSONKit)

- (id)objectFromJSONString {
    return [NSJSONSerialization JSONObjectWithData:self];
}

@end
