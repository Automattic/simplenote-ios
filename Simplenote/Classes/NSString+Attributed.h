//
//  NSString+Attributed.h
//  Simplenote
//
//  Created by Tom Witkin on 9/2/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Attributed)

- (NSAttributedString *)attributedString;
- (NSMutableAttributedString *)mutableAttributedString;

@end
