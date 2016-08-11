//
//  SPGoogleTracker.h
//  Simplenote
//
//  Created by Jorge Leandro Perez on 10/9/15.
//  Copyright © 2015 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  @class      SPGoogleTracker
 *  @brief      The purpose of this class is to encapsulate all of the interaction required with Google Analytics SDK.
 */

@interface SPGoogleTracker : NSObject

+ (instancetype)sharedInstance;


/**
 *  @details    Refreshes the Tracker's metadata
 */
- (void)refreshMetadataWithEmail:(NSString *)email;


/**
 *  @details    Tracks a given event
 *  @param      category    Category of the event that has ocurred
 *  @param      action      Name of the action that triggered the event
 *  @param      label       Optional contextual information
 *  @param      value       Optional payload
 */
- (void)trackEventWithCategory:(NSString *)category
                        action:(NSString *)action
                         label:(NSString *)label
                         value:(NSNumber *)value;

@end
