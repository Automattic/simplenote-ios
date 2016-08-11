//
//  SPTextLinkifier.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 08/27/15.
//  Copyright (c) 2015 Automattic. All rights reserved.
//

#import "SPTextLinkifier.h"
#import "UITextView+Simplenote.h"



#pragma mark - Constants

static const NSTextCheckingType SPLinkifierSupportedTypes   = NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber;
static const NSString *SPLinkifierAttributedTextKeyPath     = @"attributedText";
static const NSString *SPLinkifierTextKeyPath               = @"text";
static const NSString *SPLinkifierContentOffsetKeyPath      = @"contentOffset";
static const NSInteger SPLinkifierManualDetectionThreshold  = 5 * 1024;

//#define SPTextLinkifierDebug true


#pragma mark - Notes

/**
                      Switch Detectors    Linkify       Unlinkify

    Linkify Enabled                       x
    Linkify Disabled                                    x

    Edition Begin                                       x
    Edition Ends          x

    Text Replaced         x
    Scrolled                                            x
*/



#pragma mark - Private

@interface SPTextLinkifier ()
@property (nonatomic, strong) UITextView        *textView;
@property (nonatomic, strong) NSDataDetector    *dataDetector;
@property (nonatomic, strong) NSCharacterSet    *nonDecimalCharacterSet;
@property (nonatomic, assign) BOOL              optimizedLinkifierEnabled;
@end



#pragma mark - SPTextLinkifier

@implementation SPTextLinkifier

- (void)dealloc
{
    [self stopListeningToNotifications:_textView];
}

- (instancetype)initWithTextView:(UITextView *)textView
{
    NSParameterAssert(textView);
    
    if (self = [super init]) {
        _textView               = textView;
        _enabled                = YES;
        _dataDetector           = [[NSDataDetector alloc] initWithTypes:SPLinkifierSupportedTypes error:nil];
        _nonDecimalCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];

        [self startListeningToNotifications:textView];
    }
    
    return self;
}



#pragma mark - Static Helpers

+ (SPTextLinkifier *)linkifierWithTextView:(UITextView *)textView
{
    return [[SPTextLinkifier alloc] initWithTextView:textView];
}



# pragma mark - Notification Helpers

- (void)startListeningToNotifications:(UITextView *)textView
{
    NSParameterAssert(textView);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewDidBeginEditing:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:textView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewDidEndEditing:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:textView];

    for (NSString *keyPath in self.observedKeyPaths) {
        [textView addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)stopListeningToNotifications:(UITextView *)textView
{
    NSParameterAssert(textView);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    for (NSString *keyPath in self.observedKeyPaths) {
        [textView removeObserver:self forKeyPath:keyPath];
    }
}

- (NSArray *)observedKeyPaths
{
    return @[SPLinkifierAttributedTextKeyPath, SPLinkifierTextKeyPath];
}


#pragma mark - Properties

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    
    if (enabled) {
        [self linkifyVisibleText];
    } else {
        [self unlinkifyText];
    }
}



#pragma mark - Public Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSAssert(scrollView == self.textView, @"This ScrollView Event is not expected by the Linkifier");
    
#ifdef SPTextLinkifierDebug
    NSLog(@"### SPTextLinkifier: [%@]", NSStringFromSelector(_cmd));
#endif
    
    [self linkifyVisibleTextIfNeeded];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSAssert(scrollView == self.textView, @"This ScrollView Event is not expected by the Linkifier");
    
#ifdef SPTextLinkifierDebug
    NSLog(@"### SPTextLinkifier: [%@] decelerate [%d]", NSStringFromSelector(_cmd), decelerate);
#endif
    
    // If the ScrollView will still animate, let the 'didEndDecelerating' callback deal with the linkify.
    // Let's keep a smooth Scroll UX
    if (decelerate) {
        return;
    }
    
    [self linkifyVisibleTextIfNeeded];
}


#pragma mark - Notification Handlers

- (void)textViewDidBeginEditing:(NSNotification *)note
{
    // Note: Since iOS itself disables 'Native' Data Detectors, automatically, during edition, we'll only deal
    // with the Optimized Linkifier here
    if (self.optimizedLinkifierEnabled) {
        [self optimizedUnlinkifyText];
    }
}

- (void)textViewDidEndEditing:(NSNotification *)note
{
    [self switchLinkifierIfNeeded];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
#ifdef SPTextLinkifierDebug
    NSLog(@"### SPTextLinkifier: Changed [%@] FirstResponder [%d]", keyPath, _textView.isFirstResponder);
#endif
    
    // Failsafe: This might get called during Edition. Bypass, if so.
    if (self.textView.isFirstResponder) {
        return;
    }
    
    if ([keyPath isEqual:SPLinkifierAttributedTextKeyPath] || [keyPath isEqual:SPLinkifierTextKeyPath]) {
        [self switchLinkifierIfNeeded];
    }
}

