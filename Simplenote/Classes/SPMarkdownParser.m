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
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
                                  @"\n\\s+- \\[(x|X|o|o| )\\]\\s+([^\n]+)" options:0 error:nil];
    
    NSString *withTodos = [regex stringByReplacingMatchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length]) withTemplate:@"<div><input type=\"checkbox\" onClick=\"javascript:bridge.sendRawMessageToiOS('todoClicked')\">$2</input></div>"];

    return [[[self htmlHeader] stringByAppendingString:withTodos] stringByAppendingString:[self htmlFooter]];
}

+ (NSString *)htmlHeader
{
    NSString *headerStart = @"<html><head>";
    NSString *headerStyle = @"<style media=\"screen\" type=\"text/css\">\n";
    NSString *headerEnd = @"</style></head><body><div class=\"note\"><div id=\"static_content\">";
    NSString *headerScript = @"<script>"
                              "function iOSNativeBridge(){"
                              "  this.sendRawMessageToiOS = function(message){"
                              "    console.log(\"Message string to iOS: [\" + message+ \"]\");"
                              "    var iframe = document.createElement(\"IFRAME\");"
                              "    iframe.setAttribute(\"src\", \"jscall://\" + message);"
                              "    document.documentElement.appendChild(iframe);"
                              "    iframe.parentNode.removeChild(iframe);"
                              "    iframe = null;"
                              "  };"
                              "}"
                              "</script>";

    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    NSString *path = [self cssPathForTheme:theme];
    
    NSString *css = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:path withExtension:nil]
                                             encoding:NSUTF8StringEncoding error:nil];
    
    return [[[[headerStart stringByAppendingString:headerScript] stringByAppendingString:headerStyle] stringByAppendingString:css] stringByAppendingString:headerEnd];
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
    return @"</div></div></body></html>";
}

@end
