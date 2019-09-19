
//
//  SPTransitionController.m
//  Simplenote
//
//  Created by Tom Witkin on 7/3/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPTransitionController.h"
#import "SPAppDelegate.h"
#import "SPNoteEditorViewController.h"
#import "VSThemeManager.h"
#import "UIView+ImageRepresentation.h"
#import "Note.h"
#import "SPNoteListViewController.h"
#import "SPTextView.h"
#import "SPEditorTextView.h"
#import "NSAttributedString+Styling.h"
#import "NSMutableAttributedString+Styling.h"
#import "SPTransitionSnapshot.h"
#import "SPTextView.h"
#import "SPInteractiveTextStorage.h"
#import "NSString+Search.h"
#import "NSTextStorage+Highlight.h"
#import "NSString+Attributed.h"
#import "UIImage+Colorization.h"
#import "SPEmptyListView.h"
#import "UIDevice+Extensions.h"
#import "VSTheme+Extensions.h"
#import "SPInteractivePushPopAnimationController.h"
#import "Simplenote-Swift.h"

#define kEditorTransitionOffset 8

NSString *const SPTransitionControllerPopGestureTriggeredNotificationName = @"SPTransitionControllerPopGestureTriggeredNotificationName";

@interface SPTransitionController () {
    
    int useCount;
    CGFloat percentComplete;
}

@property (nonatomic, strong) SnapshotRenderer *renderer;
@property (nonatomic) id <UIViewControllerContextTransitioning> context;
@property (nonatomic) CGFloat initialPinchDistance;
@property (nonatomic) CGPoint initialPinchPoint;

@property (nonatomic) NSMutableArray *temporaryTransitionViews;
@property (nonatomic, strong) UIImage *pinIcon;
@property (nonatomic, strong) UIImage *searchPinIcon;

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, strong) SPInteractivePushPopAnimationController *pushPopAnimationController;

@property (nonatomic, strong) SPTextView *snapshotTextView;

@end

@implementation SPTransitionController

-(instancetype)initWithTableView:(UITableView *)tableView navigationController:(UINavigationController *)navigationController
{
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.renderer = [SnapshotRenderer new];
        useCount = 0;
        
        if ([UIDevice isPad]) {
            
            UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(handlePinch:)];
            [navigationController.view addGestureRecognizer:pinchGesture];
            
        } else {
            
            [navigationController.interactivePopGestureRecognizer addTarget:self
                                                                     action:@selector(handlePan:)];
            navigationController.interactivePopGestureRecognizer.delegate = self;
        }

        self.pushPopAnimationController = [[SPInteractivePushPopAnimationController alloc] initWithNavigationController:navigationController];
        
        self.navigationController = navigationController;
    }
    return self;
}


#pragma mark UIViewControllerTransitioningDelegate methods — Supporting Custom Transition Animations

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    return self;
}


#pragma mark UINavigationControllerDelegate methods — Supporting Custom Transition Animations


- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    
    BOOL navigatingFromListToEditor = [fromVC isKindOfClass:[SPNoteListViewController class]] &&
                                      [toVC isKindOfClass:[SPNoteEditorViewController class]];
    BOOL navigatingFromEditorToList = [fromVC isKindOfClass:[SPNoteEditorViewController class]] &&
                                      [toVC isKindOfClass:[SPNoteListViewController class]];

    if (navigatingFromListToEditor || navigatingFromEditorToList) {
        // return self since ViewController adopts UIViewControllerAnimatedTransitioningProtocal
        self.navigationOperation = operation;
        return self;
    } else {
        self.pushPopAnimationController.navigationOperation = operation;

        return self.pushPopAnimationController;
    }

    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController
{
    if (self.hasActiveInteraction) {
        return self;
    }
    else {
        return self.pushPopAnimationController.interactiveTransition;
    }
    
    return nil;
}


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

    return [_renderer renderWithNote:note size:size searchQuery:searchString preview:preview];
}

