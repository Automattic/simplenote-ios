//
//  PinLockController.m
//  ASiST
//
//  Created by Oliver on 10.09.09.
//  Copyright 2009 Drobnik.com. All rights reserved.
//

#import "DTPinLockController.h"
#import "DTPinDigitView.h"
#import "DTPinErrorView.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "VSThemeManager.h"
#import "Simplenote-Swift.h"

#define MARGIN_SIDES 23.0

@interface DTPinLockController ()

@property (nonatomic, assign) BOOL biometryUnlockDidDismiss;

- (void) switchToConfirmPageAnimated:(BOOL)animated;
- (void) setupDigitViews;
@end


@implementation DTPinLockController

@synthesize pin;
@synthesize numberOfDigits;

- (id<PinLockDelegate>)pinLockDelegate
{
    return pinLockDelegate;
}
- (void)setPinLockDelegate:(id<PinLockDelegate>)newPinLockDelegate
{
    pinLockDelegate = newPinLockDelegate;
}

- (void)fixLayout
{
    message2.frame = CGRectMake(0,33, self.view.bounds.size.width, 20);
    [self setupDigitViews];
}

- (instancetype)initWithMode:(PinLockControllerMode)initMode
{
    if (self = [super init])
    {
        UIColor *textColor = [UIColor simplenoteLockTextColor];

        self.navigationBar.translucent = NO;

        mode = initMode;
        
        baseViewController = [[DTTwoPageViewController alloc] init];
        [self pushViewController:baseViewController animated:NO];
        
        hiddenTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 130, 100, 20)];
        hiddenTextField.alpha = 0;
        hiddenTextField.keyboardType = UIKeyboardTypeNumberPad;
        hiddenTextField.delegate = self;
        hiddenTextField.keyboardAppearance = SPUserInterface.isDark ? UIKeyboardAppearanceDark : UIKeyboardAppearanceDefault;
        [baseViewController.view addSubview:hiddenTextField];
        
        // message on page 1
        message = [[UILabel alloc] initWithFrame:CGRectMake(0,33, self.view.bounds.size.width, 20)];
        message.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        message.text = NSLocalizedString(@"Enter a passcode", "Message shown on passcode lock screen");
        message.textColor = textColor;
        message.font = [UIFont systemFontOfSize:17.0];
        message.opaque = NO;
        message.backgroundColor = [UIColor clearColor];
        message.textAlignment = NSTextAlignmentCenter;
        
        [baseViewController.firstPageView addSubview:message];
        
        // message on page 2
        message2 = [[UILabel alloc] initWithFrame:CGRectMake(0,33, self.view.bounds.size.width, 20)];
        message2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        message2.font = [UIFont systemFontOfSize:17.0];
        message2.textColor = textColor;
        message2.opaque = NO;
        message2.backgroundColor = [UIColor clearColor];
        message2.textAlignment = NSTextAlignmentCenter;
        [baseViewController.secondPageView addSubview:message2];
        
        
        // sub message on page 1
        subMessage = [[UILabel alloc] initWithFrame:CGRectMake(0,151, self.view.bounds.size.width, 20)];
        subMessage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        subMessage.font = [UIFont systemFontOfSize:14.0];
        subMessage.textColor = textColor;
        subMessage.opaque = NO;
        subMessage.backgroundColor = [UIColor clearColor];
        subMessage.textAlignment = NSTextAlignmentCenter;
        [baseViewController.firstPageView addSubview:subMessage];
        
        numberOfWrongPasscodes = 0.0;
        errorView = [[DTPinErrorView alloc] initWithFrame:CGRectMake(0.0, 151.0, self.view.bounds.size.width, 20.0)];
        errorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [baseViewController.secondPageView addSubview:errorView];
        
        first = YES;
        
        
        // default
        numberOfDigits = 4;

        // NOTE: This entire ViewController will be rebuilt soon. Please forgive the untidy-mess!
        UIColor *barBackgroundColor = [UIColor simplenoteNavigationBarModalBackgroundColor];
        self.navigationBar.backgroundColor = barBackgroundColor;
        self.navigationBar.barTintColor = barBackgroundColor;

        self.view.backgroundColor = [UIColor simplenoteLockBackgroundColor];

        baseViewController.view.backgroundColor = [UIColor clearColor];
        
        if (mode == PinLockControllerModeUnlockAllowTouchID) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
        }
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupDigitViews];
    [hiddenTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // TouchID: Execute after a small delay, since the app might still be in inactive status
    NSTimeInterval const delayInSeconds = 0.3f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self displayTouchIDIfAppropriate];
    });
}

