//
//  TWAcitivityOpenInSafari.m
//  Poster
//
//  8/17/12.
//
//

#import "SPAcitivitySafari.h"

@implementation SPAcitivitySafari

- (NSString *)activityType
{
    return @"SPAcitivitySafari";
}

- (NSString *)activityTitle
{
    return @"Safari";
}

- (UIImage *)activityImage {
    
    return [UIImage imageNamed:@"button_safari"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (NSObject *o in activityItems) {
        if ([o isKindOfClass:NSURL.class]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{ 
    for (NSObject *o in activityItems) {
        if ([o isKindOfClass:NSURL.class]) {
            openURL = (NSURL *)o;
            return;
        }
    }
}


- (void)performActivity
{
    if (openURL) {
        [[UIApplication sharedApplication] openURL:openURL options:@{} completionHandler:nil];
    }
    
    [self activityDidFinish:YES];
}


@end
