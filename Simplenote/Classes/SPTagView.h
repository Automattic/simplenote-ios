//
//  SPTagView.h
//  Simplenote
//
//  Created by Tom Witkin on 7/17/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPTagEntryField.h"


@class SPTagView;
@protocol SPTagViewDelegate <NSObject>

@required

- (BOOL)tagView:(SPTagView *)tagView shouldCreateTagName:(NSString *)tagName;
- (void)tagView:(SPTagView *)tagView didCreateTagName:(NSString *)tagName;
- (void)tagView:(SPTagView *)tagView didRemoveTagName:(NSString *)tagName;

@optional

- (void)tagViewWillBeginEditing:(SPTagView *)tagView;
- (void)tagViewDidBeginEditing:(SPTagView *)tagView;
- (void)tagViewDidEndEditing:(SPTagView *)tagView;
- (void)tagViewDidChange:(SPTagView *)tagView;

@end

@interface SPTagView : UIView <SPTagEntryFieldDelegate, UIScrollViewDelegate, UITextFieldDelegate> {
    
    UIScrollView *tagScrollView;
    UIScrollView *autoCompleteScrollView;
    
    SPTagEntryField *addTagField;
        
    NSMutableArray *tagPills;
    NSArray *tagCompletionPills;
}

@property (nonatomic, weak) id<SPTagViewDelegate> tagDelegate;
@property (nonatomic, assign) UIKeyboardAppearance keyboardAppearance;

- (void)scrollEntryFieldToVisible:(BOOL)animated;
- (void)clearAllTags;
- (BOOL)setupWithTagNames:(NSArray *)tagNames;
- (void)applyStyle;

@end
