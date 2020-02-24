#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (Checklists)

/// Replaces Checklist Markers with a SPTextAttachment at the exact same location.
///
/// @param color: Tinting Color to be applied over the Image
/// @param sizingFont: Font that should be used to determine the Attachment Size
/// @param allowsMultiplePerLine: When **YES** we'll support multiple Checklists Image in the same line. Useful for the Notes List.
///
/// @Discussion
/// When Multiple Lines are allowed, we'll prepend a space to any attachment that's not at location Zero. Otherwise notes that look like
/// the following, will definitely look bad: the Checklist Image would end up by the preceding word, without spacing.
///
///  `Word -[ ] Item - [ ] Item - [ ] Item`
///
/// @Note
/// We're expecting a sizingFont because in the NotesList a UILabel is used (which lacks the full TextKit Stack),
/// which makes it impossible to determine the current Font, from within the NSTextAttachment instance.
///
- (void)processChecklistsWithColor:(UIColor *)color
                        sizingFont:(UIFont *)sizingFont
             allowsMultiplePerLine:(BOOL)allowsMultiplePerLine;

@end

NS_ASSUME_NONNULL_END
