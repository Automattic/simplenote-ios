//
//  NSTextStorage+Highlight.h
//  Simplenote
//
//  Created by Tom Witkin on 8/28/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSTextStorage (Highlight)

- (void)applyColorAttribute:(id)color forRanges:(NSArray *)wordRanges;
- (void)applyAttributes:(NSDictionary *)attributes matchingStrings:(NSArray *)strings characterLimit:(NSInteger)characterLimit;

@end
