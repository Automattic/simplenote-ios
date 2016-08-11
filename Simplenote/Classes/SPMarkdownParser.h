//
//  SPMarkdownParser.h
//  Simplenote
//
//  Created by James Frost on 01/10/2015.
//  Copyright © 2015 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @class      SPMarkdownParser
 *  @brief      This is a simple wrapper around the 'hoedown' Markdown parser, 
 *              which produces HTML from a Markdown input string.
 */
@interface SPMarkdownParser : NSObject

+ (NSString *)renderHTMLFromMarkdownString:(NSString *)markdown;

@end
