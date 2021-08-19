#import "SPInteractiveTextStorage.h"

NSString *const SPDefaultTokenName = @"SPDefaultTokenName";
NSString *const SPHeadlineTokenName = @"SPHeadlineTokenName";

@interface SPInteractiveTextStorage ()

@property (nonatomic, strong) NSMutableAttributedString *backingStore;
@property (nonatomic, assign) BOOL dynamicTextNeedsUpdate;

@end

@implementation SPInteractiveTextStorage

- (instancetype)init
{
    self = [super init];
    if (self) {
        _backingStore = [[NSMutableAttributedString alloc] init];
    }
    return self;
}

- (NSString *)string
{
    return [_backingStore string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [_backingStore attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [self beginEditing];

    // This fixes https://github.com/Automattic/simplenote-ios/issues/682
    // When undoing paste of text that includes AttributeText attachments (checkboxes)
    // the range count may be longer than the store length
    // causing a crash.  This corrects the length on the range
    if ((range.location + range.length) > _backingStore.length) {
        range.length = _backingStore.length - range.location;
    }

    [_backingStore replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters|NSTextStorageEditedAttributes range:range changeInLength:str.length - range.length];
    _dynamicTextNeedsUpdate = YES;
    [self endEditing];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [self beginEditing];
    [_backingStore setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

- (void)addAttribute:(NSString *)name value:(id)value range:(NSRange)range
{
    [_backingStore addAttribute:name value:value range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (void)performReplacementsForCharacterChangeInRange:(NSRange)changedRange
{
    NSString *rawString     = _backingStore.string;
    NSRange extendedRange   = NSUnionRange(changedRange, [rawString lineRangeForRange:NSMakeRange(NSMaxRange(changedRange), 0)]);

    [self applyTokenAttributesToRange:extendedRange];
}

- (void)processEditing
{
    if(_dynamicTextNeedsUpdate)
    {
        _dynamicTextNeedsUpdate = NO;
        [self performReplacementsForCharacterChangeInRange:[self editedRange]];
    }
    [super processEditing];
}

- (void)applyTokenAttributesToRange:(NSRange)searchRange {
    
    if (!self.defaultStyle || !self.headlineStyle) {
        return;
    }

    // If the range contains the first line, make sure to set the header's attribute
    if (searchRange.location == 0) {
        NSString *rawString = _backingStore.string;
        NSRange firstLineRange = [rawString lineRangeForRange:NSMakeRange(0, 0)];
        [self addAttributes:self.headlineStyle range:firstLineRange];
        
        NSRange remainingRange = NSMakeRange(firstLineRange.location + firstLineRange.length, searchRange.length - firstLineRange.length);
        if (remainingRange.location < rawString.length && remainingRange.length <= rawString.length) {
            [self addAttributes:self.defaultStyle range:remainingRange];
        }
    } else {
        [self addAttributes:self.defaultStyle range:searchRange];
    }
}

@end

