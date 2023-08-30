//
//  Note.h
//  Simplenote
//
//  Created by Michael Johnston on 01/07/08.
//  Copyright 2008 Simperium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPManagedObject.h"


@interface Note : SPManagedObject {
    NSString        *content;
    NSString        *modificationDatePreview;
    NSString        *creationDatePreview;
    NSString        *titlePreview;
    NSString        *contentPreview;
    NSString        *shareURL;
    NSString        *publishURL;
    NSDate          *creationDate;
    NSDate          *modificationDate;
    NSString        *tags;
    NSString        *systemTags;
    NSMutableArray  *tagsArray;
    NSMutableArray  *systemTagsArray;
    NSString        *remoteId;
    int             lastPosition;
    BOOL            pinned;
    BOOL            markdown;
    BOOL            deleted;
    BOOL            shared;
    BOOL            published;
    BOOL            unread;
    NSDictionary    *versions;
}

@property (nonatomic,   copy) NSString                  *content;
@property (nonatomic,   copy) NSString                  *publishURL;
@property (nonatomic,   copy) NSDate                    *modificationDate;
@property (nonatomic,   copy) NSString                  *tags;
@property (nonatomic, strong) NSMutableArray<NSString*> *tagsArray;
@property (nonatomic,   copy) NSString                  *shareURL;
@property (nonatomic,   copy) NSDate                    *creationDate;
@property (nonatomic,   copy) NSString                  *systemTags;
@property (nonatomic,   copy) NSString                  *modificationDatePreview;
@property (nonatomic,   copy) NSString                  *creationDatePreview;

@property (nonatomic,   copy) NSString                  *titlePreview;
@property (nonatomic,   copy) NSString                  *bodyPreview;

// What's going on:
//
//  -   Since Simplenote's inception, logic deletion flag was a simple boolean called `deleted`
//  -   Collision with NSManagedObject's `deleted` flag wasn't picked up
//  -   Eventually CLANG enhanced checks allowed us to notice there's a collision
//
//  Proper fix involves a heavy modification in Simperium, which would allow us to keep the `deleted` "internal"
//  property name, while exposing a different property setter / getter, and thus, avoiding the collision.
//
// In This thermonuclear massive super workaround, we're simply silencing the warning.
//
// Proper course of action should be taken as soon as the next steps for Simperium are outlined.
//
// TODO: JLP Dec.3.2019.
//
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
@property BOOL deleted;
#pragma clang diagnostic pop

@property (nonatomic, assign) int               lastPosition;
@property (nonatomic, assign) BOOL              pinned;
@property (nonatomic, assign) BOOL              markdown;
@property (nonatomic, assign) BOOL              shared;
@property (nonatomic, assign) BOOL              published;
@property (nonatomic, assign) BOOL              unread;

- (NSString *)dateString:(NSDate *)date brief:(BOOL)brief;
- (NSString *)creationDateString:(BOOL)brief;
- (NSString *)modificationDateString:(BOOL)brief;
- (NSString *)localID;

- (void)updateTagsArray;
- (void)updateSystemTagsArray;
- (BOOL)hasTags;
- (BOOL)hasTag:(NSString *)tag;
- (void)addTag:(NSString *)tag;
- (void)addSystemTag:(NSString *)tag;
- (void)setSystemTagsFromList:(NSArray *)tagList;
- (void)stripSystemTag:(NSString *)tag;
- (BOOL)hasSystemTag:(NSString *)tag;
- (void)setTagsFromList:(NSArray *)tagList;
- (void)stripTag:(NSString *)tag;
- (void)ensurePreviewStringsAreAvailable;
- (NSDictionary *)noteDictionaryWithContent:(BOOL)include;
- (BOOL)isList;

@end
