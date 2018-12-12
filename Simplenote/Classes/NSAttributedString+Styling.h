//
//  NSAttributedString+Styling.h
//  Simplenote
//
//  Created by Tom Witkin on 8/8/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Styling)

+ (NSAttributedString *)attributedStringWithImage:(UIImage *)image;
- (NSAttributedString *)attributedStringWithLeadingImage:(UIImage *)image lineHeight:(CGFloat)lineHeight;
+ (NSAttributedString *)attributedStringWithChecklistAttachments: (NSAttributedString *)sourceString withColor: (UIColor *)color;

@end
