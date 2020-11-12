//
//  NSManagedObjectContext+CoreDataExtensions.m
//  Castaway
//
//  Created by Tom Witkin on 4/5/13.
//  Copyright (c) 2013 Tom Witkin. All rights reserved.
//

#import "NSManagedObjectContext+CoreDataExtensions.h"

@implementation NSManagedObjectContext (CoreDataExtensions)

- (NSArray *)fetchAllObjectsForEntityName:(NSString *)entityName {
    
    return [self fetchObjectsForEntityName:entityName withPredicate:nil];
}


- (NSArray *)fetchObjectsForEntityName:(NSString *)entityName withPredicate:(NSPredicate *)predicate {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:self];
    
    fetchRequest.entity = entity;
    if (predicate)
        fetchRequest.predicate = predicate;
    
    
    NSError *error;
    NSArray *fetchedObjects = [self executeFetchRequest:fetchRequest
                                                  error:&error];
    
    
    if (!error && fetchedObjects.count > 0) {
        return fetchedObjects;
    } else {
        return nil;
    }
    
}

- (NSManagedObject *)fetchObjectForEntityName:(NSString *)entityName withPredicate:(NSPredicate *)predicate {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:self];
    fetchRequest.entity = entity;
    fetchRequest.fetchLimit = 1;
    
    fetchRequest.predicate = predicate;
    
    
    NSError *error;
    NSArray *fetchedObjects = [self executeFetchRequest:fetchRequest
                                                  error:&error];
    
    
    if (!error && fetchedObjects.count > 0) {
        return fetchedObjects[0];
    } else {
        return nil;
    }
    
}

- (NSManagedObject *)fetchObjectForEntityName:(NSString *)entityName withAttribute:(NSString *)attribute equalTo:(id)equalObject {
    
    return [self fetchObjectForEntityName:entityName
                            withPredicate:[NSPredicate predicateWithFormat:@"(%K like %@)", attribute,  equalObject]];
    
}

- (NSManagedObject *)fetchObjectForEntityName:(NSString *)entityName withAttributes:(NSArray *)attributes equalToObjects:(NSArray *)equalObjects {
    
    
    if (attributes.count != equalObjects.count) {
        return nil;
    }
    
    for (NSObject *o in attributes) {
        if (![NSStringFromClass(o.class) isEqualToString:NSStringFromClass([NSString class])]) {
            return nil;
        }
    }
    
    // construct predicate
    
    NSMutableArray *predicates = [NSMutableArray array];
    for (int i = 0 ; i < attributes.count; i++) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K like %@)", attributes[i],  equalObjects[i]];
        [predicates addObject:predicate];
        
    }
    
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    
    return [self fetchObjectForEntityName:entityName
                            withPredicate:compoundPredicate];
    
    
}

- (NSInteger)countObjectsForEntityName:(NSString *)entityName withPredicate:(NSPredicate *)predicate {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:self];
    fetchRequest.entity = entity;
    fetchRequest.includesSubentities = NO; //Omit subentities. Default is YES (i.e. include subentities)
    fetchRequest.predicate = predicate;
    
    NSError *error;
    NSInteger count = [self countForFetchRequest:fetchRequest
                                           error:&error];
    
    if (count != NSNotFound)
        
        return count;
    
    else
        
        return 0;
}

- (void)saveToParent:(void(^)(NSError *error))completion
{
    NSError *error = nil;
    if (![self save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        if (completion != nil) {
            completion(error);
        }
    } else if (self.parentContext != nil) {
        [self.parentContext performBlock:^{
            [self.parentContext saveToParent:[completion copy]];
        }];
    } else {
        if (completion != nil) {
            completion(nil);
        }
    }
}


@end
