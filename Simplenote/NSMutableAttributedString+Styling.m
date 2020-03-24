#import "NSMutableAttributedString+Styling.h"
#import "NSString+Bullets.h"
#import "Simplenote-Swift.h"


// Note: Capture Group Mark I: We're only interested in replacing the `- [ ]` marker, not the leading spaces
//
static NSUInteger const ListRangeIndex = 1;


@implementation NSMutableAttributedString (Checklists)

- (void)processChecklistsWithColor:(UIColor *)color
                        sizingFont:(UIFont *)sizingFont
             allowsMultiplePerLine:(BOOL)allowsMultiplePerLine
{
    if (self.length == 0) {
        return;
    }

    NSString *plainString = [self.string copy];
    NSRegularExpression *regex = allowsMultiplePerLine ? NSRegularExpression.regexForChecklistsEmbeddedAnywhere : NSRegularExpression.regexForChecklists;
    NSArray *matches = [[[regex matchesInString:plainString
                                        options:0
                                          range:plainString.fullRange] reverseObjectEnumerator] allObjects];

    for (NSTextCheckingResult *match in matches) {
        if (ListRangeIndex >= match.numberOfRanges) {
            continue;
        }

        NSRange matchedRange = [match rangeAtIndex:ListRangeIndex];
        if (matchedRange.location == NSNotFound || NSMaxRange(matchedRange) > self.length) {
            continue;
        }

        NSString *matchedString = [plainString substringWithRange:matchedRange];
        BOOL isChecked = [matchedString localizedCaseInsensitiveContainsString:@"x"];

        SPTextAttachment *textAttachment = [SPTextAttachment new];
        textAttachment.isChecked = isChecked;
        textAttachment.tintColor = color;
        textAttachment.sizingFont = sizingFont;

        NSMutableAttributedString *attachmentString = [NSMutableAttributedString new];
        if (allowsMultiplePerLine && matchedRange.location != 0) {
            [attachmentString appendString:NSString.spaceString];
        }

        [attachmentString appendAttachment:textAttachment];

        [self replaceCharactersInRange:matchedRange withAttributedString:attachmentString];
    }
}

- (void)appendAttachment:(NSTextAttachment *)attachment
{
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attachment];
    [self appendAttributedString:string];
}

- (void)appendString:(NSString *)aString
{
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:aString];
    [self appendAttributedString:string];
}

@end
