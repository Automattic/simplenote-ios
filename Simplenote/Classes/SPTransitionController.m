#import "Simplenote-Swift.h"

#import "SPTransitionController.h"
#import "SPMarkdownPreviewViewController.h"
#import "SPInteractivePushPopAnimationController.h"


NSString *const SPTransitionControllerPopGestureTriggeredNotificationName = @"SPTransitionControllerPopGestureTriggeredNotificationName";


#pragma mark - Private Properties

@interface SPTransitionController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) SPInteractivePushPopAnimationController   *pushPopAnimationController;
@property (nonatomic,   weak) UINavigationController                    *navigationController;
@end


@implementation SPTransitionController

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController
{
    self = [super init];
    if (self) {
        if ([UIDevice isPad]) {
            UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(handlePinch:)];
            [navigationController.view addGestureRecognizer:pinchGesture];
        }

        // Note:
        // This is required since NoteEditorViewController has a custom TitleView, which causes the
        // interactivePopGestureRecognizer to stop working on its own!
        UIGestureRecognizer *interactivePopGestureRecognizer = navigationController.interactivePopGestureRecognizer;
        [interactivePopGestureRecognizer addTarget:self action:@selector(handlePan:)];
        interactivePopGestureRecognizer.delegate = self;

        self.pushPopAnimationController = [[SPInteractivePushPopAnimationController alloc] initWithNavigationController:navigationController];
        self.navigationController = navigationController;
    }

    return self;
}


#pragma mark - UINavigationControllerDelegate


- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    BOOL navigatingToMarkdownPreview = [fromVC isKindOfClass:[SPMarkdownPreviewViewController class]];
    if (!navigatingToMarkdownPreview) {
        return nil;
    }

    self.pushPopAnimationController.navigationOperation = operation;
    return self.pushPopAnimationController;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController
{
    if (animationController != self.pushPopAnimationController) {
        return nil;
    }

    return self.pushPopAnimationController.interactiveTransition;
}

//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    printf("view did show");
//}
//
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"SPNavigationControllerDidChangeView" object:nil];
//}

#pragma mark - Gesture Recognizers

- (void)handlePan:(UIPanGestureRecognizer *)sender
{
    // By the time this method is called, the existing topViewController has been popped –
    // so topViewController contains the view we are transitioning *to*.
    // We only want to handle the Editor > List transition with a custom transition, so if
    // there's anything other than the List view on the top of the stack, we'll let the OS handle it.
    BOOL isTransitioningToList = [self.navigationController.topViewController isKindOfClass:[SPNoteListViewController class]];
    if (isTransitioningToList && sender.state == UIGestureRecognizerStateBegan) {
        [self postPopGestureNotification];
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer*)sender
{
    if (sender.numberOfTouches >= 2 && // require two fingers
        sender.scale < 1.0 && // pinch in
        sender.state == UIGestureRecognizerStateBegan) {

        [self postPopGestureNotification];
    }
}

- (void)postPopGestureNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SPTransitionControllerPopGestureTriggeredNotificationName
                                                        object:self];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer != self.navigationController.interactivePopGestureRecognizer) {
        return YES;
    }


    BOOL recognizerShouldBegin = self.navigationController.viewControllers.count > 1;
    if (recognizerShouldBegin) {
        [self bypassFirstResponderRestorationIfNeeded];
    }

    return recognizerShouldBegin;
}

- (void)bypassFirstResponderRestorationIfNeeded
{
    UIViewController<SPInteractiveDismissableViewController> *dismissableViewController = (UIViewController<SPInteractiveDismissableViewController> *)self.navigationController.topViewController;
    if (![dismissableViewController conformsToProtocol:@protocol(SPInteractiveDismissableViewController)]) {
        return;
    }

    if (!dismissableViewController.requiresFirstResponderRestorationBypass) {
        return;
    }

    [dismissableViewController.view endEditing:YES];
}

@end
