#import "SPAutomatticTracker.h"
#import "TracksService.h"



static NSString *const TracksUserDefaultsAnonymousUserIDKey = @"TracksUserDefaultsAnonymousUserIDKey";
static NSString *const TracksEventNamePrefix                = @"spios";
static NSString *const TracksAuthenticatedUserTypeKey       = @"simplenote:user_id";


@interface SPAutomatticTracker ()
@property (nonatomic, strong) TracksContextManager  *contextManager;
@property (nonatomic, strong) TracksService         *tracksService;
@property (nonatomic, strong) NSString              *anonymousID;
@end


@implementation SPAutomatticTracker

- (instancetype)init
{
    self = [super init];
    if (self) {
        TracksContextManager *contextManager = [TracksContextManager new];
        NSParameterAssert(contextManager);
        
        TracksService *service  = [[TracksService alloc] initWithContextManager:contextManager];
        service.eventNamePrefix = TracksEventNamePrefix;
        service.authenticatedUserTypeKey = TracksAuthenticatedUserTypeKey;
        NSParameterAssert(service);
        
        _tracksService          = service;
        _contextManager         = contextManager;
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static SPAutomatticTracker *_tracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tracker = [self new];
    });
    
    return _tracker;
}



#pragma mark - Public Methods

- (void)refreshMetadataWithEmail:(NSString *)email
{
    NSParameterAssert(self.tracksService);
    [self.tracksService switchToAuthenticatedUserWithUsername:email userID:email skipAliasEventCreation:NO];
}

- (void)refreshMetadataForAnonymousUser
{
    NSParameterAssert(self.tracksService);
    [self.tracksService switchToAnonymousUserWithAnonymousID:self.anonymousID];
}

- (void)trackEventWithName:(NSString *)name properties:(NSDictionary *)properties
{
    NSParameterAssert(name);
    NSParameterAssert(self.tracksService);
    
    [self.tracksService trackEventName:name withCustomProperties:properties];
    if (properties == nil) {
        NSLog(@"🔵 Tracked: %@", name);
    } else {
        NSLog(@"🔵 Tracked: %@, properties: %@", name, properties);
    }
}

- (NSString *)anonymousID
{
    if (_anonymousID.length != 0) {
        return _anonymousID;
    }
    
    NSString *anonymousID = [[NSUserDefaults standardUserDefaults] stringForKey:TracksUserDefaultsAnonymousUserIDKey];
    if (anonymousID == nil) {
        anonymousID = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:anonymousID forKey:TracksUserDefaultsAnonymousUserIDKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    _anonymousID = anonymousID;
    
    return _anonymousID;
}

@end
