//
//  VSTheme.m
//  Q Branch LLC
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2012 Q Branch LLC. All rights reserved.
//

#import "VSTheme.h"



@interface VSTheme ()

@property (nonatomic, strong) NSDictionary *themeDictionary;
@property (nonatomic, strong) NSCache *colorCache;
@property (nonatomic, strong) NSCache *fontCache;
@property (nonatomic, strong) NSCache *userSizedFontCache;
@property (nonatomic, strong) UIFont *systemBodyFont;

@end


@implementation VSTheme


#pragma mark Init

- (id)initWithDictionary:(NSDictionary *)themeDictionary {
	
	self = [super init];
	if (self == nil)
		return nil;
	
	_themeDictionary = themeDictionary;

	[self clearCaches];
    
	return self;
}


- (void)clearCaches {
    
    _colorCache = [NSCache new];
	_fontCache = [NSCache new];
	_userSizedFontCache = [NSCache new];
    
    UIFontDescriptor *titleDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    _systemBodyFont = [UIFont fontWithDescriptor:titleDescriptor
                                            size:0.0];
    
    
    // adjust iPad size to better suit larger sized screen
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        _systemBodyFont = [UIFont fontWithDescriptor:_systemBodyFont.fontDescriptor
                                                size:_systemBodyFont.pointSize * 1.2];
    
}

- (id)objectForKey:(NSString *)key {

    // add support for ~ipad and ~iphone specific values
    // first check for the device specific value, then the generic value
    NSString *deviceSpecificKey = [key stringByAppendingString:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"~ipad" : @"~iphone")];
    
    id obj = [self.themeDictionary valueForKey:deviceSpecificKey];
    if (obj == nil && self.parentTheme != nil)
		obj = [self.parentTheme objectForKey:deviceSpecificKey];
    
    // check for generic value only if no value has been found
    if (obj == nil) {
        obj = [self.themeDictionary valueForKeyPath:key];
        if (obj == nil && self.parentTheme != nil)
            obj = [self.parentTheme objectForKey:key];
    }
    
    // check to see if the returned value was a key
    if ([obj isKindOfClass:[NSString class]] && [(NSString *)obj hasPrefix:@"@"])
        obj = [self objectForKey:[obj substringFromIndex:1]];
    
    
	return obj;
}

- (NSString *)stringForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	if (obj == nil)
		return nil;
	if ([obj isKindOfClass:[NSString class]])
		return obj;
	if ([obj isKindOfClass:[NSNumber class]])
		return [obj stringValue];
	return nil;
}

- (CGFloat)floatForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	if (obj == nil)
		return  0.0f;
	return [obj floatValue];
}

@end
