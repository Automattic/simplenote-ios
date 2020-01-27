#import "Simplenote-Swift.h"

#import "UIDevice+Extensions.h"
#import "SPTransitionController.h"
#import "SPMarkdownPreviewViewController.h"
#import "SPInteractivePushPopAnimationController.h"


#define kEditorTransitionOffset 8

/*
#pragma mark - Constants

static const CGFloat SPAnimationPushTableViewRowSelectionDuration = 0.55;
static const CGFloat SPAnimationPushTableViewRowSelectionDelay = 0.025;
static const CGFloat SPAnimationPushTableViewRowSelectionDamping = 1.0;

static const CGFloat SPAnimationPushTableViewRowDuration = 0.5;
static const CGFloat SPAnimationPushTableViewRowDamping = 0.6;
static const CGFloat SPAnimationPushTableViewRowVelocity = 8.0;

static const CGFloat SPAnimationPopTableViewRowSelectionDuration = 0.45;
static const CGFloat SPAnimationPopTableViewRowSelectionDamping = 1.0;
static const CGFloat SPAnimationPopTableViewRowSelectionVelocity = 7.0;

static const CGFloat SPAnimationPopTableViewRowDuration = 0.45;
static const CGFloat SPAnimationPopTableViewRowDamping = 1.0;
static const CGFloat SPAnimationPopTableViewRowVelocity = 0.6;

static const CGFloat SPAnimationEmptyStatePushDuration = 0.15;
static const CGFloat SPAnimationEmptyStatePopDuration = 0.4;
static const CGFloat SPAnimationDelayZero = 0.0;
*/

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

/*
#pragma mark UIViewControllerTransitioningDelegate methods — Supporting Custom Transition Animations

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    return self;
}
*/

#pragma mark UINavigationControllerDelegate methods — Supporting Custom Transition Animations


- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    
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

