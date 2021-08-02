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
NSString *const kSimperiumTermsOfServiceURL         = @"https://simplenote.com/terms/";
NSString *const kSimperiumPreferencesObjectKey      = @"preferences-key";

NSString *const kAutomatticAnalyticLearnMoreURL     = @"https://automattic.com/cookies";

#ifdef APPSTORE_DISTRIBUTION
NSString *const kShareExtensionGroupName            = @"group.com.codality.NotationalFlow";
#elif INTERNAL_DISTRIBUTION
NSString *const kShareExtensionGroupName            = @"group.com.codality.NotationalFlow.Internal";
#elif RELEASE
NSString *const kShareExtensionGroupName            = @"group.com.codality.NotationalFlow";
#else
NSString *const kShareExtensionGroupName            = @"group.com.codality.NotationalFlow.Development";
#endif

NSString *const kSimplenoteTrashKey                 = @"__##__trash__##__";
NSString *const kSimplenoteUntaggedKey              = @"__##__untagged__##__";
NSString *const kSimplenoteWPServiceName            = @"simplenote-wpcom";

NSString *const kSignInErrorNotificationName        = @"SPSignInErrorNotificationName";

NSString *const kPinTimeoutPreferencesKey           = @"kPinTimeoutPreferencesKey";

NSString *const kWordPressAuthURL                   = @"https://public-api.wordpress.com/oauth2/authorize?response_type=code&scope=global&client_id=%@&redirect_uri=%@&state=%@";
