//
//  SPAutomatticTracker.h
//  Simplenote
//
//  Created by Jorge Leandro Perez on 10/9/15.
//  Copyright © 2015 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  @class      SPAutomatticTracker
 *  @brief      The purpose of this class is to encapsulate all of the interaction required with A8C's Tracks.
 */

@interface SPAutomatticTracker : NSObject

+ (instancetype)sharedInstance;


/**
 *  @details    Refreshes the Tracker's metadata
 *  @param      email       The user's email account
 */
- (void)refreshMetadataWithEmail:(NSString *)email;


/**
 *  @details    Refreshes the Tracker's metadata
 */
- (void)refreshMetadataForAnonymousUser;


/**
 *  @details    Tracks a given event
 *  @param      name        The name of the event that should be tracked
 *  @param      properties  Optional collection of values, to be passed along
 */
- (void)trackEventWithName:(NSString *)name properties:(NSDictionary *)properties;

@end