- (void)dealloc
{
    [hiddenTextField resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)appDidEnterForeground:(NSNotification *)notification
{
    [hiddenTextField becomeFirstResponder];
    [self displayTouchIDIfAppropriate];
}

- (void)displayTouchIDIfAppropriate
{
    // Don't show biometry prompt if user-set timeout hasn't expired yet
    if ([SPPinLockManager shouldBypassPinLock]) {
        return;
    }
    
    // Prevent duplicate biometry prompts
    if (self.biometryUnlockDidDismiss) {
        return;
    }
    
    BOOL appIsActive = [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
    BOOL localAuthIsAvailable = !![LAContext class];
    BOOL modeIsUnlockWithTouchID = mode == PinLockControllerModeUnlockAllowTouchID;
    
    if (appIsActive && modeIsUnlockWithTouchID && localAuthIsAvailable) {
        LAContext *context = [LAContext new];
        NSError *error;
        BOOL touchIdIsAvailable = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
        
        if (touchIdIsAvailable) {
            context.localizedFallbackTitle = NSLocalizedString(@"Enter passcode", @"Touch ID fallback title");
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                    localizedReason:NSLocalizedString(@"To unlock the application", @"Touch ID reason/explanation")
                              reply:^(BOOL success, NSError *error) {
                                  if (success) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [self dismissKeyboard];
                                          [self didFinishUnlocking];
                                      });
                                  }
                                  
                                  self.biometryUnlockDidDismiss = YES;
                              }];
        }
    }
    
}


- (void) setupDigitViews
{
    // remove existing pin views
    [firstPagePinGroup removeFromSuperview];
    firstPagePinGroup = nil;

    [secondPagePinGroup removeFromSuperview];
    secondPagePinGroup = nil;
        
    NSMutableArray *tmpArray = [NSMutableArray array];
    NSMutableArray *tmpArray2 = [NSMutableArray array];
    
    CGFloat distance = 0.0;
    
    CGFloat width = round((self.view.bounds.size.width - MARGIN_SIDES - MARGIN_SIDES - (numberOfDigits-1)*distance) / numberOfDigits);
    
    // limit width
    width = MIN(50, width);
    
    CGSize digitBoxSize = CGSizeMake(width, 53.0); // 61 for 4
    
    // calc width of all digits
    
    CGFloat neededWidth = digitBoxSize.width * numberOfDigits + (distance * (numberOfDigits-1));
    
    CGFloat leftMargin = (self.view.bounds.size.width - neededWidth)/2.0;
    
    firstPagePinGroup = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, 74, neededWidth, 53)];
    firstPagePinGroup.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    firstPagePinGroup.center = CGPointMake(baseViewController.firstPageView.center.x, firstPagePinGroup.center.y);
    [baseViewController.firstPageView addSubview:firstPagePinGroup];
    
    secondPagePinGroup = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, 74, neededWidth, 53)];
    secondPagePinGroup.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    secondPagePinGroup.center = CGPointMake(baseViewController.secondPageView.frame.size.width / 2.0, secondPagePinGroup.center.y);
    [baseViewController.secondPageView addSubview:secondPagePinGroup];
    
    
    UIColor *textColor = [UIColor simplenoteLockTextColor];
    
    for (int i=0;i<numberOfDigits;i++)
    {
        DTPinDigitView *oneDigit = [[DTPinDigitView alloc] initWithFrame:CGRectMake((digitBoxSize.width + distance)*i, 0, digitBoxSize.width, digitBoxSize.height)];
        oneDigit.digitColor = textColor;
        [tmpArray addObject:oneDigit];
        [firstPagePinGroup addSubview:oneDigit];
        
        DTPinDigitView *anotherDigit = [[DTPinDigitView alloc] initWithFrame:CGRectMake((digitBoxSize.width + distance)*i, 0, digitBoxSize.width, digitBoxSize.height)];
        anotherDigit.digitColor = textColor;
        [tmpArray2 addObject:anotherDigit];
        [secondPagePinGroup addSubview:anotherDigit];
    }
    
    pins = [[NSArray alloc] initWithArray:tmpArray];
    pins2 = [[NSArray alloc] initWithArray:tmpArray2];
    
    if (mode == PinLockControllerModeSetPin)
    {
        baseViewController.title = NSLocalizedString(@"Set Passcode", "Prompt when setting up a passcode");
        message2.text = NSLocalizedString(@"Re-enter a passcode", "Prompt when setting up a passcode");
        baseViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                             target:self action:@selector(cancel:)];
    }
    else if (mode == PinLockControllerModeRemovePin)
    {
        // nothing yet
        baseViewController.title = NSLocalizedString(@"Turn off Passcode", "Prompt when disabling passcode");
        message2.text = NSLocalizedString(@"Enter your passcode", nil);
        baseViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                             target:self action:@selector(cancel:)];
        
        [self switchToConfirmPageAnimated:NO];
    }
    else if (mode == PinLockControllerModeUnlock || mode == PinLockControllerModeUnlockAllowTouchID)
    {
        // nothing yet
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *appName = [info objectForKey:@"CFBundleDisplayName"];
        baseViewController.title = [NSString stringWithFormat:NSLocalizedString(@"Unlock %@", "Message shown when gaining entry to app via a passcode"), appName];
        message2.text = NSLocalizedString(@"Enter your passcode", "Pin Lock");
        
        [self switchToConfirmPageAnimated:NO];
    }
    
}

