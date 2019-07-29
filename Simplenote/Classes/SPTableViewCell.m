//
//  SPCollectionViewCell.m
//  Simplenote
//
//  Created by Tom Witkin on 7/3/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPTableViewCell.h"
#import "Note.h"
#import "UIView+ImageRepresentation.h"
#import "SPAppDelegate.h"
#import "NSString+Condensing.h"
#import "VSThemeManager.h"
#import "SPTextView.h"
#import "SPOptionsViewController.h"
#import "SPInteractiveTextStorage.h"
#import "UIDevice+Extensions.h"
#import "VSTheme+Extensions.h"
#import "SPNotifications.h"
#import "Simplenote-Swift.h"



static CGFloat const kAccessoryImagePaddingLeft = 16;


@interface SPTableViewCell ()
@property (nonatomic, strong) UIImageView *accessoryImageView;
@end


@implementation SPTableViewCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.clipsToBounds = YES;
        self.contentView.clipsToBounds = YES;

        // setup preview view
        CGRect frame = self.bounds;
        
        _previewView = [[SPTextView alloc] init];
        _previewView.frame = [self previewViewRectForWidth:frame.size.width fast:YES];
        
        _previewView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _previewView.scrollEnabled = NO;
        _previewView.userInteractionEnabled = NO;
        _previewView.editable = NO;
        _previewView.textContainer.maximumNumberOfLines = [self numberOfPreviewLines];
        _previewView.textContainer.lineFragmentPadding = 0;
        _previewView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        _previewView.isAccessibilityElement = NO;
        _previewView.clipsToBounds = NO;
        [self.contentView addSubview:_previewView];

        _accessoryImageView = [UIImageView new];
        _accessoryImageView.contentMode = UIViewContentModeCenter;

        // Believe me: Using the cell's accessoryView is a nightmare. iPhone Xs Max and iPad has different metrics.
        // This way we're avoiding magic numbers, and hacked positions.
        [_previewView addSubview:_accessoryImageView];

        [self applyStyle];
        
        // add notification for condensed view
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateNumberOfLines)
                                                     name:SPCondensedNoteListPreferenceChangedNotification
                                                   object:nil];
    }
    return self;
    
}

- (void)setAccessoryImage:(UIImage *)accessoryImage {
    _accessoryImageView.image = accessoryImage;
    [_accessoryImageView sizeToFit];
    [self adjustTextViewInsets];
}

- (UIImage*)accessoryImage {
    return _accessoryImageView.image;
}

- (UIColor *)accessoryTintColor {
    return _accessoryImageView.tintColor;
}

- (void)setAccessoryTintColor:(UIColor *)accessoryTintColor {
    _accessoryImageView.tintColor = accessoryTintColor;
}

- (void)adjustTextViewInsets {
    UIEdgeInsets previewInsets = _previewView.textContainerInset;
    previewInsets.right = _accessoryImageView.image.size.width + kAccessoryImagePaddingLeft;
    _previewView.textContainerInset = previewInsets;
}

- (void)applyStyle {
    UIColor *backgroundColor = [UIColor colorWithName:UIColorNameBackgroundColor];

    self.backgroundColor = backgroundColor;
    self.contentView.backgroundColor = backgroundColor;

    // set selection view
    UIView *selectionView = [[UIView alloc] initWithFrame:self.bounds];
    selectionView.backgroundColor = [UIColor colorWithName:UIColorNameNoteCellBackgroundSelectionColor];
    self.selectedBackgroundView = selectionView;

    _previewView.backgroundColor = backgroundColor;

    NSDictionary *defaultAttributes = @{
        NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
        NSForegroundColorAttributeName: [UIColor colorWithName:UIColorNameNoteBodyFontPreviewColor]
    };
    
    NSDictionary *headlineAttributes = @{
        NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline],
        NSForegroundColorAttributeName: [UIColor colorWithName:UIColorNameNoteHeadlineFontColor]
    };
    
    _previewView.interactiveTextStorage.tokens = @{SPDefaultTokenName : defaultAttributes,
                                                   SPHeadlineTokenName : headlineAttributes
                                                   };
}


- (void)layoutSubviews {

    [super layoutSubviews];

    /// We check if we're running on iPad devices because of its multitasking capabilities.
    /// We just cannot check if we're in Regular x Regular. WHY? because the user may resize the window,
    /// and we'll end up stuck with the wrong frame sizes!
    ///
    if ([UIDevice isPad]) {
        CGRect bounds = self.bounds;
        self.contentView.frame = bounds;
        _previewView.frame = [self previewViewRectForWidth:bounds.size.width fast:YES];
    }

    /// AccessoryView: Top Right Corner
    ///
    CGRect accessoryFrame = _accessoryImageView.frame;
    accessoryFrame.origin.x = CGRectGetWidth(_previewView.frame) - CGRectGetWidth(accessoryFrame);
    accessoryFrame.origin.y = CGRectGetHeight(accessoryFrame);
    _accessoryImageView.frame = accessoryFrame;
}

- (CGRect)listAnimationFrameForWidth:(CGFloat)width {
    return [self previewViewRectForWidth:width fast:NO];
}

- (CGRect)previewViewRectForWidth:(CGFloat)width fast:(BOOL)fast {
    
    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    
    // Fit preview label to text:
    // The text has a maximum width and side padding defined.
    CGFloat padding = [theme floatForKey:@"noteSidePadding" contextView:self];
    CGFloat maxWidth = [theme floatForKey:@"noteMaxWidth"];
    CGFloat verticalPadding = [theme floatForKey:@"noteVerticalPadding"];

    // calculate width of view based on max width
    CGFloat previewWidth = width - 2 * padding;
    if (maxWidth > 0 && previewWidth > maxWidth) {
        previewWidth = maxWidth;
    }

    CGFloat height;
    if (fast) {
        height = self.bounds.size.height - verticalPadding;
    }
    else {
        /// Note:
        /// We must consider the scenario in which there's an accessoryImageView being displayed, and its maximumY
        /// is effectively beyond the previewView's Height. This could cause an animation glitch, in which the
        /// accessoryImageView gets clipped.
        ///
        const CGFloat SPAccessoryImageViewPaddingBottom = 1;

        CGFloat previewHeight = [_previewView sizeThatFits:CGSizeMake(previewWidth, CGFLOAT_MAX)].height;
        CGFloat accessoryMaximumY = CGRectGetMaxY(_accessoryImageView.frame) + SPAccessoryImageViewPaddingBottom;

        height = MAX(previewHeight, accessoryMaximumY);
    }

    return CGRectMake((width - previewWidth) / 2.0,
                      verticalPadding,
                      previewWidth,
                      height + (fast ? 15.0 : 0.0));
}


- (void)updateNumberOfLines {
    
    _previewView.textContainer.maximumNumberOfLines = [self numberOfPreviewLines];
}

- (NSInteger)numberOfPreviewLines {
    
    BOOL condensed = [[NSUserDefaults standardUserDefaults] boolForKey:SPCondensedNoteListPref];
    
    return condensed ? 1 : 3;
}


@end
