//
//  SPMarkdownParser.m
//  Simplenote
//
//  Created by James Frost on 01/10/2015.
//  Copyright © 2015 Automattic. All rights reserved.
//

#import "SPMarkdownParser.h"
#import <hoedown/html.h>
#import "VSTheme+Simplenote.h"
#import "VSThemeManager.h"

@implementation SPMarkdownParser

+ (NSString *)renderHTMLFromMarkdownString:(NSString *)markdown
{
    hoedown_renderer *renderer = hoedown_html_renderer_new(HOEDOWN_HTML_SKIP_HTML, 0);
    hoedown_document *document = hoedown_document_new(renderer, HOEDOWN_EXT_AUTOLINK | HOEDOWN_EXT_FENCED_CODE | HOEDOWN_EXT_FOOTNOTES, 16);
    hoedown_buffer *html = hoedown_buffer_new(16);
    
    NSData *markdownData = [markdown dataUsingEncoding:NSUTF8StringEncoding];
    hoedown_document_render(document, html, markdownData.bytes, markdownData.length);
    
    NSData *htmlData = [NSData dataWithBytes:html->data length:html->size];
    
    hoedown_buffer_free(html);
    hoedown_document_free(document);
    hoedown_html_renderer_free(renderer);
    
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];

    return [[[self htmlHeader] stringByAppendingString:htmlString] stringByAppendingString:[self htmlFooter]];
}

+ (NSString *)htmlHeader
{
    NSString *headerStart =
        @"<html><head>"
            "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
            "<link href=\"https://fonts.googleapis.com/css?family=Noto+Serif\" rel=\"stylesheet\">"
            "<style media=\"screen\" type=\"text/css\">\n";
    NSString *headerEnd = @"</style></head><body><div class=\"note-detail-markdown\">";
    
    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    NSString *path = [self cssPathForTheme:theme];
    
    NSString *css = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:path withExtension:nil]
                                             encoding:NSUTF8StringEncoding error:nil];
    
    return [[headerStart stringByAppendingString:css] stringByAppendingString:headerEnd];
}

+ (NSString *)cssPathForTheme:(VSTheme *)theme
{
    if (theme.isDark) {
        return @"markdown-dark.css";
    } else {
        return @"markdown-default.css";
    }
}

+ (NSString *)htmlFooter
{
    return @"</div></body></html>";
}

@end
