#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Condensing)

/// Returns a version of the receiver with all of its newlines replaced with spaces.
///
/// -   Note: Multiple consecutive newlines will be replaced by a *single* space
///
- (NSString *)stringByReplacingNewlinesWithSpaces;

@end

NS_ASSUME_NONNULL_END