- (void)switchLinkifierIfNeeded
{
    // Length >= 5kb: Optimize Linkification Process
    self.optimizedLinkifierEnabled = self.textView.text.length >= SPLinkifierManualDetectionThreshold;
    
#ifdef SPTextLinkifierDebug
    if (_optimizedLinkifierEnabled) {
        NSLog(@"### SPTextLinkifier: Optimized Linkifier Mode");
    } else {
        NSLog(@"### SPTextLinkifier: Native Linkifier Mode");
    }
#endif
    
    // Switch: Make sure the old Linkifier removes its attributes
    if (self.optimizedLinkifierEnabled) {
        [self nativeUnlinkifyText];
        [self optimizedLinkifyVisibleText];
    } else {
        [self optimizedUnlinkifyText];
        [self nativeLinkifyText];
    }
}



#pragma mark - Linkifier Helpers

- (void)linkifyVisibleTextIfNeeded
{
    if (!self.textView.isFirstResponder) {
        [self linkifyVisibleText];
    }
}

- (void)linkifyVisibleText
{
    if (self.optimizedLinkifierEnabled) {
        [self optimizedLinkifyVisibleText];
    } else {
        [self nativeLinkifyText];
    }
}

- (void)unlinkifyText
{
    if (self.optimizedLinkifierEnabled) {
        [self optimizedUnlinkifyText];
    } else {
        [self nativeUnlinkifyText];
    }
}



#pragma mark - Native Linkifier

- (void)nativeLinkifyText
{
    self.textView.dataDetectorTypes = UIDataDetectorTypeAll;
}

- (void)nativeUnlinkifyText
{
    self.textView.dataDetectorTypes = UIDataDetectorTypeNone;
}



#pragma mark - Optimized Linkifier

- (void)optimizedLinkifyVisibleText
{
#ifdef SPTextLinkifierDebug
    NSDate *begin = [NSDate date];
#endif
    
    // Helpers
    NSTextStorage *textStorage      = self.textView.textStorage;
    NSRange visibleRange            = [self.textView visibleTextRange];
    NSString *visibleString         = [textStorage.string substringWithRange:visibleRange];
    NSRange range                   = NSMakeRange(0, visibleString.length);
    
    // Detect Attributed Ranges
    NSMutableDictionary *linksMap   = [NSMutableDictionary dictionary];
    
    [self.dataDetector enumerateMatchesInString:visibleString
                                        options:0
                                          range:range
                                     usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
     {
         NSRange correctedRange = result.range;
         correctedRange.location += visibleRange.location;
        
         NSValue *wrappedRange = [NSValue valueWithRange:correctedRange];
        
         switch (result.resultType) {
            case NSTextCheckingTypeLink:
                {
                    if (result.URL) {
                        linksMap[wrappedRange] = result.URL;
                    }
                    break;
                }
            case NSTextCheckingTypePhoneNumber:
                {
                    NSArray *phoneDigits    = [result.phoneNumber componentsSeparatedByCharactersInSet:self.nonDecimalCharacterSet];
                    NSString *phoneNumber   = [phoneDigits componentsJoinedByString:[NSString string]];
                    NSString *wrappedPhone  = [NSString stringWithFormat:@"tel:%@", phoneNumber];
                    NSURL *phoneURL         = [NSURL URLWithString:wrappedPhone];
                    
                    if (phoneURL != nil) {
                        linksMap[wrappedRange] = phoneURL;
                    }
                    break;
                }
            default:
                {
                    break;
                }
         }
    }];
    
    
#ifdef SPTextLinkifierDebug
    NSLog(@"### SPTextLinkifier: Detectors Delta [%f]", begin.timeIntervalSinceNow);
#endif
    
    // Apply all of the detected Links in a single loop (++performance++)!!
    [textStorage beginEditing];
    
    for (NSValue *rangeValue in linksMap.allKeys) {
        NSURL *targetURL = linksMap[rangeValue];
        
        [textStorage addAttribute:NSLinkAttributeName value:targetURL range:rangeValue.rangeValue];
    }
    
    [textStorage endEditing];
    
#ifdef SPTextLinkifierDebug
    NSLog(@"### SPTextLinkifier: Link Count [%ld] Styles Delta [%f]", linksMap.count, begin.timeIntervalSinceNow);
#endif
}

- (void)optimizedUnlinkifyText
{
    NSTextStorage *textStorage  = self.textView.textStorage;
    NSRange range               = NSMakeRange(0, textStorage.string.length);
    
    [textStorage removeAttribute:NSLinkAttributeName range:range];
}

@end
