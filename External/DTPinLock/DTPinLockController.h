//
//  PinLockController.h
//  ASiST
//
//  Created by Oliver on 10.09.09.
//  Copyright 2009 Drobnik.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTTwoPageViewController.h"
#import "SPNavigationController.h"


typedef enum { PinLockControllerModeSetPin = 0, PinLockControllerModeRemovePin = 1, PinLockControllerModeUnlock = 2, PinLockControllerModeUnlockAllowTouchID} PinLockControllerMode;

@class DTPinLockController;


@protocol PinLockDelegate <NSObject>

@optional

- (void) pinLockController:(DTPinLockController *)pinLockController didFinishSelectingNewPin:(NSString *)newPin;
- (void) pinLockControllerDidFinishRemovingPin;
- (void) pinLockControllerDidFinishUnlocking;
- (void) pinLockControllerDidFailUnlockingWithNumberOfAttempts:(NSInteger)numberOfAttempts;
- (void) pinLockControllerDidCancel;

@end


@class DTPinErrorView;
@interface DTPinLockController : SPNavigationController <UITextFieldDelegate>
{
	PinLockControllerMode mode;
	NSArray *pins;
	NSArray *pins2;
	
	UIView *firstPagePinGroup;
	UIView *secondPagePinGroup;
	
	UITextField *hiddenTextField;
	UILabel *message;
	UILabel *message2;
	
	UILabel *subMessage;
	
	NSInteger numberOfWrongPasscodes;
	DTPinErrorView *errorView;
	
	UINavigationBar *navBar;
	
	BOOL first;
	BOOL shouldDismissKeyboard;
	
	NSString *pin;
	
	id<PinLockDelegate> pinLockDelegate;
    
	DTTwoPageViewController *baseViewController;
	
	NSUInteger numberOfDigits;
}

@property (nonatomic, assign) id<PinLockDelegate> pinLockDelegate;
@property (nonatomic, retain) NSString *pin;

@property (nonatomic, assign) NSUInteger numberOfDigits;

- (instancetype)initWithMode:(PinLockControllerMode)initMode;
- (void)fixLayout;

@end
