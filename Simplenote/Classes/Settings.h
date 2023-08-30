//
//  Settings.h
//  Simplenote
//
//  Created by Jorge Leandro Perez on 3/16/15.
//  Copyright (c) 2015 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPManagedObject.h"


@interface Settings : SPManagedObject

@property (nonatomic,   copy) NSString *ghostData;
@property (nonatomic,   copy) NSString *simperiumKey;

@property (nonatomic, strong) NSNumber *ratings_disabled;
@property (nonatomic, strong) NSNumber *minimum_events;
@property (nonatomic, strong) NSNumber *minimum_interval_days;

@property (nonatomic, strong) NSNumber *like_skip_versions;
@property (nonatomic, strong) NSNumber *decline_skip_versions;
@property (nonatomic, strong) NSNumber *dislike_skip_versions;

@end
