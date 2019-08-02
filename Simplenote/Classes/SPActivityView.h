//
//  TWEpisodeActionView.h
//  Podcasts
//
//  Created by Tom Witkin on 3/21/13.
//  Copyright (c) 2013 Tom Witkin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SPActionButton, SPActivityView, Note, SPButton, SPSideBySideView;

@protocol SPActivityViewDelegate <NSObject>

@optional
- (void)activityView:(SPActivityView *)activityView didToggleIndex:(NSInteger)index enabled:(BOOL)enabled;
- (void)activityView:(SPActivityView *)activityView didSelectActionAtIndex:(NSInteger)index;
- (void)activityView:(SPActivityView *)activityView didSelectButtonAtIndex:(NSInteger)index;
@end

@interface SPActivityView : UIView {
        
    NSMutableArray *actionButtonArray;
    NSMutableArray *toggleArray;
    NSMutableArray *buttonArray;
    id<SPActivityViewDelegate> delegate;

    UIView *statusView;
    UIView *toggleView;
    UIScrollView *actionScrollView;
    UIView *buttonView;
    
    UILabel *statusLabel;
    UIActivityIndicatorView *statusActivityIndicator;
}

@property (nonatomic, assign) id<SPActivityViewDelegate> delegate;


+ (SPActivityView *)activityViewWithToggleTitles:(NSArray *)toggleTitles
                            toggleSelectedTitles:(NSArray *)toggleSelectedTitles
                              actionButtonImages:(NSArray *)actionButtonImages
                              actionButtonTitles:(NSArray *)actionButtonTitles
                                    buttonTitles:(NSArray *)buttonTitles
                                          status:(NSString *)status
                                        delegate:(id<SPActivityViewDelegate>)delegate;

- (void)setToggleState:(BOOL)enabled atIndex:(NSInteger)index;

// presents an activity indicator instaead of the status message
- (void)showActivityIndicator;
- (void)hideActivityIndicator;

// access controlls

- (UIButton *)toggleAtIndex:(NSInteger)index;
- (UIButton *)actionButtonAtIndex:(NSInteger)index;
- (UIButton *)buttonAtIndex:(NSInteger)index;

@end
