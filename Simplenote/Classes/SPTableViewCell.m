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
        self.contentView.clipsToBounds = NO;
        
        // setup preview view
        CGRect frame = self.bounds;
        
        _previewView = [[SPTextView alloc] init];
        _previewView.frame = [self previewViewRectForWidth:frame.size.width
                                                     fast:YES];
        
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
        self.accessoryView = _accessoryImageView;

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
    [self resizeAccessoryImageView:accessoryImage.size];
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

- (void)resizeAccessoryImageView:(CGSize)newSize {
    CGRect frame = _accessoryImageView.frame;
    frame.size = newSize;
    _accessoryImageView.frame = frame;
}

- (void)applyStyle {
    
    VSTheme *theme = [[VSThemeManager sharedManager] theme];

    self.backgroundColor = [theme colorForKey:@"backgroundColor"];
    self.contentView.backgroundColor = [theme colorForKey:@"backgroundColor"];
    
    // set selection view
    UIView *selectionView = [[UIView alloc] initWithFrame:self.bounds];
    selectionView.backgroundColor = [theme colorForKey:@"noteCellBackgroundSelectionColor"];
    self.selectedBackgroundView = selectionView;
    
    _previewView.backgroundColor = [theme colorForKey:@"backgroundColor"];
    
    NSDictionary *defaultAttributes = @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
                                        NSForegroundColorAttributeName:[theme colorForKey:@"noteBodyFontPreviewColor"]};
    
    NSDictionary *headlineAttributes = @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline],
                                         NSForegroundColorAttributeName: [theme colorForKey:@"noteHeadlineFontColor"]};
    
    _previewView.interactiveTextStorage.tokens = @{SPDefaultTokenName : defaultAttributes,
                                                   SPHeadlineTokenName : headlineAttributes
                                                   };
    
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if ([UIDevice isPad]) {
        CGRect frame = self.bounds;
        
        if (_previewView) {
            _previewView.frame = [self previewViewRectForWidth:frame.size.width fast:YES];
        }
        self.contentView.frame = frame;
    }
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
    if (maxWidth > 0 && previewWidth > maxWidth)
        previewWidth = maxWidth;
    
    CGFloat height;
    if (fast)
        height = self.bounds.size.height - verticalPadding;
    else
        height = [_previewView sizeThatFits:CGSizeMake(previewWidth, CGFLOAT_MAX)].height;
    
    
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
