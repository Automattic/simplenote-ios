//
//  VSTheme.m
//  Q Branch LLC
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2012 Q Branch LLC. All rights reserved.
//

#import "VSTheme.h"


static BOOL stringIsEmpty(NSString *s);
static UIColor *colorWithHexString(NSString *hexString);


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


- (BOOL)boolForKey:(NSString *)key {

	id obj = [self objectForKey:key];
	if (obj == nil)
		return NO;
	return [obj boolValue];
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


- (NSInteger)integerForKey:(NSString *)key {

	id obj = [self objectForKey:key];
	if (obj == nil)
		return 0;
	return [obj integerValue];
}


- (CGFloat)floatForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	if (obj == nil)
		return  0.0f;
	return [obj floatValue];
}

- (UIColor *)colorForKey:(NSString *)key {

	UIColor *cachedColor = [self.colorCache objectForKey:key];
	if (cachedColor != nil)
		return cachedColor;
    
	NSString *colorString = [self stringForKey:key];
	UIColor *color = colorWithHexString(colorString);
	if (color == nil)
		color = [UIColor blackColor];

	[self.colorCache setObject:color forKey:key];

	return color;
}


- (UIEdgeInsets)edgeInsetsForKey:(NSString *)key {

	CGFloat left = [self floatForKey:[key stringByAppendingString:@"Left"]];
	CGFloat top = [self floatForKey:[key stringByAppendingString:@"Top"]];
	CGFloat right = [self floatForKey:[key stringByAppendingString:@"Right"]];
	CGFloat bottom = [self floatForKey:[key stringByAppendingString:@"Bottom"]];

	UIEdgeInsets edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
	return edgeInsets;
}




@end


#pragma mark -


static BOOL stringIsEmpty(NSString *s) {
	return s == nil || [s length] == 0;
}


static UIColor *colorWithHexString(NSString *hexString) {

	/*Picky. Crashes by design.*/
	
	if (stringIsEmpty(hexString))
		return [UIColor blackColor];

	NSMutableString *s = [hexString mutableCopy];
	[s replaceOccurrencesOfString:@"#" withString:@"" options:0 range:NSMakeRange(0, [hexString length])];
	CFStringTrimWhitespace((__bridge CFMutableStringRef)s);

	NSString *redString = [s substringToIndex:2];
	NSString *greenString = [s substringWithRange:NSMakeRange(2, 2)];
	NSString *blueString = [s substringWithRange:NSMakeRange(4, 2)];

	unsigned int red = 0, green = 0, blue = 0;
	[[NSScanner scannerWithString:redString] scanHexInt:&red];
	[[NSScanner scannerWithString:greenString] scanHexInt:&green];
	[[NSScanner scannerWithString:blueString] scanHexInt:&blue];

	return [UIColor colorWithRed:(CGFloat)red/255.0f green:(CGFloat)green/255.0f blue:(CGFloat)blue/255.0f alpha:1.0f];
}
