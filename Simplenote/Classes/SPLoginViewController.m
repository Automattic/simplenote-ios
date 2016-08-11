//
//  SPLoginViewController.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 3/18/15.
//  Copyright (c) 2015 Automattic. All rights reserved.
//

#import "SPLoginViewController.h"
#import "SPConstants.h"
#import "SPTracker.h"

@import _1PasswordExtension;



#pragma mark ================================================================================
#pragma mark Constants
#pragma mark ================================================================================

static CGRect SPLoginOnePasswordButtonFrame             = {0.0f, 0.0f, 38.0f, 38.0f};
static UIEdgeInsets SPLoginOnePasswordImageInsets       = {0.0f, 16.0f, 0.0f, 0.0f};
static UIEdgeInsets SPLoginOnePasswordImageInsetsSmall  = {0.0f, 16.0f, 3.0f, 0.0f};

static CGFloat SPLoginScreenSmallThreshold              = 480.0f;


#pragma mark ================================================================================
#pragma mark SPLoginViewController
#pragma mark ================================================================================

@interface SPLoginViewController ()
@property (nonatomic, strong) UIButton *onePasswordButton;
@end


@implementation SPLoginViewController

- (void)dealloc
{
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(signingIn))];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Add OnePassword
    UIButton *onePasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [onePasswordButton setImage:[UIImage imageNamed:@"onepassword_button"] forState:UIControlStateNormal];
    onePasswordButton.frame = SPLoginOnePasswordButtonFrame;
    onePasswordButton.imageEdgeInsets = self.isSmallScreen ? SPLoginOnePasswordImageInsetsSmall : SPLoginOnePasswordImageInsets;
    self.onePasswordButton = onePasswordButton;
    
    // Attach the OnePassword button
    self.usernameField.rightView = self.onePasswordButton;
    
    // Observe SigningIn Changes
    NSKeyValueObservingOptions options = (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial);
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(signingIn)) options:options context:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadOnePassword];
}

- (BOOL)isSmallScreen
{
    return CGRectGetHeight(self.view.bounds) <= SPLoginScreenSmallThreshold;
}


#pragma mark - Overriden Methods

- (IBAction)performAction:(id)sender
{
    [super performAction:sender];
    
    // TODO: Implement a proper 'didSignUp' callback
    if (self.signingIn) {
        [SPTracker trackUserSignedIn];
    } else {
        [SPTracker trackUserAccountCreated];
    }
}


#pragma mark - KVO Helpers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self reloadOnePassword];
}


#pragma mark - One Password Helpers

- (void)reloadOnePassword
{
    // Update the OnePassword Handler
    SEL hander = self.signingIn ? @selector(findLoginFromOnePassword:) : @selector(saveLoginToOnePassword:);
    [self.onePasswordButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.onePasswordButton addTarget:self action:hander forControlEvents:UIControlEventTouchUpInside];

    // Show the OnePassword view, if it's available
    BOOL isOnePasswordAvailable         = [[OnePasswordExtension sharedExtension] isAppExtensionAvailable];
    self.usernameField.rightViewMode    = isOnePasswordAvailable ? UITextFieldViewModeAlways : UITextFieldViewModeNever;
}

- (IBAction)findLoginFromOnePassword:(id)sender
{
    [self.view endEditing:YES];
    
    [[OnePasswordExtension sharedExtension] findLoginForURLString:kOnePasswordSimplenoteURL
                                                forViewController:self
                                                           sender:sender
                                                       completion:^(NSDictionary *loginDict, NSError *error) {
                                                           if (!loginDict) {
                                                               if (error.code != AppExtensionErrorCodeCancelledByUser) {
                                                                   NSLog(@"OnePassword Error: %@", error);
                                                                   [SPTracker trackOnePasswordLoginFailure];
                                                               }
                                                               return;
                                                           }
                                                           
                                                           self.usernameField.text = loginDict[AppExtensionUsernameKey];
                                                           self.passwordField.text = loginDict[AppExtensionPasswordKey];
                                                           
                                                           [SPTracker trackOnePasswordLoginSuccess];
                                                           [super performAction:nil];
                                                       }];
}

- (IBAction)saveLoginToOnePassword:(id)sender
{
    NSDictionary *newLoginDetails = @{
        AppExtensionTitleKey        : kOnePasswordSimplenoteTitle,
        AppExtensionUsernameKey     : self.usernameField.text ?: [NSString string],
        AppExtensionPasswordKey     : self.passwordField.text ?: [NSString string],
    };

    NSDictionary *passwordGenerationOptions = @{
        AppExtensionGeneratedPasswordMinLengthKey: @(kOnePasswordGeneratedMinLength),
        AppExtensionGeneratedPasswordMaxLengthKey: @(kOnePasswordGeneratedMaxLength)
    };

    [[OnePasswordExtension sharedExtension] storeLoginForURLString:kOnePasswordSimplenoteURL
                                                      loginDetails:newLoginDetails
                                         passwordGenerationOptions:passwordGenerationOptions
                                                 forViewController:self
                                                            sender:sender
                                                        completion:^(NSDictionary *loginDict, NSError *error) {

                                                            if (!loginDict) {
                                                                if (error.code != AppExtensionErrorCodeCancelledByUser) {
                                                                    NSLog(@"OnePassword Error: %@", error);
                                                                    [SPTracker trackOnePasswordSignupFailure];
                                                                }
                                                                return;
                                                            }
     
                                                            self.usernameField.text = loginDict[AppExtensionUsernameKey] ?: [NSString string];
                                                            self.passwordField.text = loginDict[AppExtensionPasswordKey] ?: [NSString string];
                                                            self.passwordConfirmField.text = self.passwordField.text;
                                                            
                                                            [SPTracker trackOnePasswordSignupSuccess];
                                                        }];
}

@end
