#import "Simplenote-Swift.h"

#import "SPTransitionController.h"
#import "SPMarkdownPreviewViewController.h"
#import "UIDevice+Extensions.h"
#import "SPInteractivePushPopAnimationController.h"



#pragma mark - Constants

NSString *const SPTransitionControllerPopGestureTriggeredNotificationName = @"SPTransitionControllerPopGestureTriggeredNotificationName";


#pragma mark - Private Properties

@interface SPTransitionController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) SPInteractivePushPopAnimationController   *pushPopAnimationController;
@property (nonatomic, weak) UINavigationController                      *navigationController;

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


#pragma mark UINavigationControllerDelegate methods — Supporting Custom Transition Animations


- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    BOOL navigatingToMarkdownPreview= [toVC isKindOfClass:[SPNoteEditorViewController class]];
    if (!navigatingToMarkdownPreview) {
        return nil;
    }

    self.pushPopAnimationController.navigationOperation = operation;
    return self.pushPopAnimationController;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController
{
    return self.pushPopAnimationController.interactiveTransition;
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {

    // By the time this method is called, the existing topViewController has been popped –
    // so topViewController contains the view we are transitioning *to*.
    // We only want to handle the Editor > List transition with a custom transition, so if
    // there's anything other than the List view on the top of the stack, we'll let the OS handle it.
    BOOL isTransitioningToList = [self.navigationController.topViewController isKindOfClass:[SPNoteListViewController class]];
    
    if (isTransitioningToList && sender.state == UIGestureRecognizerStateBegan) {
        [self postPopGestureNotification];
    }
    
    return;
}

- (void)handlePinch:(UIPinchGestureRecognizer*)sender {

    if (sender.numberOfTouches >= 2 && // require two fingers
        sender.scale < 1.0 && // pinch in
        sender.state == UIGestureRecognizerStateBegan) {

        [self postPopGestureNotification];
    }
    
    return;
}

- (void)postPopGestureNotification {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SPTransitionControllerPopGestureTriggeredNotificationName
                                                        object:self];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer != self.navigationController.interactivePopGestureRecognizer) {
        return YES;
    }

    return self.navigationController.viewControllers.count > 1;
}

@end
