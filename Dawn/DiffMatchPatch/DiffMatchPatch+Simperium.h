//
//  DiffMatchPatch+Simperium.h
//  Simperium
//
//  Created by Jorge Leandro Perez on 6/16/14.
//  Copyright (c) 2014 Simperium. All rights reserved.
//

#import "DiffMatchPatch.h"

NS_ASSUME_NONNULL_BEGIN

@interface DiffMatchPatch (Simperium)

- (nullable NSString *)sp_patch_apply:(nullable NSArray *)sourcePatches toString:(nullable NSString *)text error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