- (void) switchToFirstPageAnimated:(BOOL)animated
{
    for (DTPinDigitView *onePin in pins)
    {
        onePin.showDot = NO;
    }
    
    for (DTPinDigitView *onePin in pins2)
    {
        onePin.showDot = NO;
        
    }
    
    [baseViewController switchToPageAtIndex:0 animated:animated];
    
    first=YES;
    hiddenTextField.text = @"";
    
}

- (void)switchToConfirmPageAnimated:(BOOL)animated
{
    for (DTPinDigitView *oneDigit in pins2) {
        oneDigit.showDot = NO;
    }
    
    [baseViewController switchToPageAtIndex:1 animated:animated];
    
    first=NO;
    hiddenTextField.text = @"";
}

#pragma mark Rotation
- (BOOL)shouldAutorotate {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return NO;
    else
        return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskAll;
}

#pragma mark Properties

- (void) setNumberOfDigits:(NSUInteger)newNumber
{
    if (numberOfDigits != newNumber)
    {
        // also check if it fits with currently set Pin
        
        NSUInteger pinLength = [pin length];
        if (pinLength && newNumber!=pinLength)
        {
            NSLog(@"Number of Digits in passed PIN (%lu) did not match set numberOfDigits (%d)", (unsigned long)pinLength, (int)newNumber);
            
            if (numberOfDigits!=pinLength)
            {
                numberOfDigits = pinLength;
            }
            else {
                return; // ignore
            }
        }
        
        else
        {
            numberOfDigits = newNumber;
        }
    }
}

- (void) setPin:(NSString *)newPin
{
    if (pin!=newPin)
    {
        // also check if it fits with numberOfDigits
        
        pin = newPin;
        
        NSUInteger pinLength = [newPin length];
        if (pinLength && numberOfDigits!=pinLength)
        {
            NSLog(@"Number of Digits in passed PIN (%lu) did not match set numberOfDigits (%lu)", (unsigned long)pinLength, (unsigned long)numberOfDigits);
            self.numberOfDigits = pinLength;
        }
        
    }
}

#pragma mark delegate messaging
- (void)didFinishSelectingNewPin:(NSString *)newPin
{
    if ([pinLockDelegate respondsToSelector:@selector(pinLockController:didFinishSelectingNewPin:)])
    {
        [pinLockDelegate pinLockController:self didFinishSelectingNewPin:newPin];
    }
}

- (void)didFinishRemovingPin
{
    if ([pinLockDelegate respondsToSelector:@selector(pinLockControllerDidFinishRemovingPin)])
    {
        [pinLockDelegate pinLockControllerDidFinishRemovingPin];
    }
}

- (void)didFinishUnlocking
{
    if ([pinLockDelegate respondsToSelector:@selector(pinLockControllerDidFinishUnlocking)])
    {
        [pinLockDelegate pinLockControllerDidFinishUnlocking];
    }
}


#pragma mark hiddenTextField

