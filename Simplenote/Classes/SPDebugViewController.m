//
//  SPDebugViewController.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 6/3/14.
//  Copyright (c) 2014 Automattic. All rights reserved.
//

#import "SPDebugViewController.h"
#import "SPAppDelegate.h"
#import "Note.h"
#import "Simplenote-Swift.h"


static NSInteger const SPDebugSectionCount  = 1;

typedef NS_ENUM(NSInteger, SPDebugRow) {
    SPDebugRowWebsocket     = 0,
    SPDebugRowTimestamp     = 1,
    SPDebugRowAuthenticated = 2,
    SPDebugRowReachability  = 3,
    SPDebugRowPendings      = 4,
    SPDebugRowEnqueued      = 5,
    SPDebugRowCount         = 6
};



@interface SPDebugViewController ()
@property (nonatomic, assign) NSUInteger localPendingChanges;
@property (nonatomic, assign) NSUInteger localEnqueuedChanges;
@property (nonatomic, assign) NSUInteger localEnqueuedDeletions;
@end



@implementation SPDebugViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView applySimplenoteGroupedStyle];
    self.title = NSLocalizedString(@"Debug", @"Debug Screen Title");
    
//    Simperium *simperium        = [[SPAppDelegate sharedDelegate] simperium];
//    SPBucket *bucket            = [simperium bucketForName:NSStringFromClass([Note class])];
//    [bucket statsWithCallback:^(SPBucket *bucket, NSUInteger localPendingChanges, NSUInteger localEnqueuedChanges, NSUInteger localEnqueuedDeletions) {
//        self.localPendingChanges    = localPendingChanges;
//        self.localEnqueuedChanges   = localEnqueuedChanges;
//        self.localEnqueuedDeletions = localEnqueuedDeletions;
//        
//        [self.tableView reloadData];
//    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SPDebugSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return SPDebugRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell   = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    Simperium *simperium    = [[SPAppDelegate sharedDelegate] simperium];
    
    switch (indexPath.row) {
        case SPDebugRowWebsocket: {
            cell.textLabel.text         = NSLocalizedString(@"WebSocket", @"WebSocket Status");
            cell.detailTextLabel.text   = simperium.networkStatus;
            cell.selectionStyle         = UITableViewCellSelectionStyleNone;
            break;
        }
        case SPDebugRowTimestamp: {
            NSString *timestamp         = [NSDateFormatter localizedStringFromDate:simperium.networkLastSeenTime
                                                                         dateStyle:NSDateFormatterShortStyle
                                                                         timeStyle:NSDateFormatterLongStyle];
            
            cell.textLabel.text         = NSLocalizedString(@"LastSeen", @"Last Message timestamp");
            cell.detailTextLabel.text   = timestamp;
            cell.selectionStyle         = UITableViewCellSelectionStyleNone;
            break;
        }
        case SPDebugRowReachability: {
            cell.textLabel.text         = NSLocalizedString(@"Reachability", @"Reachs Internet");
            cell.detailTextLabel.text   = simperium.requiresConnection ? @"YES" : @"NO";
            cell.selectionStyle         = UITableViewCellSelectionStyleNone;
            break;
        }
        case SPDebugRowAuthenticated: {
            cell.textLabel.text         = NSLocalizedString(@"Authenticated", @"User Authenticated");
            cell.detailTextLabel.text   = simperium.user.authenticated ? @"YES" : @"NO";
            cell.selectionStyle         = UITableViewCellSelectionStyleNone;
            break;
        }
        case SPDebugRowPendings: {
            cell.textLabel.text         = NSLocalizedString(@"Pendings", @"Number of changes pending to be sent");
            cell.detailTextLabel.text   = [NSString stringWithFormat:@"%ld", (long)self.localPendingChanges];
            cell.selectionStyle         = UITableViewCellSelectionStyleNone;
            break;
        }
        case SPDebugRowEnqueued: {
            cell.textLabel.text         = NSLocalizedString(@"Enqueued", @"Number of objects enqueued for processing");
            cell.detailTextLabel.text   = [NSString stringWithFormat:@"%ld", (long)self.localEnqueuedChanges];
            cell.selectionStyle         = UITableViewCellSelectionStyleNone;
            break;
        }
        default: {
            break;
        }
    }
    
    return cell;
}


#pragma mark - Static Helpers

+ (instancetype)newDebugViewController
{
    return [[SPDebugViewController alloc] initWithStyle:UITableViewStyleGrouped];
}

@end
