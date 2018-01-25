//
//  SPSimperiumManager.m
//  Simplenote
//
//  Created by Tom Witkin on 7/26/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPObjectManager.h"
#import "NSManagedObjectContext+CoreDataExtensions.h"
#import <Simperium/Simperium.h>
#import "SPAppDelegate.h"
#import "Note.h"
#import "Tag.h"
#import "NSString+Metadata.h"
#import "JSONKit+Simplenote.h"

@implementation SPObjectManager

+ (SPObjectManager *)sharedManager
{
    static SPObjectManager *sharedManager = nil;
    if (!sharedManager) {
        sharedManager = [[SPObjectManager alloc] init];
    }
    
    return sharedManager;
}

- (void)save {
    
    [[SPAppDelegate sharedDelegate] save];
}

- (NSArray *)notes {
    
    return [[SPAppDelegate sharedDelegate].simperium.managedObjectContext fetchAllObjectsForEntityName:@"Note"];
}

// Unsycned notes have version "0" in the ghost data
- (BOOL)hasUnsyncedNotes
{
    for (Note *note in self.notes) {
        NSDictionary *parsedGhost   = [note.ghostData objectFromJSONString];
        id version = [parsedGhost objectForKey:@"version"];
        if (version == nil) {
            continue;
        }
        
        if ([version integerValue] == 0) {
            return YES;
        }
    }
    
    return NO;
}

