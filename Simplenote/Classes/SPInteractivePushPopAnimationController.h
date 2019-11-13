//
//  SPInteractivePushPopAnimationController.h
//  Simplenote
//
//  Created by James Frost on 08/10/2015.
//  Copyright © 2015 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPInteractivePushPopAnimationController;

@protocol SPInteractivePushViewControllerProvider <NSObject>
- (UIViewController *)nextViewControllerForInteractivePush;
- (BOOL)interactivePushPopAnimationControllerShouldBeginPush:(SPInteractivePushPopAnimationController *)controller touchPoint:(CGPoint)touchPoint;
- (void)interactivePushPopAnimationControllerWillBeginPush:(SPInteractivePushPopAnimationController *)controller;
@end

@protocol SPInteractivePushViewControllerContent <NSObject>
@end

/**
 *  @class      SPInteractivePushPopAnimationController
 *  @brief      Allows the user to pan horizontally anywhere within the note editor to present
 *              the Markdown preview (and swipe anywhere within the preview to return).
 */
@interface SPInteractivePushPopAnimationController : NSObject<UIViewControllerAnimatedTransitioning>

/// Interactive transition for use by a `UINavigationControllerDelegate`.
/// Currently used by `SPTransitionController` to make this animation interactive.
@property (nonatomic, strong, readonly) UIPercentDrivenInteractiveTransition *interactiveTransition;

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic) UINavigationControllerOperation navigationOperation;

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;

@end
