//
//  NSString+Attributed.m
//  Simplenote
//
//  Created by Tom Witkin on 9/2/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "NSString+Attributed.h"

@implementation NSString (Attributed)

- (NSAttributedString *)attributedString {
    
    return [[NSAttributedString alloc] initWithString:self];
}

- (NSMutableAttributedString *)mutableAttributedString {
    
    return [[NSMutableAttributedString alloc] initWithString:self];
}

@end
