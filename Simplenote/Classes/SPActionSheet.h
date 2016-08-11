#import <UIKit/UIKit.h>

@class SPActionSheet;

@protocol SPActionSheetDelegate <NSObject>

@optional

//Delegate receives this call as soon as the item has been selected
- (void)actionSheet:(SPActionSheet *)actionSheet didSelectItemAtIndex:(NSInteger)index;

//Delegate receives this call once the popover has begun the dismissal animation
- (void)actionSheetDidShow:(SPActionSheet *)actionSheet;
- (void)actionSheetDidDismiss:(SPActionSheet *)actionSheet;

@end

@interface SPActionSheet : UIView {
    CGRect boxFrame;
    CGSize contentSize;
        
    id<SPActionSheetDelegate> delegate;
    
    UIView *parentView;
    
    UIWindow *mainWindow;
    
    NSArray *buttonArray;
    
    NSArray *subviewsArray;
    
    NSArray *dividerRects;
    
    UIView *contentView;
    
    UIView *titleView;
    
    UIActivityIndicatorView *activityIndicator;
    
    UIPanGestureRecognizer *panGesture;
    
    //Instance variable that can change at runtime
    BOOL showDividerRects;
}

@property (nonatomic, retain) UIView *titleView;

@property (nonatomic, retain) UIView *contentView;

@property (nonatomic, retain) NSArray *subviewsArray;

@property (nonatomic, assign) id<SPActionSheetDelegate> delegate;

@property (nonatomic) BOOL tapToDismiss;
@property (nonatomic) BOOL swipeToDismiss;
@property (nonatomic) BOOL showPadding;

// By assigning a cancel button index, actionSheet:didSelectItemAtIndex: is called when the
// tapToDismiss or swipeToDismiss gesture is invoked is called.
@property (nonatomic) CGFloat cancelButtonIndex;

#pragma mark - Class Static Showing Methods

+ (SPActionSheet *)showActionSheetInView:(UIView *)view
                             withMessage:(NSString *)message
                    withContentViewArray:(NSArray *)viewArray
                    withButtonTitleArray:(NSArray *)titleArray
                                delegate:(id<SPActionSheetDelegate>)delegate;


#pragma mark - Instance Showing Methods
- (void)layoutInView:(UIView *)view;

#pragma mark - Dismissal
//Dismisses the view, and removes it from the view stack.
- (void)dismiss;
- (void)dismiss:(BOOL)animated;
- (void)dismiss:(BOOL)animated completion:(void (^)())completion;


@end
