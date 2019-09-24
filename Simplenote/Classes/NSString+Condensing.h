
@interface NSString (Condensing)

// Compresses characters in the given set into single spaces.
- (NSString *)stringByCondensingSet:(NSCharacterSet *)set;

// Generates string with fewer whitespaces and special characters. Good for previews in UITableViews
- (void)generatePreviewStrings:(void (^)(NSString *titlePreview, NSString *bodyPreview, NSString *contentPreview))block;

@end
