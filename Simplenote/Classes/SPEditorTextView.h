//
//  SPEditorTextView.h
//  Simplenote
//
//  Created by Tom Witkin on 8/16/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPTextView.h"
@class SPTagView;

extern NSString *const CheckListRegExPattern;

@protocol SPEditorTextViewDelegate <UITextViewDelegate>
- (void)textView:(UITextView *)textView receivedInteractionWithURL:(NSURL *)url;
@end


@interface SPEditorTextView : SPTextView

@property (nonatomic) BOOL editing;
@property (nonatomic) BOOL lockContentOffset;
@property (nonatomic) BOOL overideLockContentOffset;

@property (nonatomic, strong) SPTagView *tagView;

- (void)scrollToBottom;
- (void)scrollToTop;
- (void)processChecklists;
- (NSString *)getPlainTextContent;
- (void)insertOrRemoveChecklist;

@end
