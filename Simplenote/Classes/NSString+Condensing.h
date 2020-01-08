
@interface NSString (Condensing)

// Generates string with fewer whitespaces and special characters. Good for previews in UITableViews
- (void)generatePreviewStrings:(void (^)(NSString *titlePreview, NSString *bodyPreview, NSString *contentPreview))block;

@end
