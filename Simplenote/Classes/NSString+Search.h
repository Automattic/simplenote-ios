//
//  NSString+Search.h
//  Simplenote
//
//  Created by Tom Witkin on 8/28/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Search)

- (nonnull NSArray<NSValue *> *)rangesForTerms:(nonnull NSString *)terms;

@end
