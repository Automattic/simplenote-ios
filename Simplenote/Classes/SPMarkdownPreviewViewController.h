//
//  SPMarkdownPreviewViewController.h
//  Simplenote
//
//  Created by James Frost on 01/10/2015.
//  Copyright © 2015 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPInteractivePushPopAnimationController.h"


/**
 *  @class      SPMarkdownPreviewViewController
 *  @brief      Displays Markdown text rendered as HTML in a web view.
 */
@interface SPMarkdownPreviewViewController : UIViewController <SPInteractivePushViewControllerContent>

/// Markdown text to render as HTML
@property (nonatomic, copy) NSString *markdownText;

@end