/*
#pragma mark CustomTransition

- (UIView *)textViewSnapshotForNote:(Note *)note
                              width:(CGFloat)width
                       searchString:(NSString *)searchString
                            preview:(BOOL)preview {

    CGFloat snapHeight = self.tableView.frame.size.height;
    if (@available(iOS 11.0, *)) {
        // Adjust the height of the transition preview for safeAreaInsets.
        // Fixes awkward looking transition at the bottom of the editor on iPhone X
        snapHeight -= self.tableView.safeAreaInsets.top + self.tableView.safeAreaInsets.bottom + kEditorTransitionOffset;
    }

    CGSize size = CGSizeMake(width, snapHeight);

    if (preview) {
        return [_renderer renderPreviewSnapshotFor:note size:size searchQuery:searchString];
    }

    return [_renderer renderEditorSnapshotFor:note size:size searchQuery:searchString];
}

- (CGFloat)listTextViewWidth {

    return CGRectGetWidth(self.tableView.frame);
}

- (CGFloat)editorTextViewWidthForWidth:(CGFloat)width {
    
    // set content insets on side
    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    
    CGFloat padding = [theme floatForKey:@"noteSidePadding" contextView:self.tableView];
    padding += self.tableView.safeAreaInsets.left;
    
    CGFloat maxWidth = [theme floatForKey:@"noteMaxWidth"];
    
    if (width - 2 * padding > maxWidth && maxWidth > 0) {
        padding = (width - maxWidth) / 2.0;
    }
    
    return width - 2 * padding;
}

- (void)storeTransitionSnapshot:(SPTransitionSnapshot *)transitionSnapshot {
    
    if (transitionSnapshot) {
        
        [self incrementUseCount];
        [_temporaryTransitionViews addObject:transitionSnapshot];
    }
}
- (void)clearTransitionSnapshots {
    
    while (_temporaryTransitionViews.count > 0) {
        
        SPTransitionSnapshot *transitionSnapshot = _temporaryTransitionViews[0];
        [_temporaryTransitionViews removeObject:transitionSnapshot];
        
        [transitionSnapshot.snapshot removeFromSuperview];
        transitionSnapshot = nil;
    }
    
    _temporaryTransitionViews = nil;
}

- (void)setupTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    BOOL isPad = [UIDevice isPad];
    
    // perform initial setup for animations
    _context = transitionContext;
    self.percentComplete = 0.0;
    _transitioning = YES;
    [self clearTransitionSnapshots];
    _temporaryTransitionViews = [NSMutableArray arrayWithCapacity:10];

    UIViewController *toViewController = [_context viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [_context viewControllerForKey:UITransitionContextFromViewControllerKey];

    // WORKAROUND:
    // Rotation while the editor is onScreen causes the "To View Controller" to have a different frame size, and thus,
    // breaks awfully this animation
    //
    toViewController.view.frame = fromViewController.view.frame;
    
    SPNoteListViewController *listController;
    SPNoteEditorViewController *editorController;
    
    
    NSArray *visiblePaths = self.tableView.indexPathsForVisibleRows;
    
    UIView *containerView = [transitionContext containerView];
    
    fromViewController.view.alpha = 0.0;
    toViewController.view.alpha = 0.0;
    
    // List -> Editor transition
    if (toViewController.class == [SPNoteEditorViewController class] &&
        fromViewController.class == [SPNoteListViewController class]) {
        
        listController = (SPNoteListViewController *)fromViewController;
        editorController = (SPNoteEditorViewController *)toViewController;

        // animate empty list view
        
        if (!listController.emptyListView.hidden) {
            
            CGRect emptyListViewFrame = [containerView convertRect:listController.emptyListView.frame
                                                          fromView:listController.emptyListView.superview];
            
            UIView *emptyListViewSnapshot = [listController.emptyListView snapshotViewAfterScreenUpdates:NO];

            NSDictionary *emptyListViewAnimatedValues = [self animationValuesWithStartingFrame:emptyListViewFrame
                                                                                    finalFrame:emptyListViewFrame
                                                                                 startingAlpha:UIKitConstants.alphaFull
                                                                                    finalAlpha:UIKitConstants.alphaZero];

            NSDictionary *emptyListViewAnimationProperties = [self animationPropertiesWithDuration:SPAnimationEmptyStatePushDuration
                                                                                             delay:SPAnimationDelayZero
                                                                                           options:UIViewAnimationOptionCurveEaseInOut];

            SPTransitionSnapshot *emptyListViewTransitionSnapshot = [[SPTransitionSnapshot alloc] initWithSnapshot:emptyListViewSnapshot animatedValues:emptyListViewAnimatedValues animationProperties:emptyListViewAnimationProperties superView:containerView];
            emptyListViewTransitionSnapshot.springAnimation = NO;
            [self storeTransitionSnapshot:emptyListViewTransitionSnapshot];
        }
        
        // get snapshots of the final editor text

        CGFloat initialWidth = [self listTextViewWidth];
        CGFloat finalWidth = [self editorTextViewWidthForWidth:CGRectGetWidth(editorController.noteEditorTextView.frame)];

        UIView *cleanSnapshot = [self textViewSnapshotForNote:editorController.currentNote
                                                        width:initialWidth
                                                 searchString:editorController.searchString
                                                      preview:YES];
        
        UIView *dirtySnapshot = [self textViewSnapshotForNote:editorController.currentNote
                                                        width:finalWidth
                                                 searchString:editorController.searchString
                                                      preview:NO];
        

        UITextView *editorTextView = editorController.noteEditorTextView;
        CGRect finalEditorPosition = editorTextView.frame;
        finalEditorPosition.origin.x = 0;

        // We must tamper into the navigationBar frame directly, rather than safeAreaInsets.top.
        // Why? because the safeAreaInsets, the very first time this code runs, will not be set.
        //
        finalEditorPosition.origin.y += editorTextView.contentInset.top
                                            + editorTextView.textContainerInset.top
                                            + CGRectGetMaxY(editorController.navigationController.navigationBar.frame);
        finalEditorPosition.size.width = editorController.view.frame.size.width;
        
        if ([visiblePaths containsObject:_selectedPath]  || !_selectedPath) {
            
            
            for (NSIndexPath *path in visiblePaths) {
                
                
                SPNoteTableViewCell *cell = (SPNoteTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
                CGRect startingFrame = [containerView convertRect:cell.frame fromView:cell.superview];

                if (_selectedPath && path.row == _selectedPath.row) {
                    
                    // two snapshots are used for note content since the preview is a "clean" version of a note
                    cleanSnapshot.contentMode = UIViewContentModeTop;
                    cleanSnapshot.clipsToBounds = YES;
                    dirtySnapshot.contentMode = UIViewContentModeTop;
                    dirtySnapshot.clipsToBounds = YES;
                    
                    // calculate initial spring velocity based on location
                    // of cell in listController
                    CGFloat initialVelocity = MIN(9.0, 3.0 + (startingFrame.origin.y - finalEditorPosition.origin.y) / finalEditorPosition.size.height * 6.0);

                    NSDictionary *animationProperties = [self animationPropertiesWithDuration:SPAnimationPushTableViewRowSelectionDuration
                                                                                        delay:SPAnimationPushTableViewRowSelectionDelay
                                                                                springDamping:SPAnimationPushTableViewRowSelectionDamping
                                                                                     velocity:initialVelocity
                                                                                      options:UIViewAnimationOptionCurveEaseOut];

                    NSDictionary *cleanSnapshotAnimatedValues = [self animationValuesWithStartingFrame:startingFrame
                                                                                            finalFrame:finalEditorPosition
                                                                                         startingAlpha:UIKitConstants.alphaFull
                                                                                            finalAlpha:UIKitConstants.alphaZero];

                    SPTransitionSnapshot *cleanTransitionSnapshot = [[SPTransitionSnapshot alloc] initWithSnapshot:cleanSnapshot
                                                                                                    animatedValues:cleanSnapshotAnimatedValues
                                                                                               animationProperties:animationProperties
                                                                                                         superView:containerView];
                    [self storeTransitionSnapshot:cleanTransitionSnapshot];

                    NSDictionary *dirtySnapshotAnimatedValues = [self animationValuesWithStartingFrame:startingFrame
                                                                                            finalFrame:finalEditorPosition
                                                                                         startingAlpha:UIKitConstants.alphaZero
                                                                                            finalAlpha:UIKitConstants.alphaFull];

                    SPTransitionSnapshot *dirtyTransitionSnapshot = [[SPTransitionSnapshot alloc] initWithSnapshot:dirtySnapshot
                                                                                                    animatedValues:dirtySnapshotAnimatedValues
                                                                                               animationProperties:animationProperties
                                                                                                         superView:containerView];
                    [self storeTransitionSnapshot:dirtyTransitionSnapshot];
                    
                } else {
                    
                    UIView *snapshot = [cell snapshotViewAfterScreenUpdates:NO];
                    if (snapshot) {
                        
                        snapshot.contentMode = UIViewContentModeTop;
                        snapshot.clipsToBounds = YES;
                        
                        // calculate final position based on position from selected path
                        CGRect endingFrame = startingFrame;
                        CGFloat moveAmount = [UIDevice isPad] ? 1200 : 700;
                        
                        if (path.row < _selectedPath.row) {
                            moveAmount = moveAmount * -1;
                        }

                        endingFrame.origin.y += moveAmount;
                        
                        // add delay based on position to selected cell
                        CGFloat delay = MAX(0, 0.05 - ABS(_selectedPath.row - path.row) * 0.0125);

                        NSDictionary *animationProperties = [self animationPropertiesWithDuration:SPAnimationPushTableViewRowDuration
                                                                                            delay:delay
                                                                                    springDamping:SPAnimationPushTableViewRowDamping
                                                                                         velocity:SPAnimationPushTableViewRowVelocity
                                                                                          options:UIViewAnimationOptionCurveEaseInOut];

                        NSDictionary *animatedValues = [self animationValuesWithStartingFrame:startingFrame
                                                                                   finalFrame:endingFrame];

                        SPTransitionSnapshot *transitionSnapshot = [[SPTransitionSnapshot alloc] initWithSnapshot:snapshot
                                                                                                   animatedValues:animatedValues
                                                                                              animationProperties:animationProperties
                                                                                                        superView:containerView];
                        [self storeTransitionSnapshot:transitionSnapshot];
                    }
                }
            }
        }
        
        
        
    } else if (toViewController.class == [SPNoteListViewController class] &&
               fromViewController.class == [SPNoteEditorViewController class]) {
        
        listController = (SPNoteListViewController *)toViewController;
        editorController = (SPNoteEditorViewController *)fromViewController;
        
        [[_context containerView] insertSubview:[_context viewControllerForKey:UITransitionContextToViewControllerKey].view atIndex:0];
        
        // empty list view
        if (!listController.emptyListView.hidden) {
                        
            CGRect emptyListViewFrame = [containerView convertRect:listController.emptyListView.frame
                                                          fromView:listController.emptyListView.superview];
            
            UIView *emptyListViewSnapshot = [listController.emptyListView snapshotViewAfterScreenUpdates:YES];
            
            NSDictionary *emptyListViewAnimatedValues = [self animationValuesWithStartingFrame:emptyListViewFrame
                                                                                    finalFrame:emptyListViewFrame
                                                                                 startingAlpha:UIKitConstants.alphaZero
                                                                                    finalAlpha:UIKitConstants.alphaFull];

            NSDictionary *emptyListViewAnimationProperties = [self animationPropertiesWithDuration:SPAnimationEmptyStatePopDuration
                                                                                             delay:SPAnimationDelayZero
                                                                                           options:UIViewAnimationOptionCurveEaseInOut];

            SPTransitionSnapshot *emptyListViewTransitionSnapshot = [[SPTransitionSnapshot alloc] initWithSnapshot:emptyListViewSnapshot animatedValues:emptyListViewAnimatedValues animationProperties:emptyListViewAnimationProperties superView:containerView];
            emptyListViewTransitionSnapshot.springAnimation = NO;
            [self storeTransitionSnapshot:emptyListViewTransitionSnapshot];
        }
        
        
        // get selected path
        _selectedPath = [listController.notesListController indexPathForObject:editorController.currentNote];
        
        
        // get snapshots of the final editor text
        
        CGFloat finalWidth = [self listTextViewWidth];

        UIView *cleanSnapshot = [self textViewSnapshotForNote:editorController.currentNote
                                                        width:finalWidth
                                                 searchString:editorController.searchString
                                                      preview:YES];
        
        // tap a snapshot of the current view to avoid the need for creating a textview
        CGRect editorFrame = editorController.noteEditorTextView.frame;
        UIEdgeInsets editorContentInsets = editorController.noteEditorTextView.contentInset;
        CGRect dirtySnapshotFrame = CGRectMake(editorFrame.origin.x,
                                               editorFrame.origin.y + editorContentInsets.top,
                                               editorFrame.size.width,
                                               editorFrame.size.height - editorContentInsets.top - editorFrame.origin.y);

        UIView *dirtySnapshot = [editorController.view resizableSnapshotViewFromRect:dirtySnapshotFrame
                                                                  afterScreenUpdates:NO
                                                                       withCapInsets:UIEdgeInsetsZero];
        dirtySnapshot.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        dirtySnapshot.contentMode = UIViewContentModeTop;
        dirtySnapshot.clipsToBounds = YES;
        
        // set content mode to top for all subviews
        for (UIView *v in dirtySnapshot.subviews) {
            v.contentMode = UIViewContentModeTop;
        }

        // Snapshot: Tableview Rows
        for (NSIndexPath *path in visiblePaths) {

            SPNoteTableViewCell *cell = (SPNoteTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
            
            CGRect finalFrame = [containerView convertRect:cell.frame fromView:cell.superview];
            finalFrame.size.height -= cell.bodyLineFragmentPadding; // corrects for line spacing added to final row
            
            
            if (_selectedPath && path.row == _selectedPath.row) {
                
                // two snapshots are used for note content since the preview is a "clean" version of a note
                
                CGRect startingFrame = editorController.noteEditorTextView.frame;
                startingFrame.origin.y += editorController.noteEditorTextView.contentInset.top + editorController.noteEditorTextView.frame.origin.y;
                startingFrame.origin.x = editorController.noteEditorTextView.frame.origin.x;
                startingFrame.size.width = editorController.noteEditorTextView.frame.size.width;
                
                // Final frame is *not* the frame of the cell of the frame of the textView within the cell
                finalFrame = [containerView convertRect:cell.frame fromView:cell.superview];
                finalFrame.origin.x = 0;

                cleanSnapshot.contentMode = UIViewContentModeTop;
                cleanSnapshot.clipsToBounds = YES;
                dirtySnapshot.contentMode = UIViewContentModeTop;
                dirtySnapshot.clipsToBounds = YES;
                
                NSDictionary *animationProperties = [self animationPropertiesWithDuration:SPAnimationPopTableViewRowSelectionDuration
                                                                                    delay:SPAnimationDelayZero
                                                                            springDamping:SPAnimationPopTableViewRowSelectionDamping
                                                                                 velocity:SPAnimationPopTableViewRowSelectionVelocity
                                                                                  options:UIViewAnimationOptionCurveEaseInOut];

                NSDictionary *cleanSnapshotAnimatedValues = [self animationValuesWithStartingFrame:startingFrame
                                                                                        finalFrame:finalFrame
                                                                                     startingAlpha:UIKitConstants.alphaZero
                                                                                        finalAlpha:UIKitConstants.alphaFull];

                SPTransitionSnapshot *cleanTransitionSnapshot = [[SPTransitionSnapshot alloc] initWithSnapshot:cleanSnapshot
                                                                                                animatedValues:cleanSnapshotAnimatedValues
                                                                                           animationProperties:animationProperties
                                                                                                     superView:containerView];
                [self storeTransitionSnapshot:cleanTransitionSnapshot];
                
                NSDictionary *dirtySnapshotAnimatedValues = [self animationValuesWithStartingFrame:startingFrame
                                                                                        finalFrame:finalFrame
                                                                                     startingAlpha:UIKitConstants.alphaFull
                                                                                        finalAlpha:UIKitConstants.alphaZero];

                SPTransitionSnapshot *dirtyTransitionSnapshot = [[SPTransitionSnapshot alloc] initWithSnapshot:dirtySnapshot
                                                                                                animatedValues:dirtySnapshotAnimatedValues
                                                                                           animationProperties:animationProperties
                                                                                                     superView:containerView];
                [self storeTransitionSnapshot:dirtyTransitionSnapshot];
                
            } else {
                
                UIView *snapshot = [cell imageRepresentationWithinImageView];
                if (snapshot) {
                    
                    snapshot.contentMode = UIViewContentModeTop;
                    snapshot.clipsToBounds = YES;

                    CGRect startingFrame = finalFrame;
                    CGFloat moveAmount = [UIDevice isPad] ? 1200 : 700;
                    
                    if (path.row < _selectedPath.row)
                        moveAmount = moveAmount * -1;
                    
                    startingFrame.origin.y += moveAmount;
                    
                    CGFloat delay = MIN(ABS(_selectedPath.row - path.row) * 0.02 * (isPad ? 0.4 : 0.5), 0.15);

                    NSDictionary *animationProperties = [self animationPropertiesWithDuration:SPAnimationPopTableViewRowDuration
                                                                                        delay:delay
                                                                                springDamping:SPAnimationPopTableViewRowDamping
                                                                                     velocity:SPAnimationPopTableViewRowVelocity
                                                                                      options:UIViewAnimationOptionCurveEaseInOut];

                    NSDictionary *animatedValues = [self animationValuesWithStartingFrame:startingFrame
                                                                               finalFrame:finalFrame];

                    SPTransitionSnapshot *transitionSnapshot = [[SPTransitionSnapshot alloc] initWithSnapshot:snapshot
                                                                                               animatedValues:animatedValues
                                                                                          animationProperties:animationProperties
                                                                                                    superView:containerView];
                    [self storeTransitionSnapshot:transitionSnapshot];
                }
            }
        }

        // Snapshot(s): Blur + SearchBar
        SPTransitionSnapshot *blurSnapshot = [self blurSnapshotForListController:listController containerView:containerView];
        [self storeTransitionSnapshot:blurSnapshot];

        SPTransitionSnapshot *searchBarSnapshot = [self backSearchBarSnapshotForListController:listController containerView:containerView];
        [self storeTransitionSnapshot:searchBarSnapshot];
    }
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    [self incrementUseCount];
    
    [self setupTransition:transitionContext];
    [self animateTransitionSnapshotsToCompletion];
    
    [self decrementUseCount];
}

// decrement is only called when the animation performed on the view is the final animation needed for the view
// in the transition
- (void)animateTransitionSnapshotsToPercentCompletion:(CGFloat)percentCompletion
                                             animated:(BOOL)animated
                                    decrementUseCount:(BOOL)decrement {
    
    for (SPTransitionSnapshot *transitionSnapshot in _temporaryTransitionViews) {
        
        [transitionSnapshot setPercentComplete:percentCompletion
                                      animated:animated
                                    completion:^{
                                        if (decrement)
                                            [self decrementUseCount];
                                    }];
    }
}

- (void)animateTransitionSnapshotsToCompletion {
    
    [self animateTransitionSnapshotsToPercentCompletion:1.0 animated:YES decrementUseCount:YES];
}

- (void)completeTransition {
    
    // add final view controller to view
    UIViewController *fromViewController =[_context viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController =[_context viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [[_context containerView] addSubview:toViewController.view];
    [self clearTransitionSnapshots];
    
    fromViewController.view.alpha = 1.0;
    toViewController.view.alpha = 1.0;
    
    self.percentComplete = 1.0;
    _transitioning = NO;
    [_context completeTransition:YES];
}

- (void)incrementUseCount {
    
    self.useCount++;
}

- (void)decrementUseCount {
    
    self.useCount--;
    if (self.useCount == 0) {
        [self completeTransition];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    return 0.1;
}

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    [self incrementUseCount];
    [self setupTransition:transitionContext];
    [self decrementUseCount];
}


#pragma mark - Snapshots Generation

- (SPTransitionSnapshot *)blurSnapshotForListController:(SPNoteListViewController *)listController containerView:(UIView *)containerView {
    UIVisualEffectView *liveBlurView = listController.navigationBarBackground;
    UIVisualEffectView *snapshotBlurView = [[UIVisualEffectView alloc] initWithEffect:liveBlurView.effect];
    CGRect targetFrame = liveBlurView.frame;

    NSDictionary *animatedValues = [self animationValuesWithStartingFrame:targetFrame
                                                               finalFrame:targetFrame
                                                            startingAlpha:UIKitConstants.alphaZero
                                                               finalAlpha:UIKitConstants.alphaFull];

    NSDictionary *animationProperties = [self animationPropertiesWithDuration:SPAnimationPopTableViewRowSelectionDuration
                                                                        delay:SPAnimationDelayZero
                                                                springDamping:SPAnimationPopTableViewRowSelectionDamping
                                                                     velocity:SPAnimationPopTableViewRowSelectionVelocity
                                                                      options:UIViewAnimationOptionCurveEaseInOut];

    return [[SPTransitionSnapshot alloc] initWithSnapshot:snapshotBlurView
                                           animatedValues:animatedValues
                                      animationProperties:animationProperties
                                                superView:containerView];
}


- (SPTransitionSnapshot *)backSearchBarSnapshotForListController:(SPNoteListViewController *)listController containerView:(UIView *)containerView {
    UIView *searchBarImage = [listController.searchBar imageRepresentationWithinImageView];
    CGRect targetFrame = listController.searchBar.frame;

    NSDictionary *animatedValues = [self animationValuesWithStartingFrame:targetFrame
                                                               finalFrame:targetFrame
                                                            startingAlpha:UIKitConstants.alphaZero
                                                               finalAlpha:UIKitConstants.alphaFull];

    NSDictionary *animationProperties = [self animationPropertiesWithDuration:SPAnimationPopTableViewRowSelectionDuration
                                                                        delay:SPAnimationDelayZero
                                                                springDamping:SPAnimationPopTableViewRowSelectionDamping
                                                                     velocity:SPAnimationPopTableViewRowSelectionVelocity
                                                                      options:UIViewAnimationOptionCurveEaseInOut];

    return [[SPTransitionSnapshot alloc] initWithSnapshot:searchBarImage
                                           animatedValues:animatedValues
                                      animationProperties:animationProperties
                                                superView:containerView];
}


#pragma mark - Animation Properties Helpers

- (NSDictionary *)animationValuesWithStartingFrame:(CGRect)startingFrame
                                        finalFrame:(CGRect)finalFrame
                                     startingAlpha:(CGFloat)startingAlpha
                                        finalAlpha:(CGFloat)finalAlpha {
    return @{
        SPAnimationAlphaValueName: @{
                SPAnimationInitialValueName: @(startingAlpha),
                SPAnimationFinalValueName: @(finalAlpha)
        },
        SPAnimationFrameValueName: @{
            SPAnimationInitialValueName: [NSValue valueWithCGRect:startingFrame],
            SPAnimationFinalValueName : [NSValue valueWithCGRect:finalFrame]
        }
    };
}

- (NSDictionary *)animationValuesWithStartingFrame:(CGRect)startingFrame
                                        finalFrame:(CGRect)finalFrame {
    return @{
        SPAnimationFrameValueName: @{
            SPAnimationInitialValueName: [NSValue valueWithCGRect:startingFrame],
            SPAnimationFinalValueName : [NSValue valueWithCGRect:finalFrame]
        }
    };
}

- (NSDictionary *)animationPropertiesWithDuration:(CGFloat)duration
                                            delay:(CGFloat)delay
                                    springDamping:(CGFloat)springDamping
                                         velocity:(CGFloat)velocity
                                          options:(UIViewAnimationOptions)options {
    return @{
        SPAnimationDurationName: @(duration),
        SPAnimationDelayName: @(delay),
        SPAnimationSpringDampingName: @(springDamping),
        SPAnimationInitialVeloctyName: @(velocity),
        SPAnimationOptionsName: @(options)
    };
}

- (NSDictionary *)animationPropertiesWithDuration:(CGFloat)duration
                                            delay:(CGFloat)delay
                                          options:(UIViewAnimationOptions)options {
    return @{
        SPAnimationDurationName: @(duration),
        SPAnimationDelayName: @(delay),
        SPAnimationOptionsName: @(options)
    };
}

#pragma mark - Interactive Transition

- (void)endInteractionWithSuccess:(BOOL)success {
    
    self.hasActiveInteraction = FALSE;

    if (_context==nil) {
        
        return;
    }
    
    if ((self.percentComplete > 0.5) && success) {
        
        [self animateTransitionSnapshotsToCompletion];
        [_context finishInteractiveTransition];
    } else {
        
        [self animateTransitionSnapshotsToCompletion];
        [_context finishInteractiveTransition];
    }
}

 */

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