- (NSArray *)tags {
    
    // sort by index
    NSArray *allTags = [[SPAppDelegate sharedDelegate].simperium.managedObjectContext fetchAllObjectsForEntityName:@"Tag"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index"
                                                                     ascending:YES];
    
    return [allTags sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (BOOL)tagExists:(NSString *)tagName {
    
    for (Tag *tag in self.tags) {
        if ([tag.name compare:tagName options:NSCaseInsensitiveSearch] == NSOrderedSame)
            return YES;
    }
    
    return NO;
}

- (Tag *)tagForName:(NSString *)tagName {
    
    for (Tag *tag in self.tags) {
        if ([tag.name compare:tagName options:NSCaseInsensitiveSearch] == NSOrderedSame)
            return tag;
    }
    
    return nil;
}


-(void)editTag:(Tag *)tag title:(NSString *)newTitle
{
    [self createTagFromString:newTitle atIndex:[self indexOfTag:tag]];
    
	// Brute force renaming of all notes with this tag
    NSArray *notes = [self notesWithTag:tag];
	for (Note *note in notes) {
        // Issue #311: Force the note to be loaded (this is a hack, yeah!)
        [note simperiumKey];
        
        // Proceed renaming!
        [note stripTag: tag.name];
        [note addTag: newTitle];
        [note createPreview];
	}

    [[SPAppDelegate sharedDelegate].managedObjectContext deleteObject:tag];
    
    [self save];
}

- (BOOL)removeTagName:(NSString *)tagName {
    
    return [self removeTag:[self tagForName:tagName]];
}

-(BOOL)removeTag:(Tag *)tag
{
    NSArray *tagList = [self tags];
    BOOL tagRemoved = NO;
    
    if (!tag) {
        NSLog(@"Critical error: tried to remove a tag that doesn't exist");
        return tagRemoved;
    }
    
    NSArray *notes = [self notesWithTag: tag];
	
    // Strip this tag from all notes
	for (Note *note in notes) {
		[note stripTag: tag.name];
		[note createPreview];
	}
    NSInteger i = [tagList indexOfObject: tag] + 1;
    
    // Decrement the index of all tags after this one
    if (i != NSNotFound) {
        for (;i<[tagList count]; i++) {
            Tag *tagToUpdate = [tagList objectAtIndex: i];
            int currentIndex = [tagToUpdate.index intValue];
            tagToUpdate.index = [NSNumber numberWithInt:currentIndex-1];
        }
    }
    
    [[SPAppDelegate sharedDelegate].managedObjectContext deleteObject:tag];
    tagRemoved = tag.isDeleted;
    [self save];

    return tagRemoved;
}

- (Tag *)createTagFromString:(NSString *)tagName {
    
    if (!tagName)
        return nil;
    
    // add tag at end
    return [self createTagFromString:tagName atIndex:[self.tags count]];
}

- (Tag *)createTagFromString:(NSString *)tagName atIndex:(NSInteger)index {
    
    if (tagName == nil || tagName.length == 0 || [tagName isEqualToString:@" "]) {
        NSLog(@"Attempted to create empty tag");
        return nil;
    }
    
    // Make sure email addresses don't get added as proper tags
    if ([tagName containsEmailAddress])
        return nil;
    
    // Check for duplicate
    SPBucket *tagBucket = [[SPAppDelegate sharedDelegate].simperium bucketForName:@"Tag"];
    if ([tagBucket objectForKey:[tagName lowercaseString]])
        return nil;
    
    // make sure tag has no whitespace
    tagName = [[tagName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
    
    NSArray *tagList = [self tags];
    
    // Update indexes depending on where the tag will be inserted
    if (index < [tagList count]) {
        NSInteger i = index;
        for (;i<[tagList count]; i++) {
            Tag *updatedTag = [tagList objectAtIndex:i];
            updatedTag.index = @(i+1);
            NSLog(@"changed tag index at %ld to %d", (long)i, [updatedTag.index intValue]);
        }
    }
    
	NSManagedObjectContext *context = [SPAppDelegate sharedDelegate].managedObjectContext;
    Tag *newTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag"
                                                inManagedObjectContext:context];
    newTag.simperiumKey = [[tagName lowercaseString] urlEncodeString];
    newTag.index = @(index);
    newTag.name = tagName;
    NSLog(@"added new tag with index %d", [newTag.index intValue]);
    
    return newTag;
}


- (NSInteger)indexOfTag:(Tag *)tag {
    
    return [self.tags indexOfObject:tag];
    
}


-(NSArray *)notesWithTag:(Tag *)tag
{
    if (!tag.name)
        return nil;
    
    NSMutableArray *predicateList = [NSMutableArray arrayWithCapacity:3];
    [predicateList addObject: [NSPredicate predicateWithFormat: @"deleted == %@", [NSNumber numberWithBool:NO]]];
    [predicateList addObject: [NSPredicate predicateWithFormat: @"tags CONTAINS[c] %@", tag.name]];
    NSString *regEx = [NSString stringWithFormat:@".*\"%@\".*", tag.name];
    [predicateList addObject: [NSPredicate predicateWithFormat: @"tags MATCHES[c] %@", regEx]];
    
    NSPredicate *compound = [NSCompoundPredicate andPredicateWithSubpredicates:predicateList];
    
	NSManagedObjectContext *context = [[SPAppDelegate sharedDelegate] managedObjectContext];
    return [context fetchObjectsForEntityName:@"Note" withPredicate:compound];
}

- (void)moveTagFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    NSArray *tagList = [self tags];
    NSMutableArray *tagListCopy = [tagList mutableCopy];
    Tag *fromTag = [tagList objectAtIndex:fromIndex];
    
    // Make arrays do the work of figuring out index changes (inefficient, but acceptable since this happens
    // infrequently)
    [tagListCopy insertObject:fromTag atIndex: toIndex+(fromIndex < toIndex ? 1:0)];
    [tagListCopy removeObjectAtIndex:fromIndex + (fromIndex > toIndex ? 1:0)];
    
    for (Tag *tag in tagList) {
        tag.index = @([tagListCopy indexOfObject:tag]);  // yep, inefficient
        NSLog(@"index of tag %@ is now %d", tag.name, [tag.index intValue]);
    }
    
    [self save];
    
    
}

- (void)trashNote:(Note *)note {
    
    note.deleted = YES;
    note.modificationDate = [NSDate date];
    
    [self save];
}

- (void)restoreNote:(Note *)note {
    
    note.deleted = NO;
    note.modificationDate = [NSDate date];
    
    [self save];
    
}

- (void)permenentlyDeleteNote:(Note *)note {

    [[[SPAppDelegate sharedDelegate] managedObjectContext] deleteObject:note];
    [self save];
    
}

-(void)emptyTrash
{

    NSManagedObjectContext *context = [[SPAppDelegate sharedDelegate] managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deleted == YES"];
    NSArray *notesToDelete = [context fetchObjectsForEntityName:@"Note" withPredicate:predicate];

	for (Note *note in notesToDelete)  {
        [self permenentlyDeleteNote:note];
    }
    
    [self save];
    
}

@end
