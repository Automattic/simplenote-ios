//
//  SPTextLinkifier.h
//  Simplenote
//
//  Created by Jorge Leandro Perez on 08/27/15.
//  Copyright (c) 2015 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  @class      SPTextLinkifier
 *  @brief      The purpose of this class is to handle Text Linkification for a given UITextView Instance.
 *              We need to do this, by hand, since UITextView's Data Detectors (as per iOS 9) have an
 *              extremely poor performance when dealing with huge documents, full of links.
 *  @details    The "Optimized" Linkifier algorithm has two missing features: Dates and Events are not
 *              currently supported.
 *              For that reason, we'll dynamically switch from Optimized vs Native, based on the document's length.
 */

@interface SPTextLinkifier : NSObject

@property (nonatomic, strong,  readonly) UITextView *textView;
@property (nonatomic, assign, readwrite) BOOL       enabled;

/**
 *  @details    Returns a new Linkifier Instance
 *  @param      textView    The TextView that requires Linkification Services.
 *  @returns                The new Text Linkifier Instance.
 */
+ (SPTextLinkifier *)linkifierWithTextView:(UITextView *)textView;


/**
 *  @details    This method should be called whenever the UITextView's scrollViewDidEndDecelerating: delegate 
 *              method is executed. It's main purpose is to linkify the visible text, after scrolling has concluded.
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;


/**
 *  @details    This method should be called whenever the UITextView's scrollViewDidEndDragging:willDecelerate
 *              method is executed. It's main purpose is to linkify the visible text, after scrolling has concluded.
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end
