//
//  SPConstants.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 12/22/14.
//  Copyright (c) 2014 Automattic. All rights reserved.
//

#import "SPConstants.h"



#pragma mark ================================================================================
#pragma mark Constants
#pragma mark ================================================================================

NSString *const kSimperiumBaseURL                   = @"https://api.simperium.com/1";
NSString *const kSimperiumForgotPasswordURL         = @"https://app.simplenote.com/forgot/";
NSString *const kSimperiumTermsOfServiceURL         = @"http://simplenote.com/terms/";

NSString *const kShareExtensionAccountName          = @"Main";
NSString *const kShareExtensionServiceName          = @"SimplenoteShare";

#ifdef APPSTORE_DISTRIBUTION
NSString *const kShareExtensionGroupName            = @"group.com.codality.NotationalFlow";
#elif INTERNAL_DISTRIBUTION
NSString *const kShareExtensionGroupName            = @"group.com.codality.NotationalFlow.Internal";
#elif RELEASE
NSString *const kShareExtensionGroupName            = @"group.com.codality.NotationalFlow";
#else
NSString *const kShareExtensionGroupName            = @"group.com.codality.NotationalFlow.Development";
#endif

NSString *const kOnePasswordSimplenoteTitle         = @"Simplenote";
NSString *const kOnePasswordSimplenoteURL           = @"simplenote.com";
NSInteger const kOnePasswordGeneratedMinLength      = 4;
NSInteger const kOnePasswordGeneratedMaxLength      = 50;

NSString *const kFirstLaunchKey                     = @"SPFirstLaunch";
NSString *const kSelectedTagKey                     = @"SPSelectedTag";
NSString *const kSelectedNoteKey                    = @"SPSelectedNote";
NSString *const kSimplenotePinKey                   = @"SimplenotePin";
NSString *const kSimplenotePinLegacyKey             = @"PIN";
NSString *const kSimplenoteUseBiometryKey           = @"SimplenoteUseTouchID";
NSString *const kSimplenoteMarkdownDefaultKey       = @"MarkdownDefault";
NSString *const kSimplenoteWPServiceName            = @"simplenote-wpcom";
NSString *const kSimplenotePasscodeServiceName      = @"simplenote-passcode";

NSString *const kSignInErrorNotificationName        = @"SPSignInErrorNotificationName";

NSString *const kSimplenotePublishURL               = @"http://simp.ly/publish/";
NSString *const kSimplenoteDarkThemeName            = @"dark";
NSString *const kSimplenoteDefaultThemeName         = @"default";

NSString *const kPinTimeoutPreferencesKey           = @"kPinTimeoutPreferencesKey";
