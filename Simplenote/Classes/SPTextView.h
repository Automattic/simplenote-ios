//
//  SPTextView.h
//  Simplenote
//
//  Created by Tom Witkin on 7/19/13.
//  Created by Michael Johnston on 7/19/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SPInteractiveTextStorage;

@interface SPTextView : UITextView {
    NSMutableArray *highlightViews;
}

@property (nonatomic, retain, nonnull) SPInteractiveTextStorage *interactiveTextStorage;

- (void)highlightSubstringsMatching:(NSString * _Nonnull)keywords color:(UIColor * _Nonnull)color;
- (void)highlightRange:(NSRange)range animated:(BOOL)animated withBlock:(void (^_Nonnull)(CGRect highlightFrame))block;
- (void)clearHighlights:(BOOL)animated;

@end

