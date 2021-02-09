//
//  SPEditorTextView.h
//  Simplenote
//
//  Created by Tom Witkin on 8/16/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPTextView.h"

@protocol SPEditorTextViewDelegate <UITextViewDelegate>
- (void)textView:(UITextView *)textView receivedInteractionWithURL:(NSURL *)url;
@end


@interface SPEditorTextView : SPTextView

@property (nonatomic, strong) UIFont *checklistsFont;
@property (nonatomic, strong) UIColor *checklistsTintColor;

@property (nonatomic, readonly) BOOL isInserting;
@property (nonatomic, readonly) BOOL isDeletingBackward;

@property (nonatomic, strong) void (^onContentPositionChange)(void);

- (void)scrollToBottomWithAnimation:(BOOL)animated;
- (void)scrollToTop;
- (void)processChecklists;
- (void)insertOrRemoveChecklist;

/// iOS 13.0 + 13.1 had an usability issue that rendered link interactions within a UITextView next to impossible.
/// Since such issue has bene fixed in 13.2, we're containing the custom behavior to the broken release.
///
/// Whenever this method returns *true*, link interactions will be passed along via the `textView:receivedInteractionWithURL:` delegate method.
///
/// Ref.: https://github.com/Automattic/simplenote-ios/pull/470
///
- (BOOL)performsAggressiveLinkWorkaround;

@end
