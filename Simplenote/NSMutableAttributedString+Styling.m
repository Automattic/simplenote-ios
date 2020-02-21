#import "NSMutableAttributedString+Styling.h"
#import "NSString+Bullets.h"
#import "Simplenote-Swift.h"



@implementation NSMutableAttributedString (Checklists)

- (void)processChecklistsWithColor:(UIColor *)color allowsMultiplePerLine:(BOOL)allowsMultiplePerLine
{
    CGFloat dimension = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize + 4;
    UIOffset offset = UIOffsetMake(0.0, -4.5);

    [self processChecklistsWithColor:color dimension:dimension offset:offset allowsMultiplePerLine:allowsMultiplePerLine];
}

- (void)processChecklistsWithColor:(UIColor *)color
                         dimension:(CGFloat)dimension
                            offset:(UIOffset)offset
             allowsMultiplePerLine:(BOOL)allowsMultiplePerLine
{
    if (self.length == 0) {
        return;
    }

    NSString *plainString = self.string.copy;
    NSRegularExpression *regex = allowsMultiplePerLine ? NSRegularExpression.regexForChecklistsEmbeddedAnywhere : NSRegularExpression.regexForChecklists;
    NSArray *matches = [regex matchesInString:plainString options:0 range:plainString.rangeOfEntireString];
    NSInteger positionAdjustment = 0;
    BOOL shouldPrependSpace = NO;

    for (NSTextCheckingResult *match in matches) {
        NSRange matchedRange = match.range;
        if (matchedRange.location == NSNotFound) {
            continue;
        }

        NSRange adjustedRange = NSMakeRange(matchedRange.location - positionAdjustment, matchedRange.length);
        if (NSMaxRange(adjustedRange) > self.length) {
            continue;
        }

        NSString *prefix = [plainString substringWithRange:matchedRange];
        BOOL isChecked = [prefix localizedCaseInsensitiveContainsString:@"x"];

        SPTextAttachment *textAttachment = [SPTextAttachment new];
        textAttachment.isChecked = isChecked;
        textAttachment.tintColor = color;
        textAttachment.bounds = CGRectMake(offset.horizontal, offset.vertical, dimension, dimension);

        NSMutableAttributedString *attachmentString = [NSMutableAttributedString new];
        if (shouldPrependSpace) {
            [attachmentString appendString:NSString.spaceString];
        }

        [attachmentString appendAttachment:textAttachment];

        [self replaceCharactersInRange:adjustedRange withAttributedString:attachmentString];

        positionAdjustment += matchedRange.length - attachmentString.length;
        shouldPrependSpace = allowsMultiplePerLine;
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