- (void)updateErrorMessage
{
    if (numberOfWrongPasscodes >= 3) {
        NSString *cancelTitle = NSLocalizedString(@"OK", nil);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                 message:NSLocalizedString(@"FailedAttempts", @"Show a message when user enter 3 wrong passcodes")
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addCancelActionWithTitle:cancelTitle handler:nil];
        [alertController presentFromRootViewController];
        
        
    }
    [self earthquake:secondPagePinGroup];
    
    numberOfWrongPasscodes++;
    NSString *errorMessageContructor = numberOfWrongPasscodes > 1.0 ? NSLocalizedString(@"%i Failed Passcode Attempts", "Number of failed entries entering in passcode") : NSLocalizedString(@"%i Failed Passcode Attempt", "Number of failed entries entering in passcode");
    NSString *errorMessage = [NSString stringWithFormat:errorMessageContructor, numberOfWrongPasscodes];
    
    if (pinLockDelegate && [pinLockDelegate respondsToSelector:@selector(pinLockControllerDidFailUnlockingWithNumberOfAttempts:)])
    {
        [pinLockDelegate pinLockControllerDidFailUnlockingWithNumberOfAttempts:numberOfWrongPasscodes];
    }
    
    [errorView setMessage:errorMessage];
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger newLength = [textField.text length]-range.length+[string length];
    
    NSInteger i = newLength;
    
    NSArray *arrayToSet = first?pins:pins2;
    for (DTPinDigitView *oneDigit in arrayToSet) {
        if (i > 0) {
            oneDigit.showDot = YES;
            i--;
        } else {
            oneDigit.showDot = NO;
        }
    }
    
    // if all 4 set
    if (newLength == numberOfDigits) {
        // prettier: in any case we want the rightmost field set
        
        // we cannot come here via a backspace so we assume that textField + string = PIN entered
        NSMutableString *pinEntered = [NSMutableString stringWithString:textField.text];
        [pinEntered appendString:string];
        
        if (mode == PinLockControllerModeSetPin) {
            if (first) {
                self.pin = [NSString stringWithString:pinEntered];
                [self switchToConfirmPageAnimated:YES];
                return NO;
            } else {
                if ([pinEntered isEqualToString:pin]) {
                    // brief delay to allow for drawing of fourth pin
                    [self performSelector:@selector(didFinishSelectingNewPin:) withObject:[NSString stringWithString:pinEntered] afterDelay:0.1];
                    [self dismissKeyboard];
                } else {
                    // 2nd pin does not match
                    subMessage.text = NSLocalizedString(@"Passcodes did not match. Try again.", "Pin Lock");
                    
                    [self switchToFirstPageAnimated:YES];
                    return NO;
                }
            }
        } else if (mode == PinLockControllerModeRemovePin) {
            if ([pinEntered isEqualToString:pin]) {
                // brief delay to allow for drawing of fourth pin
                [self performSelector:@selector(didFinishRemovingPin) withObject:nil afterDelay:0.1];
                [self dismissKeyboard];
            } else {
                // 2nd pin does not match
                [self updateErrorMessage];
                [self performSelector:@selector(switchToConfirmPageAnimated:)  withObject:[NSNumber numberWithBool:NO] afterDelay:0.2];
                return NO;
            }
        } else if (mode == PinLockControllerModeUnlock || mode == PinLockControllerModeUnlockAllowTouchID) {
            if ([pinEntered isEqualToString:pin]) {
                errorView.hidden = YES;
                [self dismissKeyboard];
                [self performSelector:@selector(didFinishUnlocking) withObject:nil afterDelay:0.1];
            } else {
                // 2nd pin does not match
                [self updateErrorMessage];
                [self performSelector:@selector(switchToConfirmPageAnimated:)  withObject:[NSNumber numberWithBool:NO] afterDelay:0.2];
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (shouldDismissKeyboard) {
        return YES;
    }
    
    // Don't allow keyboard to be dismissed on iPad
    return UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad;
}

- (void)dismissKeyboard
{
    shouldDismissKeyboard = YES;
    [hiddenTextField resignFirstResponder];
}


#pragma mark Actions

- (void)cancel:(id)sender
{
    [self dismissKeyboard];
    
    // if there is a delegate method, then we let it deal with it
    if (pinLockDelegate && [pinLockDelegate respondsToSelector:@selector(pinLockControllerDidCancel)])
    {
        [pinLockDelegate pinLockControllerDidCancel];
    }
    else  // otherwise we dismiss ourselves
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)earthquake:(UIView*)itemView
{
    // From http://stackoverflow.com/a/1827373/1379066
    CGFloat t = 4.0;
    
    CGAffineTransform leftQuake  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, 0);
    CGAffineTransform rightQuake = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, 0);
    
    itemView.transform = leftQuake;  // starting point
    
    [UIView beginAnimations:@"earthquake" context:(__bridge void *)(itemView)];
    [UIView setAnimationRepeatAutoreverses:YES]; // important
    [UIView setAnimationRepeatCount:5];
    [UIView setAnimationDuration:0.07];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(earthquakeEnded:finished:context:)];
    
    itemView.transform = rightQuake; // end here & auto-reverse
    
    [UIView commitAnimations];
}
- (void)earthquakeEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([finished boolValue])
    {
        UIView* item = (__bridge UIView *)context;
        item.transform = CGAffineTransformIdentity;
    }
}

@end

