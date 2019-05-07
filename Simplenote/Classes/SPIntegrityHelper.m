//
//  SPIntegrityHelper.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 10/2/14.
//  Copyright (c) 2014 Automattic. All rights reserved.
//

#import "SPIntegrityHelper.h"
#import <Simperium/Simperium.h>
#import "Note.h"
#import "JSONKit+Simplenote.h"
#import "SVProgressHUD.h"



#pragma mark ================================================================================
#pragma mark Workaround: Exposing Private SPBucket methods
#pragma mark ================================================================================

@interface SPBucket ()
- (BOOL)hasLocalChangesForKey:(NSString *)key;
@end


#pragma mark ================================================================================
#pragma mark Constants
#pragma mark ================================================================================

static NSString *kIntegrityDidRunKey    = @"IntegrityDidRun";
static NSString *kEntityName            = @"Note";
static NSString *kMemberDataKey         = @"obj";
static NSString *kContentKey            = @"content";


#pragma mark ================================================================================
#pragma mark SPIntegrityHelper
#pragma mark ================================================================================

@implementation SPIntegrityHelper

+ (void)reloadInconsistentNotesIfNeeded:(Simperium *)simperium {
    
    // This process should be executed *just once*, and only if the user is already logged in
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:kIntegrityDidRunKey] == true) {
        return;
    }
    
    [defaults setBool:true forKey:kIntegrityDidRunKey];
    [defaults synchronize];
    
    if (simperium.user.authenticated == false) {
        return;
    }
    
    // Proceed Asynchronously on the main thread: Don't risk getting the process killed by the watchdog!
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadInconsistentNotes:simperium];
        [SVProgressHUD dismiss];
    });
}


+ (void)reloadInconsistentNotes:(Simperium *)simperium {
    
    // Fetch every single Note entity that is stored
    SPBucket *bucket                = [simperium bucketForName:kEntityName];
    NSArray *allNotes               = [bucket allObjects];
    NSDate *startDate               = [NSDate date];
    NSInteger reloadedCount         = 0;
    
    NSLog(@"<> Integrity Check: Found %ld Entities [%f seconds elapsed]", (unsigned long)allNotes.count, startDate.timeIntervalSinceNow);
    
    // Compare the Ghost Content string, against the Entity Content
    for (Note *note in allNotes) {
        NSDictionary *parsedGhost   = [note.ghostData objectFromJSONString];
        NSString *ghostContent      = parsedGhost[kMemberDataKey][kContentKey];
        
        // If the contents don't match and there are no pending changes: fall back to ghostContent + Nuke Preview
        if (ghostContent == nil ||
            ![ghostContent isKindOfClass:[NSString class]] ||
            [ghostContent isEqualToString:note.content] ||
            [bucket hasLocalChangesForKey:note.simperiumKey])
        {
            continue;
        }
        
        note.content = ghostContent;
        note.preview = nil;
        ++reloadedCount;
    }
    
    NSLog(@"<> Integrity Check: Reloaded %ld Entities [%f seconds elapsed]", (long)reloadedCount, startDate.timeIntervalSinceNow);
    
    if (reloadedCount <= 0) {
        return;
    }

    [simperium saveWithoutSyncing];
    
    NSLog(@"<> Integrity Check: Process Complete [%f seconds elapsed]", startDate.timeIntervalSinceNow);
}

@end
