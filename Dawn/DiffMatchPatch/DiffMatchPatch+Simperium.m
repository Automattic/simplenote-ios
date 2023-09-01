//
//  DiffMatchPatch+Simperium.m
//  Simperium
//
//  Created by Jorge Leandro Perez on 6/16/14.
//  Copyright (c) 2014 Simperium. All rights reserved.
//

#import "DiffMatchPatch+Simperium.h"



static NSInteger DiffMatchPatchApplyError = -9999;


@implementation DiffMatchPatch (Simperium)

- (NSString *)sp_patch_apply:(NSArray *)sourcePatches toString:(NSString *)text error:(NSError **)error {
    
    NSArray *patched    = [self patch_apply:sourcePatches toString:text];
    NSArray *results    = [patched lastObject];
    BOOL success        = YES;
    
    for (NSNumber *result in results) {
        if (![result isKindOfClass:[NSNumber class]]) {
            continue;
        }
        if (!result.boolValue) {
            success = NO;
            break;
        }
    }
    
    if (!success && error) {
        *error = [[NSError alloc] initWithDomain:NSStringFromClass([self class])
                                            code:DiffMatchPatchApplyError
                                        userInfo:nil];
        return nil;
    }
    
    return [patched firstObject];
}

@end
