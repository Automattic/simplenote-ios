//
//  SPAppDelegate.h
//  Simplenote
//
//  Created by Tom Witkin on 7/3/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Simperium/Simperium.h>

@class SPTagsListViewController;
@class SPNoteListViewController;
@class SPNoteEditorViewController;
@class SPNavigationController;
@class SPModalActivityIndicator;

@interface SPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIWindow *pinLockWindow;

@property (strong, nonatomic, readonly) Simperium						*simperium;
@property (strong, nonatomic, readonly) NSManagedObjectContext			*managedObjectContext;
@property (strong, nonatomic, readonly) NSManagedObjectModel			*managedObjectModel;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator	*persistentStoreCoordinator;

@property (strong, nonatomic) SPNavigationController					*navigationController;
@property (strong, nonatomic) SPTagsListViewController					*tagListViewController;
@property (strong, nonatomic) SPNoteListViewController					*noteListViewController;
@property (strong, nonatomic) SPNoteEditorViewController				*noteEditorViewController;

@property (strong, nonatomic) NSString									*selectedTag;
@property (assign, nonatomic) BOOL										bSigningUserOut;

@property (assign, nonatomic) BOOL                                      allowTouchIDInsteadOfPin;

- (void)showOptions;

- (void)save;
- (void)logoutAndReset:(id)sender;

- (NSString *)getPin:(BOOL)checkLegacy;
- (void)setPin:(NSString *)newPin;
- (void)removePin;

+ (SPAppDelegate *)sharedDelegate;

@end