- (CGFloat)textViewTextWidthForWidth:(CGFloat)width {
    
    // set content insets on side
    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    
    CGFloat padding = [theme floatForKey:@"noteSidePadding" contextView:self.tableView];
    if (@available(iOS 11.0, *)) {
        padding += self.tableView.safeAreaInsets.left;
    }
    
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
    percentComplete = 0.0;
    _transitioning = YES;
    [self clearTransitionSnapshots];
    _temporaryTransitionViews = [NSMutableArray arrayWithCapacity:10];

    UIViewController *toViewController =[_context viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController =[_context viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGRect navigationBarFrame = toViewController.navigationController.navigationBar.frame;
    UIView *navigationBarSnapshot = [toViewController.navigationController.view resizableSnapshotViewFromRect:navigationBarFrame afterScreenUpdates:NO withCapInsets:UIEdgeInsetsMake(navigationBarFrame.origin.y, 0, 0, 0)];
    
    NSDictionary *navigationBarAnimatedValues = @{SPAnimationAlphaValueName: @{SPAnimationInitialValueName: @1.0,
                                                                               SPAnimationFinalValueName: @0.0
                                                                               },
                                                  SPAnimationFrameValueName : @{SPAnimationInitialValueName: [NSValue valueWithCGRect:navigationBarFrame],
                                                                                SPAnimationFinalValueName : [NSValue valueWithCGRect:navigationBarFrame]}
                                                  };
    NSDictionary *navigationBarAnimationProperties = @{SPAnimationDurationName: @0.4,
                                                       SPAnimationDelayName: @0.0,
                                                       SPAnimationOptionsName: [NSNumber numberWithInt:UIViewAnimationOptionCurveEaseInOut]
                                                       };
    
    SPTransitionSnapshot *navigationBarTransitionSnapshot = [[SPTransitionSnapshot alloc] initWithSnapshot:navigationBarSnapshot animatedValues:navigationBarAnimatedValues animationProperties:navigationBarAnimationProperties superView:toViewController.navigationController.view];
    navigationBarTransitionSnapshot.springAnimation = NO;
    [self storeTransitionSnapshot:navigationBarTransitionSnapshot];
    
    
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
            
            NSDictionary *emptyListViewAnimatedValues = @{SPAnimationAlphaValueName: @{SPAnimationInitialValueName: @1.0,
                                                                                       SPAnimationFinalValueName: @0.0
                                                                                       },
                                                          SPAnimationFrameValueName : @{SPAnimationInitialValueName: [NSValue valueWithCGRect:emptyListViewFrame],
                                                                                        SPAnimationFinalValueName : [NSValue valueWithCGRect:emptyListViewFrame]}
                                                          };
            NSDictionary *emptyListViewAnimationProperties = @{SPAnimationDurationName: @0.15,
                                                               SPAnimationDelayName: @0.0,
                                                               SPAnimationOptionsName: [NSNumber numberWithInt:UIViewAnimationOptionCurveEaseInOut]
                                                               };
            
            SPTransitionSnapshot *emptyListViewTransitionSnapshot = [[SPTransitionSnapshot alloc] initWithSnapshot:emptyListViewSnapshot animatedValues:emptyListViewAnimatedValues animationProperties:emptyListViewAnimationProperties superView:containerView];
            emptyListViewTransitionSnapshot.springAnimation = NO;
            [self storeTransitionSnapshot:emptyListViewTransitionSnapshot];
        }
        
        // get snapshots of the final editor text
        
        CGFloat finalWidth = [self textViewTextWidthForWidth:editorController.noteEditorTextView.frame.size.width];
        UIView *cleanSnapshot, *dirtySnapshot;
        
        cleanSnapshot = [self textViewSnapshotForNote:editorController.currentNote
                                                width:finalWidth
                                         searchString:editorController.searchString
                                              preview:YES];
        
        dirtySnapshot = [self textViewSnapshotForNote:editorController.currentNote
                                                width:finalWidth
                                         searchString:editorController.searchString
                                              preview:NO];
        

        CGRect finalEditorPosition = editorController.noteEditorTextView.frame;
        finalEditorPosition.origin.y += editorController.noteEditorTextView.contentInset.top + editorController.noteEditorTextView.textContainerInset.top;
        if (@available(iOS 11.0, *)) {
            finalEditorPosition.origin.y += self.tableView.safeAreaInsets.top;
        }
        finalEditorPosition.origin.x = 0;
        finalEditorPosition.size.width = editorController.view.frame.size.width;
        
        if ([visiblePaths containsObject:_selectedPath]  || !_selectedPath) {
            
            
            for (NSIndexPath *path in visiblePaths) {
                
                
                SPNoteTableViewCell *cell = (SPNoteTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
                CGRect startingFrame = [containerView convertRect:cell.frame fromView:cell.superview];
                startingFrame.size.height -= 5; // corrects for line spacing added to final row
                
                if (_selectedPath && path.row == _selectedPath.row) {
                    
                    // two snapshots are used for note content since the preview is a "clean" versio of a note
                    startingFrame = [cell previewFrameIn:containerView];
                    
                    startingFrame.size.height -= 5; // corrects for line spacing added to final row

                    cleanSnapshot.contentMode = UIViewContentModeTop;
                    cleanSnapshot.clipsToBounds = YES;
                    dirtySnapshot.contentMode = UIViewContentModeTop;
                    dirtySnapshot.clipsToBounds = YES;
                    
                    // calculate initial spring velocity based on location
                    // of cell in listController
                    CGFloat initialVelocity = MIN(9.0, 3.0 + (startingFrame.origin.y - finalEditorPosition.origin.y) / finalEditorPosition.size.height * 6.0);
                    
                    NSDictionary *animationProperties = @{SPAnimationDurationName: @0.55,
                                                         SPAnimationDelayName: @0.025,
                                                         SPAnimationSpringDampingName: @1.0,
                                                         SPAnimationInitialVeloctyName: [NSNumber numberWithFloat:initialVelocity],
                                                          SPAnimationOptionsName : [NSNumber numberWithInt:UIViewAnimationOptionCurveEaseOut]
                                                         };
                    
                    NSDictionary *cleanSnapshotAnimatedValues = @{SPAnimationAlphaValueName: @{SPAnimationInitialValueName: @1.0,
                                                                              SPAnimationFinalValueName: @0.0},
                                                                  SPAnimationFrameValueName : @{SPAnimationInitialValueName: [NSValue valueWithCGRect:startingFrame],
                                                                               SPAnimationFinalValueName : [NSValue valueWithCGRect:finalEditorPosition]
                                                                               }
                                                                   };

                    SPTransitionSnapshot *cleanTransitionSnapshot = [[SPTransitionSnapshot alloc] initWithSnapshot:cleanSnapshot
                                                                                                    animatedValues:cleanSnapshotAnimatedValues
                                                                                               animationProperties:animationProperties
                                                                                                         superView:containerView];
                    [self storeTransitionSnapshot:cleanTransitionSnapshot];
                    
                    NSDictionary *dirtySnapshotAnimatedValues = @{SPAnimationAlphaValueName: @{SPAnimationInitialValueName: @0.0,
                                                                                               SPAnimationFinalValueName: @1.0},
                                                                SPAnimationFrameValueName : @{SPAnimationInitialValueName: [NSValue valueWithCGRect:startingFrame],
                                                                                              SPAnimationFinalValueName : [NSValue valueWithCGRect:finalEditorPosition]
                                                                                }
                                                                   };
                    SPTransitionSnapshot *dirtyTransitionSnapshot = [[SPTransitionSnapshot alloc] initWithSnapshot:dirtySnapshot
                                                                                                    animatedValues:dirtySnapshotAnimatedValues
                                                                                               animationProperties:animationProperties
                                                                                                         superView:containerView];
                    [self storeTransitionSnapshot:dirtyTransitionSnapshot];
                    
                } else {
                    
                    UIView *snapshot;
                    snapshot = [cell snapshotViewAfterScreenUpdates:NO];
                    if (snapshot) {
                        
                        snapshot.contentMode = UIViewContentModeTop;
                        snapshot.clipsToBounds = YES;
                        
                        // calculate final position based on position from selected path
                        CGRect endingFrame = startingFrame;
                        CGFloat moveAmount = [UIDevice isPad] ? 1200 : 700;
                        
                        if (path.row < _selectedPath.row)
                            moveAmount = moveAmount * -1;
                        
                        endingFrame.origin.y += moveAmount;
                        
                        // add delay based on position to selected cell
                        CGFloat delay = MAX(0, 0.05 - ABS(_selectedPath.row - path.row) * 0.0125);
                        
                        NSDictionary *animationProperties = @{SPAnimationDurationName: @0.5,
                                                              SPAnimationDelayName: [NSNumber numberWithFloat:delay],
                                                              SPAnimationSpringDampingName: @0.6,
                                                              SPAnimationInitialVeloctyName: @8.0,
                                                              SPAnimationOptionsName : [NSNumber numberWithInt:UIViewAnimationOptionCurveEaseInOut]
                                                              };
                        
                        NSDictionary *animatedValues = @{SPAnimationFrameValueName : @{SPAnimationInitialValueName: [NSValue valueWithCGRect:startingFrame],
                                                                      SPAnimationFinalValueName : [NSValue valueWithCGRect:endingFrame]
                                                                      }
                                                         };
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
            
            NSDictionary *emptyListViewAnimatedValues = @{SPAnimationAlphaValueName: @{SPAnimationInitialValueName: @0.0,
                                                                                       SPAnimationFinalValueName: @1.0
                                                                                       },
                                                          SPAnimationFrameValueName : @{SPAnimationInitialValueName: [NSValue valueWithCGRect:emptyListViewFrame],
                                                                SPAnimationFinalValueName : [NSValue valueWithCGRect:emptyListViewFrame]}
                                                          };
            NSDictionary *emptyListViewAnimationProperties = @{SPAnimationDurationName: @0.4,
                                                               SPAnimationDelayName: @0.0,
                                                               SPAnimationOptionsName: [NSNumber numberWithInt:UIViewAnimationOptionCurveEaseInOut]
                                                               };
            
            SPTransitionSnapshot *emptyListViewTransitionSnapshot = [[SPTransitionSnapshot alloc] initWithSnapshot:emptyListViewSnapshot animatedValues:emptyListViewAnimatedValues animationProperties:emptyListViewAnimationProperties superView:containerView];
            emptyListViewTransitionSnapshot.springAnimation = NO;
            [self storeTransitionSnapshot:emptyListViewTransitionSnapshot];
        }
        
        
        // get selected path
        _selectedPath = [listController.fetchedResultsController indexPathForObject:editorController.currentNote];
        
        
        // get snapshots of the final editor text
        
        CGFloat finalWidth = [self textViewTextWidthForWidth:editorController.noteEditorTextView.frame.size.width];
        UIView *cleanSnapshot, *dirtySnapshot;
        
        cleanSnapshot = [self textViewSnapshotForNote:editorController.currentNote
                                                width:finalWidth
                                         searchString:editorController.searchString
                                              preview:YES];
        
        // tap a snapshot of the current view to avoid the need for creating a textview
        dirtySnapshot = [editorController.view resizableSnapshotViewFromRect:CGRectMake(editorController.noteEditorTextView.frame.origin.x, editorController.noteEditorTextView.frame.origin.y + editorController.noteEditorTextView.contentInset.top, editorController.noteEditorTextView.frame.size.width, editorController.noteEditorTextView.frame.size.height - editorController.noteEditorTextView.contentInset.top - editorController.noteEditorTextView.frame.origin.y)
                                                          afterScreenUpdates:NO
                                                               withCapInsets:UIEdgeInsetsZero];
        dirtySnapshot.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        dirtySnapshot.contentMode = UIViewContentModeTop;
        dirtySnapshot.clipsToBounds = YES;
        
        // set content mode to top for all subviews
        for (UIView *v in dirtySnapshot.subviews) {
            v.contentMode = UIViewContentModeTop;
        }
        
        
        for (NSIndexPath *path in visiblePaths) {
            
            
            SPNoteTableViewCell *cell = (SPNoteTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
            
            CGRect finalFrame = [containerView convertRect:cell.frame fromView:cell.superview];
            finalFrame.size.height -= cell.previewLineFragmentPadding; // corrects for line spacing added to final row
            
            
            if (_selectedPath && path.row == _selectedPath.row) {
                
                // two snapshots are used for note content since the preview is a "clean" version of a note
                
                CGRect startingFrame = editorController.noteEditorTextView.frame;
                startingFrame.origin.y += editorController.noteEditorTextView.contentInset.top + editorController.noteEditorTextView.frame.origin.y;
                startingFrame.origin.x = editorController.noteEditorTextView.frame.origin.x;
                startingFrame.size.width = editorController.noteEditorTextView.frame.size.width;
                
                // final frame is note the frame of the cell of the frame of the
                // textView within the cell
                finalFrame = [cell previewFrameIn:containerView];
                finalFrame.size.width = editorController.view.frame.size.width;
                finalFrame.origin.x = 0;
                finalFrame.size.height -= 5; // corrects for line spacing added to final row

                cleanSnapshot.contentMode = UIViewContentModeTop;
                cleanSnapshot.clipsToBounds = YES;
                dirtySnapshot.contentMode = UIViewContentModeTop;
                dirtySnapshot.clipsToBounds = YES;
                
                NSDictionary *animationProperties = @{SPAnimationDurationName: @0.45,
                                                      SPAnimationDelayName: @0.0,
                                                      SPAnimationSpringDampingName: @1.0,
                                                      SPAnimationInitialVeloctyName: @7.0,
                                                      SPAnimationOptionsName: [NSNumber numberWithInt:UIViewAnimationOptionCurveEaseInOut]
                                                      };
                
                NSDictionary *cleanSnapshotAnimatedValues = @{SPAnimationAlphaValueName: @{SPAnimationInitialValueName: @0.0,
                                                                                           SPAnimationFinalValueName: @1.0},
                                                              SPAnimationFrameValueName : @{SPAnimationInitialValueName: [NSValue valueWithCGRect:startingFrame],
                                                                                            SPAnimationFinalValueName : [NSValue valueWithCGRect:finalFrame]
                                                                           }
                                                              };
                
                SPTransitionSnapshot *cleanTransitionSnapshot = [[SPTransitionSnapshot alloc] initWithSnapshot:cleanSnapshot
                                                                                                animatedValues:cleanSnapshotAnimatedValues
                                                                                           animationProperties:animationProperties
                                                                                                     superView:containerView];
                [self storeTransitionSnapshot:cleanTransitionSnapshot];
                
                NSDictionary *dirtySnapshotAnimatedValues = @{SPAnimationAlphaValueName: @{SPAnimationInitialValueName: @1.0,
                                                                                           SPAnimationFinalValueName: @0.0},
                                                              SPAnimationFrameValueName : @{SPAnimationInitialValueName: [NSValue valueWithCGRect:startingFrame],
                                                                                            SPAnimationFinalValueName : [NSValue valueWithCGRect:finalFrame]
                                                                           }
                                                              };
                SPTransitionSnapshot *dirtyTransitionSnapshot = [[SPTransitionSnapshot alloc] initWithSnapshot:dirtySnapshot
                                                                                                animatedValues:dirtySnapshotAnimatedValues
                                                                                           animationProperties:animationProperties
                                                                                                     superView:containerView];
                [self storeTransitionSnapshot:dirtyTransitionSnapshot];
                
            } else {
                
                UIView *snapshot;
                snapshot = [cell imageRepresentationWithinImageView];
                if (snapshot) {
                    
                    snapshot.contentMode = UIViewContentModeTop;
                    snapshot.clipsToBounds = YES;

                    CGRect startingFrame = finalFrame;
                    CGFloat moveAmount = [UIDevice isPad] ? 1200 : 700;
                    
                    if (path.row < _selectedPath.row)
                        moveAmount = moveAmount * -1;
                    
                    startingFrame.origin.y += moveAmount;
                    
                    CGFloat delay = MIN(ABS(_selectedPath.row - path.row) * 0.02 * (isPad ? 0.4 : 0.5), 0.15);

                    NSDictionary *animationProperties = @{SPAnimationDurationName: @0.45,
                                                          SPAnimationDelayName: [NSNumber numberWithFloat:delay],
                                                          SPAnimationSpringDampingName: @1.0,
                                                          SPAnimationInitialVeloctyName: @0.6,
                                                          SPAnimationOptionsName: [NSNumber numberWithInt:UIViewAnimationOptionCurveEaseInOut]
                                                          };
                    
                    NSDictionary *animatedValues = @{SPAnimationFrameValueName : @{SPAnimationInitialValueName: [NSValue valueWithCGRect:startingFrame],
                                                                  SPAnimationFinalValueName : [NSValue valueWithCGRect:finalFrame]
                                                                  }
                                                     };
                    SPTransitionSnapshot *transitionSnapshot = [[SPTransitionSnapshot alloc] initWithSnapshot:snapshot
                                                                                               animatedValues:animatedValues
                                                                                          animationProperties:animationProperties
                                                                                                    superView:containerView];
                    [self storeTransitionSnapshot:transitionSnapshot];
                }
            }
        }
    }
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
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
    
    percentComplete = 1.0;
    _transitioning = NO;
    [_context completeTransition:YES];
}

- (void)incrementUseCount {
    
    useCount++;
}
- (void)decrementUseCount {
    
    useCount--;
    if (useCount == 0)
        [self completeTransition];
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    return 0.1;
}

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    
    [self incrementUseCount];
    [self setupTransition:transitionContext];
    [self decrementUseCount];
}

#pragma mark Interactive Transition

-(void)endInteractionWithSuccess:(BOOL)success {
    
    self.hasActiveInteraction = FALSE;

    if (_context==nil) {
        
        return;
    }
    
    if ((percentComplete > 0.5) && success) {
        
        [self animateTransitionSnapshotsToCompletion];
        [_context finishInteractiveTransition];
    } else {
        
        [self animateTransitionSnapshotsToCompletion];
        [_context finishInteractiveTransition];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {

    // By the time this method is called, the existing topViewController has been popped –
    // so topViewController contains the view we are transitioning *to*.
    // We only want to handle the Editor > List transition with a custom transition, so if
    // there's anything other than the List view on the top of the stack, we'll let the OS handle it.
    BOOL isTransitioningToList = [self.navigationController.topViewController isKindOfClass:[SPNoteListViewController class]];
    
    if (isTransitioningToList && !_transitioning && sender.state == UIGestureRecognizerStateBegan) {
        [self postPopGestureNotification];
    }
    
    return;
}


-(void)handlePinch:(UIPinchGestureRecognizer*)sender
{
    if (!_transitioning &&
        sender.numberOfTouches >= 2 && // require two fingers
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

@end
