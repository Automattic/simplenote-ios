//
//  DTTwoPageViewController.h
//  DTPinLockController
//
//  Created by Oliver Drobnik on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DTTwoPageViewController : UIViewController 
{
	UIView *firstPageView;
	UIView *secondPageView;
	
	NSInteger currentIndex;
}

@property (nonatomic, retain) UIView *firstPageView;
@property (nonatomic, retain) UIView *secondPageView;

- (void) switchToPageAtIndex:(NSInteger)index animated:(BOOL)animated;


@end
