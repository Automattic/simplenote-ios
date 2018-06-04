//
//  WPAuthHandler.h
//  Simplenote
//  Handles oauth authentication with WordPress.com
//

#import <Simperium/Simperium.h>

@interface WPAuthHandler : NSObject
+ (BOOL)isWPAuthenticationUrl:(NSURL*)url;
+ (SPUser *)authorizeSimplenoteUserFromUrl:(NSURL*)url forAppId:(NSString *)appId;
@end
