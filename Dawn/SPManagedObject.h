//
//  SPManagedObject.h
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



@interface SPManagedObject : NSManagedObject

@property (copy, nonatomic) NSString *ghostData;
@property (copy, nonatomic) NSString *simperiumKey;

- (NSString *)version;

@end

//NS_ASSUME_NONNULL_BEGIN
//NS_ASSUME_NONNULL_END
