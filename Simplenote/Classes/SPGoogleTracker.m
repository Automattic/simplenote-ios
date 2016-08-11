//
//  SPGoogleTracker.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 10/9/15.
//  Copyright © 2015 Automattic. All rights reserved.
//

#import "SPGoogleTracker.h"
#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>


@implementation SPGoogleTracker

+ (instancetype)sharedInstance
{
    static SPGoogleTracker *_tracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tracker = [[self class] new];
    });
    
    return _tracker;
}

- (void)refreshMetadataWithEmail:(NSString *)email
{
    [[[GAI sharedInstance] defaultTracker] set:@"email" value:email];
}

- (void)trackEventWithCategory:(NSString *)category
                        action:(NSString *)action
                         label:(NSString *)label
                         value:(NSNumber *)value
{
    NSParameterAssert(category);
    NSParameterAssert(action);
    
    GAIDictionaryBuilder *dictionary = [GAIDictionaryBuilder createEventWithCategory:category
                                                                              action:action
                                                                               label:label
                                                                               value:value];
    [[[GAI sharedInstance] defaultTracker] send:[dictionary build]];
}

@end
