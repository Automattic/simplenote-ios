//
//  NSManagedObjectContext+CoreDataExtensions.h
//  Castaway
//
//  Created by Tom Witkin on 4/5/13.
//  Copyright (c) 2013 Tom Witkin. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (CoreDataExtensions)

- (NSArray *)fetchAllObjectsForEntityName:(NSString *)entityName;

- (NSArray *)fetchObjectsForEntityName:(NSString *)entityName withPredicate:(NSPredicate *)predicate;

- (NSManagedObject *)fetchObjectForEntityName:(NSString *)entityName withPredicate:(NSPredicate *)predicate;

- (NSManagedObject *)fetchObjectForEntityName:(NSString *)entityName withAttribute:(NSString *)attribute equalTo:(id)equalObject;

- (NSManagedObject *)fetchObjectForEntityName:(NSString *)entityName withAttributes:(NSArray *)attributes equalToObjects:(NSArray *)equalObjects;

- (NSInteger)countObjectsForEntityName:(NSString *)entityName withPredicate:(NSPredicate *)predicate;

- (void)saveToParent:(void(^)(NSError *error))completion;

@end
