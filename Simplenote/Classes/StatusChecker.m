#import "StatusChecker.h"
#import "Note.h"
#import "Simplenote-Swift.h"



#pragma mark ================================================================================
#pragma mark Workaround: Exposing Private SPBucket methods
#pragma mark ================================================================================

@interface SPBucket ()
- (BOOL)hasLocalChangesForKey:(NSString *)key;
@end


#pragma mark ================================================================================
#pragma mark Constants
#pragma mark ================================================================================

static NSString *kEntityName = @"Note";


#pragma mark ================================================================================
#pragma mark StatusChecker
#pragma mark ================================================================================

@implementation StatusChecker

+ (BOOL)hasUnsentChanges:(Simperium *)simperium
{    
    if (simperium.user.authenticated == false) {
        return false;
    }

    SPBucket *bucket = [simperium bucketForName:kEntityName];
    NSArray *allNotes = [bucket allObjects];
    NSDate *startDate = [NSDate date];

    NSLog(@"<> Status Checker: Found %ld Entities [%f seconds elapsed]", (unsigned long)allNotes.count, startDate.timeIntervalSinceNow);
    
    // Compare the Ghost Content string, against the Entity Content
    for (Note *note in allNotes) {
        if ([bucket hasLocalChangesForKey:note.simperiumKey]) {
            NSLog(@"<> Status Checker: FOUND entities with local changes [%f seconds elapsed]", startDate.timeIntervalSinceNow);
            return true;
        }
    }

    NSLog(@"<> Status Checker: No entities with local changes [%f seconds elapsed]", startDate.timeIntervalSinceNow);
    return false;
}

@end
