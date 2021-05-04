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
#import "Simplenote-Swift.h"


@implementation SPObjectManager

+ (SPObjectManager *)sharedManager
{
    static SPObjectManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[SPObjectManager alloc] init];
    });

    return sharedManager;
}

- (void)save {
    
    [[SPAppDelegate sharedDelegate] save];
}

- (NSArray *)notes {
    
    return [[SPAppDelegate sharedDelegate].simperium.managedObjectContext fetchAllObjectsForEntityName:@"Note"];
}

- (NSArray *)tags {
    
    // sort by index
    NSArray *allTags = [[SPAppDelegate sharedDelegate].simperium.managedObjectContext fetchAllObjectsForEntityName:@"Tag"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index"
                                                                     ascending:YES];
    
    return [allTags sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (BOOL)tagExists:(NSString *)tagName
{
    return [self tagForName:tagName] != nil;
}

// This API performs `Tag` comparison by checking the `encoded tag hash`, in order to
// normalize / isolate ourselves from potential Unicode-Y issues.
//
// Ref. https://github.com/Automattic/simplenote-macos/pull/617
//
- (Tag *)tagForName:(NSString *)tagName
{
    NSString *targetTagHash = tagName.byEncodingAsTagHash;
    for (Tag *tag in self.tags) {
        if ([tag.name.byEncodingAsTagHash isEqualToString:targetTagHash]) {
            return tag;
        }
    }

    return nil;
}

- (void)editTag:(Tag *)tag title:(NSString *)newTitle
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

- (BOOL)removeTagName:(NSString *)tagName
{
    return [self removeTag:[self tagForName:tagName]];
}

- (BOOL)removeTag:(Tag *)tag
{
    NSArray *tagList = [self tags];
    BOOL tagRemoved = NO;
    
    if (!tag) {
        NSLog(@"Critical error: tried to remove a tag that doesn't exist");
        return tagRemoved;
    }
    
    NSArray *notes = [self notesWithTag: tag includeDeleted:YES];
	
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

- (Tag *)createTagFromString:(NSString *)tagName
{
    // Add tag at end
    return [self createTagFromString:tagName atIndex:self.tags.count];
}

- (Tag *)createTagFromString:(NSString *)tagName atIndex:(NSInteger)index
{
    if (tagName == nil || tagName.length == 0 || [tagName isEqualToString:@" "]) {
        NSLog(@"Attempted to create empty tag");
        return nil;
    }
    
    // Make sure email addresses don't get added as proper tags
    if ([tagName isValidEmailAddress]) {
        return nil;
    }

    // Ensure the new tag has no spaces
    NSString *newTagName = [[tagName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];

    // Check for duplicate
    if ([self tagExists:newTagName]) {
        return nil;
    }

    // Update indexes depending on where the tag will be inserted
    NSInteger tagIndex = index;
    NSArray *tagList = [self tags];

    while (tagIndex < tagList.count) {
        Tag *updatedTag = [tagList objectAtIndex:tagIndex];
        updatedTag.index = @(tagIndex+1);
        NSLog(@"Changed tag index at %ld to %d", (long)tagIndex, [updatedTag.index intValue]);
        tagIndex++;
    }

    // Finally Insert the new Tag
    SPBucket *tagBucket = [[SPAppDelegate sharedDelegate].simperium bucketForName:@"Tag"];
    Tag *newTag = [tagBucket insertNewObjectForKey:newTagName.byEncodingAsTagHash];
    newTag.index = @(index);
    newTag.name = newTagName;

    NSLog(@"Added new tag with index %d", [newTag.index intValue]);
    
    return newTag;
}


- (NSInteger)indexOfTag:(Tag *)tag {
    
    return [self.tags indexOfObject:tag];
    
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

- (void)trashNote:(Note *)note
{
    note.deleted = YES;
    note.modificationDate = [NSDate date];
    
    [self save];
}

- (void)restoreNote:(Note *)note
{
    note.deleted = NO;
    note.modificationDate = [NSDate date];
    
    [self save];
}

- (void)permenentlyDeleteNote:(Note *)note
{
    [[[SPAppDelegate sharedDelegate] managedObjectContext] deleteObject:note];
    [self save];
}

- (void)emptyTrash
{
    NSManagedObjectContext *context = [[SPAppDelegate sharedDelegate] managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deleted == YES"];
    NSArray *notesToDelete = [context fetchObjectsForEntityName:@"Note" withPredicate:predicate];

	for (Note *note in notesToDelete)  {
        [self permenentlyDeleteNote:note];
    }
    
    [self save];
}


#pragma mark - Sharing

- (void)insertTagNamed:(NSString *)tagName note:(Note *)note
{
    [note addTag:tagName];
    note.modificationDate = [NSDate date];

    [self save];
}

- (void)removeTagNamed:(NSString *)tagName note:(Note *)note
{
    [note stripTag:tagName];
    note.modificationDate = [NSDate date];

    [self save];
}


#pragma mark - Updating Notes

- (void)updateMarkdownState:(BOOL)markdown note:(Note *)note
{
    if (note.markdown == markdown) {
        return;
    }

    note.markdown = markdown;
    note.modificationDate = [NSDate date];

    [self save];
}

- (void)updatePublishedState:(BOOL)published note:(Note *)note
{
    if (note.published == published) {
        return;
    }

    note.published = published;
    note.modificationDate = [NSDate date];

    [self save];
}

- (void)updatePinnedState:(BOOL)pinned note:(Note *)note
{
    if (note.pinned == pinned) {
        return;
    }

    note.pinned = pinned;
    note.modificationDate = [NSDate date];

    [self save];
}

@end
