//
//  Note.h
//  Simplenote
//
//  Created by Michael Johnston on 01/07/08.
//  Copyright 2008 Simperium. All rights reserved.
//

#import <Simperium/SPManagedObject.h>

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
    NSMutableArray  *emailTagsArray;
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

@property (nonatomic,   copy) NSString          *content;
@property (nonatomic,   copy) NSString          *publishURL;
@property (nonatomic,   copy) NSDate            *modificationDate;
@property (nonatomic,   copy) NSString          *tags;
@property (nonatomic, strong) NSMutableArray    *tagsArray;
@property (nonatomic, strong) NSMutableArray    *emailTagsArray;
@property (nonatomic,   copy) NSString          *shareURL;
@property (nonatomic,   copy) NSDate            *creationDate;
@property (nonatomic,   copy) NSString          *systemTags;
@property (nonatomic,   copy) NSString          *modificationDatePreview;
@property (nonatomic,   copy) NSString          *creationDatePreview;
@property (nonatomic,   copy) NSString          *preview;
@property (nonatomic,   copy) NSString          *titlePreview;
@property (nonatomic,   copy) NSString          *bodyPreview;
@property BOOL deleted;
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
- (void)createPreview;
- (NSDictionary *)noteDictionaryWithContent:(BOOL)include;
- (BOOL)isList;

@end
