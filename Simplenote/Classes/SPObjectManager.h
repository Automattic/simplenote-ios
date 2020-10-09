//
//  SPSimperiumManager.h
//  Simplenote
//
//  Created by Tom Witkin on 7/26/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Note;
@class Tag;

NS_ASSUME_NONNULL_BEGIN

@interface SPObjectManager : NSObject

+ (SPObjectManager *)sharedManager;

- (NSArray *)notes;
- (NSArray *)tags;


#pragma mark - Tags

- (NSArray *)notesWithTag:(Tag *)tag;
- (void)editTag:(Tag *)tag title:(NSString *)newTitle;
- (BOOL)removeTagName:(NSString *)tagName;
- (BOOL)removeTag:(Tag *)tag;
- (Tag *)createTagFromString:(NSString *)tagName;
- (BOOL)tagExists:(NSString *)tagName;
- (Tag *)tagForName:(NSString *)tagName;
- (void)moveTagFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;


#pragma mark - Notes

- (void)updateMarkdownState:(Note *)note markdown:(BOOL)markdown;
- (void)updatePublishedState:(Note *)note published:(BOOL)published;
- (void)updatePinnedState:(Note *)note pinned:(BOOL)pinned;

- (void)trashNote:(Note *)note;
- (void)restoreNote:(Note *)note;
- (void)permenentlyDeleteNote:(Note *)note;
- (void)emptyTrash;

#pragma mark - Sharing

- (void)insertTagNamed:(NSString *)tagName note:(Note *)note;
- (void)removeTagNamed:(NSString *)tagName note:(Note *)note;

@end

NS_ASSUME_NONNULL_END
