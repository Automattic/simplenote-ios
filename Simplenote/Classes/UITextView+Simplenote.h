//
//  UITextView+Simplenote.h
//  Simplenote
//
//  Created by Jorge Leandro Perez on 3/25/15.
//  Copyright (c) 2015 Simperium. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITextView (Simplenote)

- (BOOL)applyAutoBulletsWithReplacementText:(NSString *)replacementText replacementRange:(NSRange)replacementRange;
- (NSRange)visibleTextRange;

@end
